import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:location/location.dart';

/// A service that handles both timer functionality and location tracking
/// in the background to reduce main thread load and UI blocking.
class BackgroundService {
  // Isolate communication
  static const String _isolateName = 'backgroundServiceIsolate';
  static const String _periodicUpdateChannel = 'periodicUpdate';
  static SendPort? _uiSendPort;

  // Storage keys
  static const String _clockInTimeKey = 'clock_in_timestamp';
  static const String _isRunningKey = 'timer_is_running';
  static const String _isWfhModeKey = 'is_wfh_mode';
  static const String _lastLatitudeKey = 'last_latitude';
  static const String _lastLongitudeKey = 'last_longitude';
  static const String _formattedTimeKey = 'formatted_time';

  // GetStorage instance
  static late final GetStorage _storage;

  // In-memory state and cache
  static bool _initialized = false;
  static bool _isolateRunning = false;
  static Timer? _mainThreadTimer;
  static Map<String, dynamic> _memoryCache = {};

  // Callbacks
  static Function(String)? onTimerUpdate;
  static Function(double, double)? onLocationUpdate;

  static void startLocationUpdates() {
    LocationService.startTracking(
        highFrequency: true, updateInterval: const Duration(hours: 1));
  }

  /// Initialize the background service
  static Future<void> initialize() async {
    if (_initialized) return;

    debugPrint('🔄 Initializing background service');

    try {
      // Initialize GetStorage
      await GetStorage.init('background_service');
      _storage = GetStorage('background_service');

      // Set up communication channel
      final ReceivePort receivePort = ReceivePort();
      if (IsolateNameServer.lookupPortByName(_isolateName) != null) {
        IsolateNameServer.removePortNameMapping(_isolateName);
      }
      IsolateNameServer.registerPortWithName(
          receivePort.sendPort, _isolateName);

      // Listen for messages from the isolate
      receivePort.listen(_handleIsolateMessage);

      _initialized = true;

      // Check if timer should be running based on saved state
      final isRunning = _storage.read(_isRunningKey) ?? false;
      if (isRunning) {
        _startMainThreadTimer();
      }

      debugPrint('✅ Background service initialized with GetStorage');
    } catch (e) {
      debugPrint('⚠️ Error initializing background service: $e');
    }
  }

  /// Start the timer service
  static Future<void> startTimer({bool isWfh = false}) async {
    final now = DateTime.now();
    final timeString = now.toIso8601String();

    // Store in memory cache first
    _memoryCache[_clockInTimeKey] = timeString;
    _memoryCache[_isRunningKey] = true;
    _memoryCache[_isWfhModeKey] = isWfh;

    // Save to GetStorage
    try {
      _storage.write(_clockInTimeKey, timeString);
      _storage.write(_isRunningKey, true);
      _storage.write(_isWfhModeKey, isWfh);
    } catch (e) {
      debugPrint('⚠️ Error saving timer state to GetStorage: $e');
    }

    // Start timer on main thread for immediate UI updates
    _startMainThreadTimer();

    debugPrint('▶️ Timer started at $timeString, WFH mode: $isWfh');
  }

  /// Stop the timer
  static Future<void> stopTimer() async {
    // Update memory cache
    _memoryCache[_isRunningKey] = false;

    // Update GetStorage
    try {
      _storage.write(_isRunningKey, false);
    } catch (e) {
      debugPrint('⚠️ Error saving timer state to GetStorage: $e');
    }

    // Stop main thread timer
    _mainThreadTimer?.cancel();
    _mainThreadTimer = null;

    debugPrint('⏹️ Timer stopped');
  }

  /// Check if the timer is running
  static bool isTimerRunning() {
    // Check memory cache first
    if (_memoryCache.containsKey(_isRunningKey)) {
      return _memoryCache[_isRunningKey] as bool;
    }

    // Read from GetStorage if not in cache
    try {
      final isRunning = _storage.read(_isRunningKey) ?? false;
      _memoryCache[_isRunningKey] = isRunning; // Update cache
      return isRunning;
    } catch (e) {
      debugPrint('⚠️ Error checking timer status: $e');
    }

    return false;
  }

  /// Get WFH mode status
  static bool isWfhMode() {
    // Check memory cache first
    if (_memoryCache.containsKey(_isWfhModeKey)) {
      return _memoryCache[_isWfhModeKey] as bool;
    }

    // Read from GetStorage if not in cache
    try {
      final isWfh = _storage.read(_isWfhModeKey) ?? false;
      _memoryCache[_isWfhModeKey] = isWfh; // Update cache
      return isWfh;
    } catch (e) {
      debugPrint('⚠️ Error checking WFH mode: $e');
    }

    return false;
  }

  /// Update location in the background
  static Future<void> updateLocation(double latitude, double longitude) async {
    if (latitude == 0.0 && longitude == 0.0) {
      debugPrint('⚠️ Skipping location update with invalid coordinates');
      return;
    }

    // Update memory cache first
    _memoryCache[_lastLatitudeKey] = latitude;
    _memoryCache[_lastLongitudeKey] = longitude;

    // Notify callback
    onLocationUpdate?.call(latitude, longitude);

    // Persist to GetStorage
    try {
      _storage.write(_lastLatitudeKey, latitude);
      _storage.write(_lastLongitudeKey, longitude);
      debugPrint('📍 Location updated: $latitude, $longitude');
    } catch (e) {
      debugPrint('❌ Error saving location to GetStorage: $e');
    }
  }

  /// Get the last saved location
  static Map<String, double> getLastLocation() {
    // Check memory cache first
    final cachedLat = _memoryCache[_lastLatitudeKey] as double?;
    final cachedLng = _memoryCache[_lastLongitudeKey] as double?;

    if (cachedLat != null && cachedLng != null) {
      return {'latitude': cachedLat, 'longitude': cachedLng};
    }

    // Read from GetStorage if not in cache
    try {
      final latitude = _storage.read(_lastLatitudeKey) ?? 0.0;
      final longitude = _storage.read(_lastLongitudeKey) ?? 0.0;

      // Update memory cache
      _memoryCache[_lastLatitudeKey] = latitude;
      _memoryCache[_lastLongitudeKey] = longitude;

      return {'latitude': latitude, 'longitude': longitude};
    } catch (e) {
      debugPrint('❌ Error getting last location from GetStorage: $e');
    }

    return {'latitude': 0.0, 'longitude': 0.0};
  }

  /// Get clock-in time as formatted string (HH:MM)
  static String getClockInTime() {
    // Check memory cache first
    final cachedTime = _memoryCache[_clockInTimeKey] as String?;
    if (cachedTime != null) {
      try {
        final time = DateTime.parse(cachedTime);
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        // Continue to check GetStorage
      }
    }

    // Read from GetStorage if not in cache
    try {
      final timeStr = _storage.read<String>(_clockInTimeKey);
      if (timeStr != null) {
        _memoryCache[_clockInTimeKey] = timeStr; // Update cache

        try {
          final time = DateTime.parse(timeStr);
          return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        } catch (e) {
          debugPrint('⚠️ Error parsing time: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ Error getting clock-in time from GetStorage: $e');
    }

    return '--:--';
  }

  /// Get elapsed time in seconds since clock-in
  static int getElapsedTime() {
    // Check if timer is running
    final isRunning = isTimerRunning();
    if (!isRunning) {
      return 0;
    }

    // Get clock-in time from memory cache first
    final cachedTime = _memoryCache[_clockInTimeKey] as String?;
    if (cachedTime != null) {
      try {
        final clockInTime = DateTime.parse(cachedTime);
        final now = DateTime.now();
        return now.difference(clockInTime).inSeconds;
      } catch (e) {
        // Continue to check GetStorage
      }
    }

    // Read from GetStorage if not in cache
    try {
      final clockInTimeStr = _storage.read<String>(_clockInTimeKey);
      if (clockInTimeStr != null) {
        _memoryCache[_clockInTimeKey] = clockInTimeStr; // Update cache

        try {
          final clockInTime = DateTime.parse(clockInTimeStr);
          final now = DateTime.now();
          return now.difference(clockInTime).inSeconds;
        } catch (e) {
          debugPrint('⚠️ Error calculating elapsed time: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ Error getting elapsed time from GetStorage: $e');
    }

    return 0;
  }

  /// Get formatted timer string (HH:MM:SS)
  static String getFormattedTime() {
    // Check memory cache first
    final cachedFormatted = _memoryCache[_formattedTimeKey] as String?;
    if (cachedFormatted != null) {
      return cachedFormatted;
    }

    final seconds = getElapsedTime();
    final formatted = formatElapsedTime(seconds);

    // Update memory cache
    _memoryCache[_formattedTimeKey] = formatted;

    return formatted;
  }

  /// Format seconds into HH:MM:SS
  static String formatElapsedTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  /// Start a timer on the main thread for immediate UI updates
  static void _startMainThreadTimer() {
    // Cancel any existing timer
    _mainThreadTimer?.cancel();

    // Update immediately
    _updateTimerDisplay();

    // Set up periodic updates every second
    _mainThreadTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimerDisplay();
    });

    debugPrint('🔄 Main thread timer started');
  }

  /// Update timer display value
  static void _updateTimerDisplay() {
    final seconds = getElapsedTime();
    final formatted = formatElapsedTime(seconds);

    // Save in memory cache
    _memoryCache[_formattedTimeKey] = formatted;

    // Save in GetStorage
    try {
      _storage.write(_formattedTimeKey, formatted);
    } catch (e) {
      debugPrint('⚠️ Error saving formatted time to GetStorage: $e');
    }

    // Notify callback if registered
    onTimerUpdate?.call(formatted);
  }

  /// Handle messages from background isolate
  static void _handleIsolateMessage(dynamic message) {
    if (message is Map<String, dynamic>) {
      if (message['channel'] == _periodicUpdateChannel) {
        // Handle periodic updates from isolate if needed
      }
    }
  }
}

/// A service specifically for location tracking that minimizes battery usage
class LocationService {
  static final Location _location = Location();
  static Timer? _locationUpdateTimer;
  static bool _isTracking = false;
  static bool _isInitialized = false;

  /// Initialize location service and request permissions
  static Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Check if location service is enabled
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          debugPrint('⚠️ Location service is disabled');
          return false;
        }
      }

      // Check location permission
      PermissionStatus permissionStatus = await _location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await _location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          debugPrint('⚠️ Location permission denied');
          return false;
        }
      }

      // Configure location settings for battery efficiency
      await _location.changeSettings(
        accuracy: LocationAccuracy.balanced,
        interval: 10000, // 10 seconds
        distanceFilter: 10, // 10 meters
      );

      _isInitialized = true;
      debugPrint('✅ Location service initialized');
      return true;
    } catch (e) {
      debugPrint('❌ Error initializing location service: $e');
      return false;
    }
  }

  /// Start tracking location with optimized frequency
  static Future<void> startTracking({
    bool highFrequency = false,
    Duration? updateInterval,
  }) async {
    // Stop any existing tracking first
    stopTracking();

    try {
      await initialize();

      // Get initial location
      await getCurrentLocation();

      // Set update interval - default to hourly
      final interval = updateInterval ?? const Duration(hours: 1);

      _locationUpdateTimer = Timer.periodic(interval, (_) async {
        await getCurrentLocation();
      });

      _isTracking = true;
      debugPrint(
          '🔄 Location tracking started (interval: ${interval.inMinutes} minutes)');
    } catch (e) {
      debugPrint('❌ Error starting location tracking: $e');
    }
  }

  /// Stop tracking location
  static void stopTracking() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    _isTracking = false;
    debugPrint('⏹️ Location tracking stopped');
  }

  /// Get current location with timeout protection
  static Future<Map<String, double>> getCurrentLocation() async {
    try {
      // Set a timeout for the location request
      final locationData = await _location
          .getLocation()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Location request timed out');
      });

      if (locationData.latitude != null && locationData.longitude != null) {
        // Update the location in background service
        await BackgroundService.updateLocation(
            locationData.latitude!, locationData.longitude!);

        return {
          'latitude': locationData.latitude!,
          'longitude': locationData.longitude!,
        };
      }
    } catch (e) {
      debugPrint('❌ Error getting current location: $e');
    }

    // Return cached location if available
    return BackgroundService.getLastLocation();
  }
}
