import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'biometric_auth_advanced_method_channel.dart';

abstract class BiometricAuthAdvancedPlatform extends PlatformInterface {
  /// Constructs a BiometricAuthAdvancedPlatform.
  BiometricAuthAdvancedPlatform() : super(token: _token);

  static final Object _token = Object();

  static BiometricAuthAdvancedPlatform _instance = MethodChannelBiometricAuthAdvanced();

  /// The default instance of [BiometricAuthAdvancedPlatform] to use.
  ///
  /// Defaults to [MethodChannelBiometricAuthAdvanced].
  static BiometricAuthAdvancedPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BiometricAuthAdvancedPlatform] when
  /// they register themselves.
  static set instance(BiometricAuthAdvancedPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Check if biometric hardware is available on the device
  Future<bool> canCheckBiometrics() {
    throw UnimplementedError('canCheckBiometrics() has not been implemented.');
  }

  /// Get list of available biometric types on the device
  Future<List<String>> getAvailableBiometrics() {
    throw UnimplementedError('getAvailableBiometrics() has not been implemented.');
  }

  /// Check if device has enrolled biometrics
  Future<bool> hasEnrolledBiometrics() {
    throw UnimplementedError('hasEnrolledBiometrics() has not been implemented.');
  }

  /// Check if device supports strong biometric authentication
  Future<bool> canAuthenticateWithBiometricsStrong() {
    throw UnimplementedError('canAuthenticateWithBiometricsStrong() has not been implemented.');
  }

  /// Check if device supports weak biometric authentication
  Future<bool> canAuthenticateWithBiometricsWeak() {
    throw UnimplementedError('canAuthenticateWithBiometricsWeak() has not been implemented.');
  }

  /// Check if device credentials are enrolled
  Future<bool> canAuthenticateWithDeviceCredential() {
    throw UnimplementedError('canAuthenticateWithDeviceCredential() has not been implemented.');
  }

  /// Authenticate using biometrics or device credentials
  Future<Map<String, dynamic>> authenticate({
    required String title,
    String? subtitle,
    String? description,
    String negativeButtonText = 'Cancel',
    bool confirmationRequired = false,
    bool allowDeviceCredential = false,
    String biometricStrength = 'strong',
  }) {
    throw UnimplementedError('authenticate() has not been implemented.');
  }

  /// Get detailed information about device biometric capabilities
  Future<Map<String, dynamic>> getBiometricInfo() {
    throw UnimplementedError('getBiometricInfo() has not been implemented.');
  }

  /// Cancel current authentication
  Future<void> cancelAuthentication() {
    throw UnimplementedError('cancelAuthentication() has not been implemented.');
  }
}
