import 'dart:async';
import 'package:eplisio_go/core/utils/location_services.dart';
import 'package:eplisio_go/core/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
  final _attendanceId = ''.obs;
  final _totalHours = 0.0.obs;
  final employeeName = ''.obs;

  // Timers
  Timer? _timer;
  Timer? _autoClockOutTimer;
  Timer? _endOfDayTimer;

  // Getters
  StatisticsModel get statistics => _statistics.value;
  bool get isLoading => _isLoading.value;
  bool get isClockedIn => _isClockedIn.value;
  String get formattedTimer => _formattedTimer.value;
  bool get isWfhMode => _isWfhMode.value;
  double get totalHours => _totalHours.value;

  // Formatted time getters - Always return IST times for display
  String get formattedClockInTime {
    try {
      return TimeUtils.formatTimeHHMM(_clockInTime.value);
    } catch (e) {
      return '--:--';
    }
  }

  String get formattedClockOutTime {
    try {
      return _clockOutTime.value != null
          ? TimeUtils.formatTimeHHMM(_clockOutTime.value!)
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        _updateCurrentLocation(Get.context!);
      } else {
        debugPrint('Context is null in onInit');
      }
    });
  }

  void _resetTimerState() {
    _isClockedIn.value = false;
    _clockInTime.value = TimeUtils.nowIST();
    _clockOutTime.value = null;
    _formattedTimer.value = '00:00:00';
    _totalHours.value = 0.0;
  }

  void showLocationInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Why We Need Your Location',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'EplisioGo requires background location access to verify your work '
          'location during shifts. This ensures accurate attendance tracking.\n\n'
          '🔹 Location is tracked **only after you clock in** and stops automatically '
          'when you clock out or at 9 PM.\n\n'
          '🔒 Your location data is shared **only with your organization** during work hours.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            child: const Text('Got it'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCurrentLocation(BuildContext context) async {
    try {
      final hasPermission = await LocationService.checkLocationPermission();

      if (hasPermission) {
        // Show explanation dialog if permission is granted
        showLocationInfoDialog(context);
        return;
      } else {
        debugPrint('Location permission not granted');
        return;
      }
    } catch (e) {
      debugPrint('Error checking location: $e');
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    _autoClockOutTimer?.cancel();
    _endOfDayTimer?.cancel();
    LocationService.stopLocationUpdates();
    super.onClose();
  }

  Future<void> _initializeController() async {
    await _fetchTodayAttendance();
    await Future.wait([
      loadStatistics(),
      _loadEmployeeData(),
    ]);
    _setupEndOfDayTimer();
    _setupAutoClockOutTimer();
  }

  Future<void> _fetchTodayAttendance() async {
    try {
      final clockInfo = await _repository.getClockInTime();

      _attendanceId.value = clockInfo.attendanceId;
      
      // Convert clock times from UTC to IST for UI display
      _clockInTime.value = TimeUtils.toIST(clockInfo.clockInTime);
      _isWfhMode.value = clockInfo.workFromHome;

      // Check if this is from a previous day and not clocked out
      if (!TimeUtils.isToday(clockInfo.clockInTime) && clockInfo.clockOutTime == null) {
        // Auto clock out at 9 PM of that day
        final autoClockOutTime = DateTime(
          _clockInTime.value.year,
          _clockInTime.value.month,
          _clockInTime.value.day,
          21, // 9 PM
          0,
          0,
        );

        try {
          final response = await _repository.clockOut(
            latitude: clockInfo.clockInLocation?['latitude'] ?? 0.0,
            longitude: clockInfo.clockInLocation?['longitude'] ?? 0.0,
          );

          // Convert clock-out time from UTC to IST for display
          _clockOutTime.value = TimeUtils.toIST(response.clockOutTime!);
          _isClockedIn.value = false;

          // Calculate total hours
          if (response.clockOutTime != null) {
            final difference =
                _clockOutTime.value!.difference(_clockInTime.value);
            _totalHours.value = difference.inMinutes / 60;
          }

          debugPrint('Auto clocked out for previous day at 9 PM');
        } catch (e) {
          debugPrint('Error auto clocking out for previous day: $e');
        }
      } else {
        // Normal flow for today
        _isClockedIn.value = clockInfo.clockOutTime == null;
        if (clockInfo.clockOutTime != null) {
          // Convert clock-out time from UTC to IST for display
          _clockOutTime.value = TimeUtils.toIST(clockInfo.clockOutTime!);
          _totalHours.value = clockInfo.totalHours ?? 0.0;
          final difference =
              _clockOutTime.value!.difference(_clockInTime.value);
          _formattedTimer.value = TimeUtils.formatDuration(difference);
        } else if (_isClockedIn.value) {
          _startTimer();
          LocationService.startLocationUpdates();
          _setupAutoClockOutTimer();
        }
      }

      // Save state
      final storage = GetStorage();
      await storage.write('is_clocked_in', _isClockedIn.value);
      await storage.write(
          'clock_in_time', _clockInTime.value.toIso8601String());
      await storage.write('is_wfh_mode', _isWfhMode.value);

      if (_clockOutTime.value != null) {
        await storage.write(
            'clock_out_time', _clockOutTime.value!.toIso8601String());
      }
    } catch (e) {
      debugPrint('Error fetching attendance: $e');
      await _loadSavedState();
    }
  }

  Future<void> _loadSavedState() async {
    try {
      final storage = GetStorage();

      // Load clock state
      _isClockedIn.value = storage.read('is_clocked_in') ?? false;

      // Load clock times
      final savedClockInTime = storage.read('clock_in_time');
      final savedClockOutTime = storage.read('clock_out_time');

      if (savedClockInTime != null) {
        final clockInTime = DateTime.parse(savedClockInTime);
        // Only load if it's from today
        if (TimeUtils.isToday(clockInTime)) {
          _clockInTime.value = clockInTime;

          if (savedClockOutTime != null) {
            _clockOutTime.value = DateTime.parse(savedClockOutTime);
            // Calculate and display total hours
            final difference = _clockOutTime.value!.difference(_clockInTime.value);
            _formattedTimer.value = TimeUtils.formatDuration(difference);
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
      final now = DateTime.now(); // Local time
      final difference = now.difference(_clockInTime.value);
      _formattedTimer.value = TimeUtils.formatDuration(difference);
    });
  }

  // Setup timer to reset data at end of day
  void _setupEndOfDayTimer() {
    _endOfDayTimer?.cancel();

    final now = DateTime.now(); // Local time
    final endOfDay = TimeUtils.getEndOfDay();
    final timeUntilEndOfDay = endOfDay.difference(now);

    if (timeUntilEndOfDay.inSeconds > 0) {
      _endOfDayTimer = Timer(timeUntilEndOfDay, () {
        _resetTimerState();
        final storage = GetStorage();
        storage.remove('clock_in_time');
        storage.remove('clock_out_time');
        storage.write('is_clocked_in', false);
      });
    }
  }

  // Setup auto clock-out timer if user is clocked in
  void _setupAutoClockOutTimer() {
    _autoClockOutTimer?.cancel();

    if (_isClockedIn.value) {
      final now = DateTime.now(); // Local time
      final autoClockOutTime = TimeUtils.getNinepm();

      // If it's past 9 PM IST, clock out immediately
      if (now.isAfter(autoClockOutTime)) {
        if (_isClockedIn.value) {
          _autoClockOut();
        }
        return;
      }

      // Schedule auto clock out
      final timeUntilAutoClockOut = autoClockOutTime.difference(now);
      _autoClockOutTimer = Timer(timeUntilAutoClockOut, () async {
        if (_isClockedIn.value) {
          await _autoClockOut();
        }
      });

      debugPrint(
          'Auto clock-out scheduled for 9:00 PM IST (in ${timeUntilAutoClockOut.inHours} hours and ${timeUntilAutoClockOut.inMinutes % 60} minutes)');
    }
  }

  // Automatically clock out the user
  Future<void> _autoClockOut() async {
    try {
      debugPrint('Executing auto clock-out');

      // Get last known location or use default
      Map<String, double> location = {'latitude': 0.0, 'longitude': 0.0};

      try {
        location = await LocationService.getCurrentLocation();
      } catch (e) {
        debugPrint('Error getting location for auto clock-out: $e');
      }

      // Perform clock out operation
      final response = await _repository.clockOut(
        latitude: location['latitude']!,
        longitude: location['longitude']!,
      );

      // Convert clock-out time from UTC to IST for display
      _clockOutTime.value = TimeUtils.toIST(response.clockOutTime!);
      _isClockedIn.value = false;

      // Save state
      final storage = GetStorage();
      await storage.write('is_clocked_in', false);
      await storage.write(
          'clock_out_time', _clockOutTime.value?.toIso8601String());

      LocationService.stopLocationUpdates();
      _timer?.cancel();

      // Calculate total hours
      if (_clockOutTime.value != null) {
        final difference = _clockOutTime.value!.difference(_clockInTime.value);
        _totalHours.value = difference.inMinutes / 60;
        _formattedTimer.value = TimeUtils.formatDuration(difference);
      }

      // Show notification
      Get.snackbar(
        'Auto Clock-Out',
        'You have been automatically clocked out for the day.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange,
        duration: const Duration(seconds: 5),
      );

      // Update statistics
      await loadStatistics();
    } catch (e) {
      debugPrint('Auto clock-out failed: $e');
    }
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

        // Convert clock-out time from UTC to IST for display
        _clockOutTime.value = TimeUtils.toIST(response.clockOutTime!);
        _isClockedIn.value = false;

        // Save state
        await storage.write('is_clocked_in', false);
        await storage.write(
            'clock_out_time', _clockOutTime.value?.toIso8601String());

        LocationService.stopLocationUpdates();
        _timer?.cancel();
        _autoClockOutTimer?.cancel();

        // Update the timer display
        if (_clockOutTime.value != null) {
          final difference =
              _clockOutTime.value!.difference(_clockInTime.value);
          _formattedTimer.value = TimeUtils.formatDuration(difference);
          _totalHours.value = difference.inMinutes / 60;
        }
      } else {
        // Clock In
        final response = await _repository.clockIn(
          workFromHome: _isWfhMode.value,
          latitude: location['latitude']!,
          longitude: location['longitude']!,
        );

        // Convert clock-in time from UTC to IST for display
        _clockInTime.value = TimeUtils.toIST(response.clockInTime);
        _clockOutTime.value = null;
        _isClockedIn.value = true;

        // Save state
        await storage.write('is_clocked_in', true);
        await storage.write(
            'clock_in_time', _clockInTime.value.toIso8601String());
        await storage.remove('clock_out_time');

        LocationService.startLocationUpdates();
        _startTimer();
        _setupAutoClockOutTimer();
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
}