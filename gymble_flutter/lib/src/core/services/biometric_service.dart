import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    // Skip biometric check on web platform
    if (kIsWeb) {
      return false;
    }
    
    try {
      // Check if device supports biometric authentication
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (_) {
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    // Skip on web platform
    if (kIsWeb) {
      return [];
    }
    
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (_) {
      return [];
    }
  }

  // Authenticate with biometrics
  Future<bool> authenticate() async {
    // Skip on web platform
    if (kIsWeb) {
      return false;
    }
    
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (_) {
      return false;
    }
  }

  // Check if Face ID is available
  Future<bool> isFaceIdAvailable() async {
    // Skip on web platform
    if (kIsWeb) {
      return false;
    }
    
    try {
      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.contains(BiometricType.face);
    } catch (_) {
      return false;
    }
  }

  // Check if Touch ID/Fingerprint is available
  Future<bool> isTouchIdAvailable() async {
    // Skip on web platform
    if (kIsWeb) {
      return false;
    }
    
    try {
      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.contains(BiometricType.fingerprint) || 
             availableBiometrics.contains(BiometricType.strong) || 
             availableBiometrics.contains(BiometricType.weak);
    } catch (_) {
      return false;
    }
  }

  // Get biometric type name (Face ID or Touch ID)
  Future<String> getBiometricTypeName() async {
    if (await isFaceIdAvailable()) {
      return 'Face ID';
    } else if (await isTouchIdAvailable()) {
      return 'Touch ID';
    } else {
      return 'Biometric';
    }
  }
}