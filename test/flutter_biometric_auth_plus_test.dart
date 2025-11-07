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
}

void main() {
  final BiometricAuthAdvancedPlatform initialPlatform = BiometricAuthAdvancedPlatform.instance;

  test('$MethodChannelBiometricAuthAdvanced is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBiometricAuthAdvanced>());
  });

  test('getPlatformVersion', () async {
    BiometricAuthAdvanced biometricAuthAdvancedPlugin = BiometricAuthAdvanced();
    MockBiometricAuthAdvancedPlatform fakePlatform = MockBiometricAuthAdvancedPlatform();
    BiometricAuthAdvancedPlatform.instance = fakePlatform;

    expect(await biometricAuthAdvancedPlugin.getPlatformVersion(), '42');
  });
}
