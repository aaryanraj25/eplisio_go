import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class BackgroundService {
  // Constants
  static const String _isolateName = 'backgroundServiceIsolate';
  static const String _periodicUpdateChannel = 'periodicUpdate';
  
  // Storage keys
  static const String _clockInTimeKey = 'clock_in_timestamp';
  static const String _clockOutTimeKey = 'clock_out_timestamp';
  static const String _isRunningKey = 'timer_is_running';
  static const String _isWfhModeKey = 'is_wfh_mode';
  static const String _lastLatitudeKey = 'last_latitude';
  static const String _lastLongitudeKey = 'last_longitude';
  static const String _formattedTimeKey = 'formatted_time';
  static const String _lastLocationUpdateTimeKey = 'last_location_update_time';

  // State management
  static late final GetStorage _storage;
  static bool _initialized = false;
  static bool _isolateRunning = false;
  static Timer? _mainThreadTimer;
  static Timer? _locationUpdateTimer;
  static Map<String, dynamic> _memoryCache = {};
  static SendPort? _uiSendPort;

  // Location service
  static final Location _location = Location();

  // Callbacks
  static Function(String)? onTimerUpdate;
  static Function(double, double)? onLocationUpdate;
  
  // Location update callback - you'll implement this in repository
  static Future<void> Function(double, double)? onLocationUpdateToServer;

  /// Initialize the background service
  static Future<void> initialize() async {
    if (_initialized) return;

    debugPrint('🔄 Initializing background service');

    try {
      // Initialize GetStorage
      await GetStorage.init('background_service');
      _storage = GetStorage('background_service');

      // Initialize location service
      await _initializeLocationService();

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
        _startLocationUpdateTimer();
      }

      debugPrint('✅ Background service initialized');
    } catch (e) {
      debugPrint('⚠️ Error initializing background service: $e');
    }
  }

  /// Initialize location service
  static Future<void> _initializeLocationService() async {
    try {
      bool serviceEnabled;
      PermissionStatus permissionStatus;

      // Check if location service is enabled
      serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          debugPrint('⚠️ Location service not enabled');
          return;
        }
      }

      // Check location permission
      permissionStatus = await _location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await _location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          debugPrint('⚠️ Location permission not granted');
          return;
        }
      }

      // Configure location settings
      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 10000, // 10 seconds
        distanceFilter: 10, // 10 meters
      );

      debugPrint('✅ Location service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing location service: $e');
    }
  }

  /// Start the timer service
  static Future<void> startTimer({bool isWfh = false}) async {
    final now = DateTime.now();
    final timeString = now.toIso8601String();

    // Store in memory cache
    _memoryCache[_clockInTimeKey] = timeString;
    _memoryCache[_clockOutTimeKey] = null;
    _memoryCache[_isRunningKey] = true;
    _memoryCache[_isWfhModeKey] = isWfh;

    // Save to GetStorage
    try {
      _storage.write(_clockInTimeKey, timeString);
      _storage.write(_clockOutTimeKey, null);
      _storage.write(_isRunningKey, true);
      _storage.write(_isWfhModeKey, isWfh);
    } catch (e) {
      debugPrint('⚠️ Error saving timer state to GetStorage: $e');
    }

    _startMainThreadTimer();
    _startLocationUpdateTimer(); // Start location updates
    
    // Get initial location and update
    if (!isWfh) {
      _updateCurrentLocation();
    }
    
    debugPrint('▶️ Timer started at $timeString, WFH mode: $isWfh');
  }

  /// Stop the timer and record clock out time
  static Future<void> stopTimer() async {
    final now = DateTime.now();
    final timeString = now.toIso8601String();

    // Update memory cache
    _memoryCache[_clockOutTimeKey] = timeString;
    _memoryCache[_isRunningKey] = false;

    // Update GetStorage
    try {
      _storage.write(_clockOutTimeKey, timeString);
      _storage.write(_isRunningKey, false);
    } catch (e) {
      debugPrint('⚠️ Error saving timer state to GetStorage: $e');
    }

    // Stop main thread timer
    _mainThreadTimer?.cancel();
    _mainThreadTimer = null;
    
    // Stop location update timer
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;

    debugPrint('⏹️ Timer stopped at $timeString');
  }

  /// Start a timer to update location every hour
  static void _startLocationUpdateTimer() {
    // Cancel existing timer if any
    _locationUpdateTimer?.cancel();
    
    // Check if WFH mode is enabled
    final isWfh = isWfhMode();
    if (isWfh) {
      debugPrint('🏠 WFH mode is enabled, skipping location updates');
      return;
    }
    
    // First update immediately
    _updateCurrentLocation();
    
    // Then schedule hourly updates
    // Using 1 hour interval (3600 seconds)
    _locationUpdateTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _updateCurrentLocation();
    });
    
    debugPrint('📍 Location update timer started with 1 hour interval');
  }
  
  /// Get and update the current location
  static Future<void> _updateCurrentLocation() async {
    try {
      // Check if timer is still running
      if (!isTimerRunning()) {
        _locationUpdateTimer?.cancel();
        return;
      }
      
      // Check if WFH mode is enabled
      if (isWfhMode()) {
        return;
      }
      
      // Get current location
      final locationData = await _location.getLocation();
      
      if (locationData.latitude != null && locationData.longitude != null) {
        final now = DateTime.now().toIso8601String();
        
        // Update in memory cache
        _memoryCache[_lastLatitudeKey] = locationData.latitude;
        _memoryCache[_lastLongitudeKey] = locationData.longitude;
        _memoryCache[_lastLocationUpdateTimeKey] = now;
        
        // Update in storage
        _storage.write(_lastLatitudeKey, locationData.latitude);
        _storage.write(_lastLongitudeKey, locationData.longitude);
        _storage.write(_lastLocationUpdateTimeKey, now);
        
        // Notify through callback
        onLocationUpdate?.call(
          locationData.latitude!,
          locationData.longitude!,
        );
        
        // Send to server if callback is registered
        if (onLocationUpdateToServer != null) {
          await onLocationUpdateToServer!(
            locationData.latitude!,
            locationData.longitude!,
          );
          debugPrint('📤 Location sent to server: ${locationData.latitude}, ${locationData.longitude}');
        }
        
        debugPrint('📍 Location updated: ${locationData.latitude}, ${locationData.longitude}');
      }
    } catch (e) {
      debugPrint('❌ Error updating location: $e');
    }
  }

  /// Get clock-in time as formatted string (HH:mm)
  static String getClockInTime() {
    final cachedTime = _memoryCache[_clockInTimeKey] as String?;
    if (cachedTime != null) {
      try {
        final time = DateTime.parse(cachedTime).toLocal();
        return DateFormat('HH:mm').format(time);
      } catch (e) {
        // Continue to check GetStorage
      }
    }

    try {
      final timeStr = _storage.read<String>(_clockInTimeKey);
      if (timeStr != null) {
        _memoryCache[_clockInTimeKey] = timeStr;
        try {
          final time = DateTime.parse(timeStr).toLocal();
          return DateFormat('HH:mm').format(time);
        } catch (e) {
          debugPrint('⚠️ Error parsing clock-in time: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ Error getting clock-in time from GetStorage: $e');
    }

    return '--:--';
  }

  /// Get clock-out time as formatted string (HH:mm)
  static String getClockOutTime() {
    final cachedTime = _memoryCache[_clockOutTimeKey] as String?;
    if (cachedTime != null) {
      try {
        final time = DateTime.parse(cachedTime).toLocal();
        return DateFormat('HH:mm').format(time);
      } catch (e) {
        // Continue to check GetStorage
      }
    }

    try {
      final timeStr = _storage.read<String>(_clockOutTimeKey);
      if (timeStr != null) {
        _memoryCache[_clockOutTimeKey] = timeStr;
        try {
          final time = DateTime.parse(timeStr).toLocal();
          return DateFormat('HH:mm').format(time);
        } catch (e) {
          debugPrint('⚠️ Error parsing clock-out time: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ Error getting clock-out time from GetStorage: $e');
    }

    return '--:--';
  }

  /// Get elapsed time in seconds since clock-in
  static int getElapsedTime() {
    final isRunning = isTimerRunning();
    if (!isRunning) return 0;

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

    try {
      final clockInTimeStr = _storage.read<String>(_clockInTimeKey);
      if (clockInTimeStr != null) {
        _memoryCache[_clockInTimeKey] = clockInTimeStr;
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

  /// Format seconds into HH:MM:SS
  static String formatElapsedTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  /// Get formatted timer string (HH:MM:SS)
  static String getFormattedTime() {
    final cachedFormatted = _memoryCache[_formattedTimeKey] as String?;
    if (cachedFormatted != null) {
      return cachedFormatted;
    }

    final seconds = getElapsedTime();
    final formatted = formatElapsedTime(seconds);

    _memoryCache[_formattedTimeKey] = formatted;
    return formatted;
  }

  /// Check if the timer is running
  static bool isTimerRunning() {
    if (_memoryCache.containsKey(_isRunningKey)) {
      return _memoryCache[_isRunningKey] as bool;
    }

    try {
      final isRunning = _storage.read(_isRunningKey) ?? false;
      _memoryCache[_isRunningKey] = isRunning;
      return isRunning;
    } catch (e) {
      debugPrint('⚠️ Error checking timer status: $e');
    }

    return false;
  }

  /// Get WFH mode status
  static bool isWfhMode() {
    if (_memoryCache.containsKey(_isWfhModeKey)) {
      return _memoryCache[_isWfhModeKey] as bool;
    }

    try {
      final isWfh = _storage.read(_isWfhModeKey) ?? false;
      _memoryCache[_isWfhModeKey] = isWfh;
      return isWfh;
    } catch (e) {
      debugPrint('⚠️ Error checking WFH mode: $e');
    }

    return false;
  }

  /// Start a timer on the main thread for immediate UI updates
  static void _startMainThreadTimer() {
    _mainThreadTimer?.cancel();
    _updateTimerDisplay();

    _mainThreadTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimerDisplay();
    });

    debugPrint('🔄 Main thread timer started');
  }

  /// Update timer display value
  static void _updateTimerDisplay() {
    final seconds = getElapsedTime();
    final formatted = formatElapsedTime(seconds);

    _memoryCache[_formattedTimeKey] = formatted;

    try {
      _storage.write(_formattedTimeKey, formatted);
    } catch (e) {
      debugPrint('⚠️ Error saving formatted time to GetStorage: $e');
    }

    onTimerUpdate?.call(formatted);
  }

  /// Handle messages from background isolate
  static void _handleIsolateMessage(dynamic message) {
    if (message is Map<String, dynamic>) {
      if (message['channel'] == _periodicUpdateChannel) {
        // Handle periodic updates from isolate
        final time = message['time'] as String?;
        if (time != null) {
          onTimerUpdate?.call(time);
        }
      }
    }
  }

  /// Update location manually (can be called from outside)
  static Future<void> updateLocation(double latitude, double longitude) async {
    if (latitude == 0.0 && longitude == 0.0) {
      debugPrint('⚠️ Skipping location update with invalid coordinates');
      return;
    }

    _memoryCache[_lastLatitudeKey] = latitude;
    _memoryCache[_lastLongitudeKey] = longitude;
    _memoryCache[_lastLocationUpdateTimeKey] = DateTime.now().toIso8601String();

    onLocationUpdate?.call(latitude, longitude);

    // Also call server update if available
    if (onLocationUpdateToServer != null) {
      await onLocationUpdateToServer!(latitude, longitude);
    }

    try {
      _storage.write(_lastLatitudeKey, latitude);
      _storage.write(_lastLongitudeKey, longitude);
      _storage.write(_lastLocationUpdateTimeKey, DateTime.now().toIso8601String());
      debugPrint('📍 Location manually updated: $latitude, $longitude');
    } catch (e) {
      debugPrint('❌ Error saving location to GetStorage: $e');
    }
  }

  /// Get the last saved location
  static Map<String, double> getLastLocation() {
    final cachedLat = _memoryCache[_lastLatitudeKey] as double?;
    final cachedLng = _memoryCache[_lastLongitudeKey] as double?;

    if (cachedLat != null && cachedLng != null) {
      return {'latitude': cachedLat, 'longitude': cachedLng};
    }

    try {
      final latitude = _storage.read(_lastLatitudeKey) ?? 0.0;
      final longitude = _storage.read(_lastLongitudeKey) ?? 0.0;

      _memoryCache[_lastLatitudeKey] = latitude;
      _memoryCache[_lastLongitudeKey] = longitude;

      return {'latitude': latitude, 'longitude': longitude};
    } catch (e) {
      debugPrint('❌ Error getting last location from GetStorage: $e');
    }

    return {'latitude': 0.0, 'longitude': 0.0};
  }
  
  /// Get time of last location update
  static DateTime? getLastLocationUpdateTime() {
    final cachedTime = _memoryCache[_lastLocationUpdateTimeKey] as String?;
    if (cachedTime != null) {
      try {
        return DateTime.parse(cachedTime);
      } catch (e) {
        // Continue to check GetStorage
      }
    }

    try {
      final timeStr = _storage.read<String>(_lastLocationUpdateTimeKey);
      if (timeStr != null) {
        _memoryCache[_lastLocationUpdateTimeKey] = timeStr;
        try {
          return DateTime.parse(timeStr);
        } catch (e) {
          debugPrint('⚠️ Error parsing last location update time: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ Error getting last location update time from storage: $e');
    }

    return null;
  }
  
  /// Register location update to server callback
  static void registerLocationUpdateCallback(Future<void> Function(double, double) callback) {
    onLocationUpdateToServer = callback;
    debugPrint('✅ Location update to server callback registered');
  }
}