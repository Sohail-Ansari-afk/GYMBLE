import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

class LocationService {
  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    // Skip on web platform
    if (kIsWeb) {
      return true; // Return true on web to avoid blocking the flow
    }
    return await Geolocator.isLocationServiceEnabled();
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    // Skip on web platform
    if (kIsWeb) {
      return true; // Return true on web to avoid blocking the flow
    }
    
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      return false;
    }

    // Permissions are granted
    return true;
  }

  // Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      // On web, return a mock position with default values
      if (kIsWeb) {
        // Return a mock position with default values
        return Position(
          latitude: 0.0,
          longitude: 0.0,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
      }
      
      final hasPermission = await requestLocationPermission();
      
      if (!hasPermission) {
        return null;
      }
      
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  // Open app settings to enable location permission
  Future<void> openLocationSettings() async {
    // Skip on web platform
    if (kIsWeb) {
      return;
    }
    await Geolocator.openLocationSettings();
  }
  
  // Request location permission via app settings
  Future<bool> requestLocationPermissionViaSettings() async {
    // Skip on web platform
    if (kIsWeb) {
      return true; // Return true on web to avoid blocking the flow
    }
    return await Permission.location.request().isGranted;
  }
}