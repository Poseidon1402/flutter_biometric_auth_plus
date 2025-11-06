import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_biometric_auth_plus/flutter_biometric_auth_plus.dart';
import 'package:flutter_biometric_auth_plus/flutter_biometric_auth_plus_platform_interface.dart';
import 'package:flutter_biometric_auth_plus/flutter_biometric_auth_plus_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterBiometricAuthPlusPlatform
    with MockPlatformInterfaceMixin
    implements FlutterBiometricAuthPlusPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterBiometricAuthPlusPlatform initialPlatform = FlutterBiometricAuthPlusPlatform.instance;

  test('$MethodChannelFlutterBiometricAuthPlus is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterBiometricAuthPlus>());
  });

  test('getPlatformVersion', () async {
    FlutterBiometricAuthPlus flutterBiometricAuthPlusPlugin = FlutterBiometricAuthPlus();
    MockFlutterBiometricAuthPlusPlatform fakePlatform = MockFlutterBiometricAuthPlusPlatform();
    FlutterBiometricAuthPlusPlatform.instance = fakePlatform;

    expect(await flutterBiometricAuthPlusPlugin.getPlatformVersion(), '42');
  });
}
