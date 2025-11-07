import 'package:flutter_test/flutter_test.dart';
import 'package:biometric_auth_advanced/biometric_auth_advanced.dart';
import 'package:biometric_auth_advanced/biometric_auth_advanced_platform_interface.dart';
import 'package:biometric_auth_advanced/biometric_auth_advanced_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBiometricAuthAdvancedPlatform
    with MockPlatformInterfaceMixin
    implements BiometricAuthAdvancedPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> canCheckBiometrics() => Future.value(false);

  @override
  Future<List<String>> getAvailableBiometrics() => Future.value(<String>[]);

  @override
  Future<bool> hasEnrolledBiometrics() => Future.value(false);

  @override
  Future<bool> canAuthenticateWithBiometricsStrong() => Future.value(false);

  @override
  Future<bool> canAuthenticateWithBiometricsWeak() => Future.value(false);

  @override
  Future<bool> canAuthenticateWithDeviceCredential() => Future.value(false);

  @override
  Future<Map<String, dynamic>> authenticate({
    required String title,
    String? subtitle,
    String? description,
    String negativeButtonText = 'Cancel',
    bool confirmationRequired = false,
    bool allowDeviceCredential = false,
    String biometricStrength = 'strong',
  }) => Future.value(<String, dynamic>{});

  @override
  Future<Map<String, dynamic>> getBiometricInfo() => Future.value(<String, dynamic>{});

  @override
  Future<void> cancelAuthentication() => Future.value();
}

void main() {
  final BiometricAuthAdvancedPlatform initialPlatform = BiometricAuthAdvancedPlatform.instance;

  test('MethodChannelBiometricAuthAdvanced is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBiometricAuthAdvanced>());
  });

  test('getPlatformVersion', () async {
    BiometricAuthAdvanced biometricAuthAdvancedPlugin = BiometricAuthAdvanced();
    MockBiometricAuthAdvancedPlatform fakePlatform = MockBiometricAuthAdvancedPlatform();
    BiometricAuthAdvancedPlatform.instance = fakePlatform;

    expect(await biometricAuthAdvancedPlugin.getPlatformVersion(), '42');
  });
}
