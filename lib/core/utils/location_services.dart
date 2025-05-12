import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as perm;

class LocationService {
  static final Location _location = Location();
  static Timer? _locationUpdateTimer;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permission using permission_handler
      final status = await perm.Permission.location.request();
      if (!status.isGranted) {
        debugPrint('Location permission denied');
        return;
      }

      // Enable location service if disabled
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          debugPrint('Location service not enabled');
          return;
        }
      }

      // Configure location settings
      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 10000, // 10 seconds
        distanceFilter: 10, // 10 meters
      );

      _isInitialized = true;
      debugPrint('Location service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing location service: $e');
    }
  }

  static Future<Map<String, double>> getCurrentLocation() async {
    try {
      await initialize();

      if (!_isInitialized) {
        throw Exception('Location service not initialized');
      }

      final locationData = await _location.getLocation().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Location request timed out'),
      );

      final latitude = locationData.latitude;
      final longitude = locationData.longitude;

      if (latitude == null || longitude == null) {
        throw Exception('Invalid location data received');
      }

      debugPrint('Location fetched - Lat: $latitude, Long: $longitude');
      return {'latitude': latitude, 'longitude': longitude};
    } catch (e) {
      debugPrint('Error getting location: $e');
      _showErrorDialog(e.toString());
      return {'latitude': 0.0, 'longitude': 0.0};
    }
  }

  static void startLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) async {
        final location = await getCurrentLocation();
        debugPrint('Periodic location update: ${location['latitude']}, ${location['longitude']}');
      },
    );
  }

  static void stopLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }

  static Future<bool> checkLocationPermission() async {
    try {
      final status = await perm.Permission.location.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('Error checking location permission: $e');
      return false;
    }
  }

  static void _showErrorDialog(String error) {
    Get.dialog(
      AlertDialog(
        title: const Text('Location Error'),
        content: Text('Unable to get location:\n$error\n\nPlease check your location settings and permissions.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await perm.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
