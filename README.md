# Flutter Biometric Auth Plus 🔐

Advanced Android biometric authentication plugin for Flutter, providing comprehensive support for modern Android security features.

## Features

### 🎯 Complete Biometric Support
- **Fingerprint Recognition** - Universal biometric authentication
- **Face Recognition** - Both 2D and 3D face unlock (device-dependent)
- **Iris Recognition** - Advanced biometric security (Samsung and select devices)
- **Device Credentials** - PIN, Pattern, and Password fallback

### 🔒 Security Levels
- **Strong Biometrics (Class 3)** - Fingerprint, 3D Face, Iris
  - Suitable for cryptographic operations
  - Highest security level
- **Weak Biometrics (Class 2)** - 2D Face unlock
  - Convenience-focused authentication
  - Lower security threshold
- **Device Credential Fallback** - Seamless fallback to PIN/Pattern/Password

### 📱 Modern Android API
- Built on **BiometricPrompt API** (Android 10+)
- Minimum SDK: Android 7.0 (API 24)
- Target SDK: Android 14+ (API 36)
- Full compatibility with modern Android devices

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_biometric_auth_plus: ^1.0.0
```

## Usage

### Import the package

```dart
import 'package:flutter_biometric_auth_plus/flutter_biometric_auth_plus.dart';
```

### Check Device Capabilities

```dart
final biometricAuth = FlutterBiometricAuthPlus();

// Check if device has biometric hardware
bool canCheckBiometrics = await biometricAuth.canCheckBiometrics();

// Check if biometrics are enrolled
bool hasEnrolledBiometrics = await biometricAuth.hasEnrolledBiometrics();

// Check for strong biometric support (Class 3)
bool canUseStrong = await biometricAuth.canAuthenticateWithBiometricsStrong();

// Check for weak biometric support (Class 2)
bool canUseWeak = await biometricAuth.canAuthenticateWithBiometricsWeak();

// Check if device credential is set
bool hasDeviceCredential = await biometricAuth.canAuthenticateWithDeviceCredential();
```

### Get Available Biometric Types

```dart
List<String> availableBiometrics = await biometricAuth.getAvailableBiometrics();
// Returns: ['fingerprint', 'face', 'iris'] based on device capabilities
```

### Get Comprehensive Biometric Information

```dart
Map<String, dynamic> info = await biometricAuth.getBiometricInfo();
print('Has hardware: ${info['hasHardware']}');
print('Enrolled biometrics: ${info['hasEnrolledBiometrics']}');
print('Available types: ${info['availableBiometricTypes']}');
print('Android version: ${info['androidVersion']}');
```

### Authenticate with Strong Biometrics Only

```dart
try {
  final result = await biometricAuth.authenticate(
    title: 'Authenticate',
    subtitle: 'Verify your identity',
    description: 'Place your finger on the sensor',
    negativeButtonText: 'Cancel',
    confirmationRequired: false,
    allowDeviceCredential: false,
    biometricStrength: 'strong', // 'strong', 'weak', or 'any'
  );

  final authResult = BiometricAuthResult.fromMap(result);
  
  if (authResult.success) {
    print('✅ Authentication successful!');
    print('Method: ${authResult.authenticationMethod.name}');
  } else {
    print('❌ Authentication failed: ${authResult.errorMessage}');
  }
} catch (e) {
  print('Error: $e');
}
```

### Authenticate with Device Credential Fallback

```dart
final result = await biometricAuth.authenticate(
  title: 'Secure Login',
  subtitle: 'Use biometrics or PIN',
  description: 'Authenticate to access secure content',
  allowDeviceCredential: true, // Enable PIN/Pattern/Password fallback
  biometricStrength: 'strong',
);

final authResult = BiometricAuthResult.fromMap(result);

if (authResult.success) {
  if (authResult.usedDeviceCredential) {
    print('Authenticated with device credential');
  } else {
    print('Authenticated with biometric');
  }
}
```

### Cancel Authentication

```dart
await biometricAuth.cancelAuthentication();
```

## API Reference

### Main Methods

#### `canCheckBiometrics()`
Returns `Future<bool>` - Check if device has biometric hardware.

#### `getAvailableBiometrics()`
Returns `Future<List<String>>` - List of available biometric types: `['fingerprint', 'face', 'iris']`.

#### `hasEnrolledBiometrics()`
Returns `Future<bool>` - Check if user has enrolled at least one biometric.

#### `canAuthenticateWithBiometricsStrong()`
Returns `Future<bool>` - Check if strong biometric (Class 3) authentication is available.

#### `canAuthenticateWithBiometricsWeak()`
Returns `Future<bool>` - Check if weak biometric (Class 2) authentication is available.

#### `canAuthenticateWithDeviceCredential()`
Returns `Future<bool>` - Check if device credential (PIN/Pattern/Password) is set.

#### `authenticate({...})`
Perform biometric authentication with customizable options.

**Parameters:**
- `title` (required) - Dialog title
- `subtitle` (optional) - Dialog subtitle
- `description` (optional) - Additional description/instructions
- `negativeButtonText` - Cancel button text (default: "Cancel")
- `confirmationRequired` - Require explicit user confirmation (default: false)
- `allowDeviceCredential` - Allow PIN/Pattern/Password fallback (default: false)
- `biometricStrength` - Required strength: 'strong', 'weak', or 'any' (default: 'strong')

**Returns:** `Future<Map<String, dynamic>>` with authentication result.

#### `getBiometricInfo()`
Returns `Future<Map<String, dynamic>>` - Comprehensive biometric capability information.

#### `cancelAuthentication()`
Returns `Future<void>` - Cancel current authentication dialog.

## Models

### BiometricAuthResult

Result object returned after authentication:

```dart
class BiometricAuthResult {
  final bool success;                    // Authentication success status
  final String? errorCode;               // Error code if failed
  final String? errorMessage;            // Human-readable error message
  final String? biometricType;           // Type of biometric used
  final bool usedDeviceCredential;       // Whether device credential was used
  final AuthenticationMethod authenticationMethod; // Method used
}
```

### BiometricType

Available biometric types:
- `fingerprint` - Fingerprint sensor
- `face` - Face recognition
- `iris` - Iris scanner
- `unknown` - Unknown/unsupported type

### BiometricStrength

Authentication strength levels:
- `strong` - Class 3 biometrics (Fingerprint, 3D Face, Iris)
- `weak` - Class 2 biometrics (2D Face unlock)
- `any` - Accept any available biometric

### AuthenticationMethod

Authentication method used:
- `biometric` - Biometric authentication
- `deviceCredential` - PIN/Pattern/Password
- `unknown` - Unknown method

## Error Codes

Common error codes returned during authentication:

- `CANCELED` - Authentication was canceled
- `USER_CANCELED` - User explicitly canceled
- `NEGATIVE_BUTTON` - User tapped the negative button
- `TIMEOUT` - Authentication timed out
- `LOCKOUT` - Too many failed attempts (temporary lockout)
- `LOCKOUT_PERMANENT` - Biometric authentication disabled due to too many attempts
- `NO_BIOMETRICS` - No biometrics enrolled
- `HW_NOT_PRESENT` - No biometric hardware
- `HW_UNAVAILABLE` - Biometric hardware unavailable
- `NO_DEVICE_CREDENTIAL` - No device credential set
- `BIOMETRIC_UNAVAILABLE` - Biometric authentication not available

## Android Configuration

### Minimum Requirements

Add to your `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 24  // Android 7.0 (Nougat)
        targetSdkVersion 34
    }
}
```

### Permissions

The plugin automatically includes the required permissions. No manual configuration needed.

The following permissions are automatically added:
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
```

## Best Practices

### 1. Always Check Capabilities First

```dart
if (await biometricAuth.canAuthenticateWithBiometricsStrong()) {
  // Proceed with authentication
} else {
  // Show alternative authentication or error message
}
```

### 2. Provide Clear User Feedback

```dart
final result = await biometricAuth.authenticate(
  title: 'Login Required',
  subtitle: 'Verify it\'s you',
  description: 'Touch the fingerprint sensor to continue',
);
```

### 3. Handle Errors Gracefully

```dart
final authResult = BiometricAuthResult.fromMap(result);

if (!authResult.success) {
  switch (authResult.errorCode) {
    case 'NO_BIOMETRICS':
      showMessage('Please enroll biometrics in device settings');
      break;
    case 'LOCKOUT':
      showMessage('Too many attempts. Try again later');
      break;
    default:
      showMessage('Authentication failed: ${authResult.errorMessage}');
  }
}
```

### 4. Use Appropriate Security Levels

- **High Security** (banking, payments): Use `biometricStrength: 'strong'`
- **Convenience** (app unlock): Use `biometricStrength: 'weak'` or `'any'`
- **Critical Operations**: Set `confirmationRequired: true`

### 5. Implement Device Credential Fallback

```dart
final result = await biometricAuth.authenticate(
  title: 'Authenticate',
  allowDeviceCredential: true, // Allow PIN/Pattern as backup
  biometricStrength: 'strong',
);
```

## Example App

The example app demonstrates:
- ✅ Complete device capability checking
- ✅ All available biometric types display
- ✅ Strong vs Weak biometric authentication
- ✅ Device credential fallback
- ✅ Beautiful Material Design 3 UI
- ✅ Comprehensive error handling
- ✅ Real-time authentication status

Run the example:
```bash
cd example
flutter run
```

## Compatibility

### Android Versions
- ✅ Android 7.0 (API 24) - Android 14+ (API 36)
- ✅ Full BiometricPrompt API support (Android 10+)
- ✅ Backward compatibility for older devices

### Device Support
- ✅ All devices with fingerprint sensors
- ✅ Devices with face unlock (2D and 3D)
- ✅ Samsung devices with iris scanners
- ✅ Devices with only PIN/Pattern/Password

## Comparison with Other Plugins

| Feature | flutter_biometric_auth_plus | local_auth | Other plugins |
|---------|---------------------------|------------|---------------|
| BiometricPrompt API | ✅ Full support | ⚠️ Partial | ❌ Limited |
| Strong/Weak Biometrics | ✅ Yes | ❌ No | ❌ No |
| Device Credential Fallback | ✅ Seamless | ⚠️ Basic | ⚠️ Basic |
| Face Recognition | ✅ Yes | ⚠️ Limited | ⚠️ Limited |
| Iris Recognition | ✅ Yes | ❌ No | ❌ No |
| Detailed Capabilities | ✅ Comprehensive | ⚠️ Basic | ❌ Limited |
| Error Handling | ✅ Detailed | ⚠️ Basic | ⚠️ Basic |
| Modern Android API | ✅ Yes | ⚠️ Partial | ❌ No |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Created with ❤️ for the Flutter community

## Support

If you find this plugin helpful, please give it a ⭐ on GitHub!

For bugs and feature requests, please create an issue on GitHub.

---

**Note:** This plugin currently supports Android only. iOS support may be added in future versions.

