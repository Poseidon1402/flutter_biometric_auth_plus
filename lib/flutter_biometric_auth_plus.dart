/// Advanced Android Biometric Authentication Plugin
///
/// This plugin provides comprehensive support for Android's BiometricPrompt API,
/// including fingerprint, face, iris recognition, and device credential authentication.
library flutter_biometric_auth_plus;

import 'flutter_biometric_auth_plus_platform_interface.dart';

export 'src/models/biometric_auth_result.dart';
export 'src/models/biometric_type.dart';
export 'src/models/biometric_strength.dart';
export 'src/models/authentication_options.dart';
export 'src/widgets.dart';

/// Main class for handling biometric authentication on Android devices
class FlutterBiometricAuthPlus {
  /// Check if biometric hardware is available on the device
  Future<bool> canCheckBiometrics() {
    return FlutterBiometricAuthPlusPlatform.instance.canCheckBiometrics();
  }

  /// Get list of available biometric types on the device
  /// Returns a list of [BiometricType] (fingerprint, face, iris)
  Future<List<String>> getAvailableBiometrics() {
    return FlutterBiometricAuthPlusPlatform.instance.getAvailableBiometrics();
  }

  /// Check if device has enrolled biometrics
  /// This checks if the user has registered at least one biometric
  Future<bool> hasEnrolledBiometrics() {
    return FlutterBiometricAuthPlusPlatform.instance.hasEnrolledBiometrics();
  }

  /// Check if device supports strong biometric authentication
  /// Strong biometrics: Fingerprint, Iris, Face (Class 3)
  Future<bool> canAuthenticateWithBiometricsStrong() {
    return FlutterBiometricAuthPlusPlatform.instance.canAuthenticateWithBiometricsStrong();
  }

  /// Check if device supports weak biometric authentication
  /// Weak biometrics: Face, Iris (Class 2)
  Future<bool> canAuthenticateWithBiometricsWeak() {
    return FlutterBiometricAuthPlusPlatform.instance.canAuthenticateWithBiometricsWeak();
  }

  /// Check if device credentials (PIN, Pattern, Password) are enrolled
  Future<bool> canAuthenticateWithDeviceCredential() {
    return FlutterBiometricAuthPlusPlatform.instance.canAuthenticateWithDeviceCredential();
  }

  /// Authenticate using biometrics or device credentials
  ///
  /// [options] - Authentication configuration including:
  ///   - title: Dialog title
  ///   - subtitle: Dialog subtitle (optional)
  ///   - description: Dialog description (optional)
  ///   - negativeButtonText: Cancel button text
  ///   - confirmationRequired: Require explicit user confirmation
  ///   - allowDeviceCredential: Allow PIN/Pattern/Password as fallback
  ///   - biometricStrength: Required biometric strength (strong/weak)
  ///
  /// Returns [BiometricAuthResult] with authentication status and details
  Future<Map<String, dynamic>> authenticate({
    required String title,
    String? subtitle,
    String? description,
    String negativeButtonText = 'Cancel',
    bool confirmationRequired = false,
    bool allowDeviceCredential = false,
    String biometricStrength = 'strong',
  }) {
    return FlutterBiometricAuthPlusPlatform.instance.authenticate(
      title: title,
      subtitle: subtitle,
      description: description,
      negativeButtonText: negativeButtonText,
      confirmationRequired: confirmationRequired,
      allowDeviceCredential: allowDeviceCredential,
      biometricStrength: biometricStrength,
    );
  }

  /// Get detailed information about device biometric capabilities
  /// Returns information about hardware, enrolled biometrics, and security level
  Future<Map<String, dynamic>> getBiometricInfo() {
    return FlutterBiometricAuthPlusPlatform.instance.getBiometricInfo();
  }

  /// Stop listening to authentication (cancel current authentication)
  Future<void> cancelAuthentication() {
    return FlutterBiometricAuthPlusPlatform.instance.cancelAuthentication();
  }

  @Deprecated('Use getBiometricInfo() instead')
  Future<String?> getPlatformVersion() {
    return FlutterBiometricAuthPlusPlatform.instance.getPlatformVersion();
  }
}
