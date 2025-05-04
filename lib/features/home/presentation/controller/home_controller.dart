import 'package:eplisio_go/core/utils/services.dart';
import 'package:eplisio_go/features/home/data/repo/home_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';

class HomeController extends GetxController with WidgetsBindingObserver {
  final HomeRepository _repository;

  // Reactive variables - minimal set
  final _isLoading = false.obs;
  final _isClockedIn = false.obs;
  final _clockInTime = RxString('--:--');
  final _clockOutTime = RxString('--:--');
  final _formattedTimer = '00:00:00'.obs;
  final _isWfhMode = false.obs;
  final employeeName = ''.obs;

  // Statistics variables - loaded on demand
  final _statsLoaded = false.obs;
  final _totalSales = 0.obs;
  final _totalVisits = 0.obs;
  final _rank = 0.obs;
  final _totalClients = 0.obs;

  final _locationTrackingActive = false.obs;
  bool get locationTrackingActive => _locationTrackingActive.value;

  // Location variables
  final _currentLatitude = RxDouble(0.0);
  final _currentLongitude = RxDouble(0.0);

  HomeController({required HomeRepository repository})
      : _repository = repository;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isClockedIn => _isClockedIn.value;
  String get clockInTime => _clockInTime.value;
  String get clockOutTime => _clockOutTime.value;
  String get formattedTimer => _formattedTimer.value;
  bool get isWfhMode => _isWfhMode.value;
  bool get statsLoaded => _statsLoaded.value;
  int get totalSales => _totalSales.value;
  int get totalVisits => _totalVisits.value;
  int get rank => _rank.value;
  int get totalClients => _totalClients.value;
  double get currentLatitude => _currentLatitude.value;
  double get currentLongitude => _currentLongitude.value;

  @override
  void onInit() {
    super.onInit();
    // Register with WidgetsBinding to listen for app lifecycle events
    WidgetsBinding.instance.addObserver(this);

    Future.delayed(Duration(milliseconds: 300), () {
      _initializeServices();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes
    if (state == AppLifecycleState.resumed) {
      // App is in the foreground
      // Update location if the user is clocked in and app is brought to foreground
      if (_isClockedIn.value && _locationTrackingActive.value) {
        _updateCurrentLocation();
      }
    }
  }

  Future<void> _updateCurrentLocation() async {
    // Only update location if user is clocked in
    if (!_isClockedIn.value) return;

    try {
      final location = await LocationService.getCurrentLocation();
      _currentLatitude.value = location['latitude'] ?? 0.0;
      _currentLongitude.value = location['longitude'] ?? 0.0;

      // Only send to API if coordinates are valid
      if (_currentLatitude.value != 0.0 && _currentLongitude.value != 0.0) {
        await _repository.updateLocation(
            _currentLatitude.value, _currentLongitude.value);
        debugPrint(
            'Location updated via API: ${_currentLatitude.value}, ${_currentLongitude.value}');
      }
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }

  Future<void> _initializeServices() async {
    // Initialize background services first
    await BackgroundService.initialize();

    // Set up callbacks to update UI when background service sends updates
    BackgroundService.onTimerUpdate = (formattedTime) {
      _formattedTimer.value = formattedTime;
    };

    BackgroundService.onLocationUpdate = (lat, lng) {
      _currentLatitude.value = lat;
      _currentLongitude.value = lng;
    };

    // Load essential data (minimal loading for fast UI rendering)
    await _loadEssentialData();

    // Check if user is clocked in and update location if needed
    if (_isClockedIn.value) {
      _locationTrackingActive.value = true;
      _updateCurrentLocation();
    }
  }

  Future<void> _loadEssentialData() async {
    debugPrint('Loading essential data...');
    try {
      _isLoading.value = true;

      // Load required minimum data in parallel
      await Future.wait([
        _loadUserProfile(),
        _checkClockStatus(),
        _loadInitialLocation(),
      ]);
    } catch (e) {
      debugPrint('Error loading essential data: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Load user profile data (name, etc.)
  Future<void> _loadUserProfile() async {
    try {
      final GetStorage storage = GetStorage();
      final userData = storage.read('employee');

      if (userData != null) {
        final Map<String, dynamic> parsedData =
            userData is String ? jsonDecode(userData) : userData;
        employeeName.value = parsedData['name'] ?? '';
      }
    } catch (e) {
      debugPrint('Error loading employee name: $e');
    }
  }

  // Check if user is clocked in
  Future<void> _checkClockStatus() async {
    try {
      // Get saved clock state
      _isClockedIn.value = await BackgroundService.isTimerRunning();
      _isWfhMode.value = await BackgroundService.isWfhMode();
      _clockInTime.value = await BackgroundService.getClockInTime();
      _clockOutTime.value = _isClockedIn.value ? '--:--' : _clockOutTime.value;

      // Get current timer value
      if (_isClockedIn.value) {
        _formattedTimer.value = await BackgroundService.getFormattedTime();
      }
    } catch (e) {
      debugPrint('Error checking clock status: $e');
    }
  }

  // Load initial location
  Future<void> _loadInitialLocation() async {
    try {
      final location = await BackgroundService.getLastLocation();
      _currentLatitude.value = location['latitude'] ?? 0.0;
      _currentLongitude.value = location['longitude'] ?? 0.0;

      // If no valid location, try to get current
      if (_currentLatitude.value == 0.0 && _currentLongitude.value == 0.0) {
        final currentLocation = await LocationService.getCurrentLocation();
        _currentLatitude.value = currentLocation['latitude'] ?? 0.0;
        _currentLongitude.value = currentLocation['longitude'] ?? 0.0;
      }
    } catch (e) {
      debugPrint('Error loading initial location: $e');
    }
  }

  // Load statistics data (loaded on demand to optimize initial page load)
  Future<void> loadStatistics() async {
    if (_statsLoaded.value) return;

    try {
      _isLoading.value = true;
      final stats = await _repository.getStatistics();

      _totalSales.value = stats.totalSales;
      _totalVisits.value = stats.totalVisits;
      _rank.value = stats.performance.rank;
      _totalClients.value = stats.performance.totalClients;

      _statsLoaded.value = true;
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Toggle WFH mode
  void toggleWfhMode() {
    if (_isClockedIn.value) return; // Cannot change when clocked in
    _isWfhMode.toggle();
  }

  // Handle clock in/out
  Future<void> toggleClockInOut() async {
    if (_isLoading.value) return;

    try {
      _isLoading.value = true;

      // Get current location before clock action
      final location = await LocationService.getCurrentLocation();
      _currentLatitude.value = location['latitude'] ?? 0.0;
      _currentLongitude.value = location['longitude'] ?? 0.0;

      if (_isClockedIn.value) {
        // Clock Out
        final response = await _repository.clockOut(
          latitude: _currentLatitude.value,
          longitude: _currentLongitude.value,
        );

        // Update clock times
        _clockOutTime.value = response.clockOutTime ?? '--:--';
        _isClockedIn.value = false;

        // Stop background timer
        await BackgroundService.stopTimer();
        _formattedTimer.value = '00:00:00';

        // Stop location tracking
        LocationService.stopTracking();
        _locationTrackingActive.value = false;
      } else {
        // Clock In
        final response = await _repository.clockIn(
          workFromHome: _isWfhMode.value,
          latitude: _currentLatitude.value,
          longitude: _currentLongitude.value,
        );

        // Update clock time
        _clockInTime.value = response.clockInTime ?? '--:--';
        _clockOutTime.value = '--:--';
        _isClockedIn.value = true;

        // Start background timer
        await BackgroundService.startTimer(isWfh: _isWfhMode.value);

        // Start location tracking - only while clocked in
        LocationService.startTracking(
            highFrequency: true, updateInterval: const Duration(hours: 1));
        _locationTrackingActive.value = true;
      }
    } catch (e) {
      debugPrint('Error toggling clock: $e');
      Get.snackbar(
        'Error',
        'Failed to ${_isClockedIn.value ? 'clock out' : 'clock in'}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Test location service for debugging
  Future<void> testLocationService() async {
    try {
      _isLoading.value = true;
      Get.snackbar(
        'Location Test',
        'Testing location service...',
        duration: const Duration(seconds: 2),
      );

      final location = await LocationService.getCurrentLocation();
      _currentLatitude.value = location['latitude'] ?? 0.0;
      _currentLongitude.value = location['longitude'] ?? 0.0;

      Get.snackbar(
        'Location Test',
        'Location: ${_currentLatitude.value}, ${_currentLongitude.value}',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Location Test',
        'Error: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Remove the observer when controller is closed
    WidgetsBinding.instance.removeObserver(this);
    LocationService.stopTracking();
    super.onClose();
  }
}
