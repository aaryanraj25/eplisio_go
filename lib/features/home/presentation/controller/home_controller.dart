import 'dart:async';
import 'package:eplisio_go/core/utils/location_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:eplisio_go/core/utils/services.dart';
import 'package:eplisio_go/features/home/data/model/home_model.dart';
import 'package:eplisio_go/features/home/data/repo/home_repo.dart';

class HomeController extends GetxController {
  final HomeRepository _repository;

  // Reactive variables
  final _statistics = Rx<StatisticsModel>(StatisticsModel.empty());
  final _isLoading = false.obs;
  final _isClockedIn = false.obs;
  final _clockInTime = DateTime.now().obs;
  final _clockOutTime = Rx<DateTime?>(null);
  final _formattedTimer = '00:00:00'.obs;
  final _isWfhMode = false.obs;
  final employeeName = ''.obs;
  Timer? _timer;

  // Getters
  StatisticsModel get statistics => _statistics.value;
  bool get isLoading => _isLoading.value;
  bool get isClockedIn => _isClockedIn.value;
  String get formattedTimer => _formattedTimer.value;
  bool get isWfhMode => _isWfhMode.value;

  // Formatted time getters
  String get formattedClockInTime {
    try {
      return DateFormat('HH:mm').format(_clockInTime.value);
    } catch (e) {
      return '--:--';
    }
  }

  String get formattedClockOutTime {
    try {
      return _clockOutTime.value != null
          ? DateFormat('HH:mm').format(_clockOutTime.value!)
          : '--:--';
    } catch (e) {
      return '--:--';
    }
  }

  HomeController({required HomeRepository repository})
      : _repository = repository;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onClose() {
    _timer?.cancel();
    LocationService.stopLocationUpdates();
    super.onClose();
  }

  Future<void> _initializeController() async {
    await _loadSavedState();
    await Future.wait([
      loadStatistics(),
      _loadEmployeeData(),
    ]);
  }

  Future<void> _loadSavedState() async {
    try {
      final storage = GetStorage();
      final now = DateTime.now();

      // Load clock state
      _isClockedIn.value = storage.read('is_clocked_in') ?? false;

      // Load clock times
      final savedClockInTime = storage.read('clock_in_time');
      final savedClockOutTime = storage.read('clock_out_time');

      if (savedClockInTime != null) {
        final clockInTime = DateTime.parse(savedClockInTime);
        // Only load if it's from today
        if (clockInTime.year == now.year &&
            clockInTime.month == now.month &&
            clockInTime.day == now.day) {
          _clockInTime.value = clockInTime;

          if (savedClockOutTime != null) {
            _clockOutTime.value = DateTime.parse(savedClockOutTime);
            // If clocked out, show timer until end of day
            _startEndOfDayTimer(clockInTime);
          } else if (_isClockedIn.value) {
            // If still clocked in, start running timer
            _startTimer();
            LocationService.startLocationUpdates();
          }
        } else {
          // Clear old data if not from today
          await storage.remove('clock_in_time');
          await storage.remove('clock_out_time');
          await storage.write('is_clocked_in', false);
          _resetTimerState();
        }
      }

      // Load WFH mode
      _isWfhMode.value = storage.read('is_wfh_mode') ?? false;
    } catch (e) {
      debugPrint('Error loading saved state: $e');
      _resetTimerState();
    }
  }

  void _resetTimerState() {
    _isClockedIn.value = false;
    _clockInTime.value = DateTime.now();
    _clockOutTime.value = null;
    _formattedTimer.value = '00:00:00';
  }

  Future<void> _loadEmployeeData() async {
    try {
      final storage = GetStorage();
      final cachedData = storage.read('employee_data');

      if (cachedData != null) {
        employeeName.value = cachedData['name'] ?? '';
      }

      final employee = await _repository.getUserData();
      employeeName.value = employee.name;

      await storage.write('employee_data', employee.toJson());
    } catch (e) {
      debugPrint('Error loading employee data: $e');
      if (employeeName.value.isEmpty) {
        employeeName.value = 'User';
      }
    }
  }

  Future<void> loadStatistics() async {
    try {
      final stats = await _repository.getStatistics();
      _statistics.value = stats;
    } catch (e) {
      debugPrint('Error loading statistics: $e');
      _statistics.value = StatisticsModel.empty();
    }
  }

  void toggleWfhMode() {
    if (!_isClockedIn.value) {
      _isWfhMode.value = !_isWfhMode.value;
      GetStorage().write('is_wfh_mode', _isWfhMode.value);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final difference = now.difference(_clockInTime.value);
      _formattedTimer.value = _formatDuration(difference);
    });
  }

  void _startEndOfDayTimer(DateTime clockInTime) {
    final now = DateTime.now();

    // Calculate elapsed time since clock in
    if (_clockOutTime.value != null) {
      final difference = _clockOutTime.value!.difference(clockInTime);
      _formattedTimer.value = _formatDuration(difference);
    }

    // Set timer to clear at end of day
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final timeUntilEndOfDay = endOfDay.difference(now);

    Future.delayed(timeUntilEndOfDay, () {
      _resetTimerState();

      // Clear saved state at end of day
      final storage = GetStorage();
      storage.remove('clock_in_time');
      storage.remove('clock_out_time');
      storage.write('is_clocked_in', false);
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  Future<void> toggleClockInOut() async {
    if (_isLoading.value) return;

    try {
      _isLoading.value = true;

      final storage = GetStorage();
      final hasPermission = await LocationService.checkLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission not granted');
      }
      await LocationService.initialize();
      Map<String, double> location;
      int retryCount = 0;
      do {
        location = await LocationService.getCurrentLocation();
        retryCount++;
        if (location['latitude'] == 0.0 &&
            location['longitude'] == 0.0 &&
            retryCount < 3) {
          await Future.delayed(const Duration(seconds: 2));
        }
      } while (location['latitude'] == 0.0 &&
          location['longitude'] == 0.0 &&
          retryCount < 3);

      // Validate location
      if (location['latitude'] == 0.0 && location['longitude'] == 0.0) {
        throw Exception(
            'Unable to get accurate location. Please check your GPS settings.');
      }

      if (_isClockedIn.value) {
        // Clock Out
        final response = await _repository.clockOut(
          latitude: location['latitude']!,
          longitude: location['longitude']!,
        );

        _clockOutTime.value = response.clockOutTime;
        _isClockedIn.value = false;

        // Save state
        await storage.write('is_clocked_in', false);
        await storage.write(
            'clock_out_time', response.clockOutTime?.toIso8601String());

        LocationService.stopLocationUpdates();

        _timer?.cancel();
        _startEndOfDayTimer(_clockInTime.value);
      } else {
        // Clock In
        final response = await _repository.clockIn(
          workFromHome: _isWfhMode.value,
          latitude: location['latitude']!,
          longitude: location['longitude']!,
        );

        _clockInTime.value = response.clockInTime;
        _clockOutTime.value = null;
        _isClockedIn.value = true;

        // Save state
        await storage.write('is_clocked_in', true);
        await storage.write(
            'clock_in_time', response.clockInTime.toIso8601String());
        await storage.remove('clock_out_time');

        LocationService.startLocationUpdates();
        _startTimer();
      }

      await loadStatistics();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to ${_isClockedIn.value ? 'clock out' : 'clock in'}: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Helper method to check if a date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
