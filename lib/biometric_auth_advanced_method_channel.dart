import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'biometric_auth_advanced_platform_interface.dart';

/// An implementation of [BiometricAuthAdvancedPlatform] that uses method channels.
class MethodChannelBiometricAuthAdvanced extends BiometricAuthAdvancedPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('biometric_auth_advanced');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> canCheckBiometrics() async {
    final result = await methodChannel.invokeMethod<bool>('canCheckBiometrics');
    return result ?? false;
  }

  @override
  Future<List<String>> getAvailableBiometrics() async {
    final result = await methodChannel.invokeMethod<List>('getAvailableBiometrics');
    return result?.cast<String>() ?? [];
  }

  @override
  Future<bool> hasEnrolledBiometrics() async {
    final result = await methodChannel.invokeMethod<bool>('hasEnrolledBiometrics');
    return result ?? false;
  }

  @override
  Future<bool> canAuthenticateWithBiometricsStrong() async {
    final result = await methodChannel.invokeMethod<bool>('canAuthenticateWithBiometricsStrong');
    return result ?? false;
  }

  @override
  Future<bool> canAuthenticateWithBiometricsWeak() async {
    final result = await methodChannel.invokeMethod<bool>('canAuthenticateWithBiometricsWeak');
    return result ?? false;
  }

  @override
  Future<bool> canAuthenticateWithDeviceCredential() async {
    final result = await methodChannel.invokeMethod<bool>('canAuthenticateWithDeviceCredential');
    return result ?? false;
  }

  @override
  Future<Map<String, dynamic>> authenticate({
    required String title,
    String? subtitle,
    String? description,
    String negativeButtonText = 'Cancel',
    bool confirmationRequired = false,
    bool allowDeviceCredential = false,
    String biometricStrength = 'strong',
  }) async {
    final args = <String, dynamic>{
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'negativeButtonText': negativeButtonText,
      'confirmationRequired': confirmationRequired,
      'allowDeviceCredential': allowDeviceCredential,
      'biometricStrength': biometricStrength,
    };

    final result = await methodChannel.invokeMethod<Map>('authenticate', args);
    return Map<String, dynamic>.from(result ?? {});
  }

  @override
  Future<Map<String, dynamic>> getBiometricInfo() async {
    final result = await methodChannel.invokeMethod<Map>('getBiometricInfo');
    return Map<String, dynamic>.from(result ?? {});
  }

  @override
  Future<void> cancelAuthentication() async {
    await methodChannel.invokeMethod<void>('cancelAuthentication');
  }
}
