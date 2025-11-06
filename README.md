# flutter_biometric_auth_plus

[![pub package](https://img.shields.io/pub/v/flutter_biometric_auth_plus.svg)](https://pub.dev/packages/flutter_biometric_auth_plus)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Advanced biometric authentication plugin for Flutter with comprehensive Android support including fingerprint, face recognition, iris scanning, and device credentials.

## 🎥 Demo

https://github.com/Poseidon1402/flutter_biometric_auth_plus/blob/main/assets/demo.mp4

> **Note:** Replace the URL above with your actual demo video URL from GitHub or YouTube

## ✨ Features

- 🔐 **Complete Biometric Support**
  - Fingerprint recognition
  - Face recognition (2D and 3D)
  - Iris recognition (Samsung devices)
  - Device credentials (PIN, Pattern, Password)

- 💪 **Security Levels**
  - Strong biometrics (Class 3) - Fingerprint, 3D Face, Iris
  - Weak biometrics (Class 2) - 2D Face unlock
  - Device credential fallback support

- 🎯 **Modern Android API**
  - Built on BiometricPrompt API (Android 10+)
  - Backward compatible to Android 7.0 (API 24)
  - Full AndroidX Biometric library integration

- 📊 **Comprehensive Capabilities**
  - Hardware detection
  - Enrollment status checking
  - Detailed error handling (15+ error codes)
  - Authentication cancellation
  - Real-time capability information

## 📱 Platform Support

| Platform | Support |
|----------|---------|
| Android  | ✅      |
| iOS      | ❌ (Coming soon) |

**Android Requirements:**
- Minimum SDK: 24 (Android 7.0)
- Compile SDK: 34+
- Target SDK: 34+

## 🚀 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_biometric_auth_plus: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## 📖 Usage

### Import

```dart
import 'package:flutter_biometric_auth_plus/flutter_biometric_auth_plus.dart';
```

### Quick Start

```dart
final biometricAuth = FlutterBiometricAuthPlus();

// Check if biometrics are available
bool canAuthenticate = await biometricAuth.canAuthenticateWithBiometricsStrong();

if (canAuthenticate) {
  // Authenticate
  final result = await biometricAuth.authenticate(
    title: 'Biometric Authentication',
    subtitle: 'Verify your identity',
    negativeButtonText: 'Cancel',
  );

  final authResult = BiometricAuthResult.fromMap(result);
  
  if (authResult.success) {
    print('✅ Authentication successful!');
  } else {
    print('❌ Authentication failed: ${authResult.errorMessage}');
  }
}
```

### Check Device Capabilities

```dart
// Check hardware availability
bool hasHardware = await biometricAuth.canCheckBiometrics();

// Check enrolled biometrics
bool hasEnrolled = await biometricAuth.hasEnrolledBiometrics();

// Get available biometric types
List<String> types = await biometricAuth.getAvailableBiometrics();
// Returns: ['fingerprint', 'face', 'iris']

// Get comprehensive information
Map<String, dynamic> info = await biometricAuth.getBiometricInfo();
print('Hardware: ${info['hasHardware']}');
print('Enrolled: ${info['hasEnrolledBiometrics']}');
print('Types: ${info['availableBiometricTypes']}');
```

### Authentication Options

#### Strong Biometric Only (Recommended for high security)

```dart
final result = await biometricAuth.authenticate(
  title: 'Secure Payment',
  subtitle: 'Confirm transaction',
  biometricStrength: 'strong', // Fingerprint, 3D Face, Iris
  confirmationRequired: true,  // Explicit confirmation
);
```

#### With Device Credential Fallback

```dart
final result = await biometricAuth.authenticate(
  title: 'Login',
  subtitle: 'Verify your identity',
  allowDeviceCredential: true, // Allow PIN/Pattern/Password
  biometricStrength: 'strong',
);

final authResult = BiometricAuthResult.fromMap(result);
if (authResult.success) {
  if (authResult.usedDeviceCredential) {
    print('Authenticated with PIN/Pattern/Password');
  } else {
    print('Authenticated with biometric');
  }
}
```

#### Weak Biometric (Convenience mode)

```dart
final result = await biometricAuth.authenticate(
  title: 'Quick Unlock',
  biometricStrength: 'weak', // Accepts 2D face unlock
);
```

### Error Handling

```dart
try {
  final result = await biometricAuth.authenticate(
    title: 'Authenticate',
  );
  
  final authResult = BiometricAuthResult.fromMap(result);
  
  if (authResult.success) {
    // Success
    navigateToSecureScreen();
  } else {
    // Handle specific errors
    switch (authResult.errorCode) {
      case 'NO_BIOMETRICS':
        showMessage('Please enroll biometrics in Settings');
        break;
      case 'LOCKOUT':
        showMessage('Too many attempts. Try again in 30 seconds');
        break;
      case 'USER_CANCELED':
        // User canceled, no action needed
        break;
      default:
        showMessage('Authentication failed: ${authResult.errorMessage}');
    }
  }
} on PlatformException catch (e) {
  showMessage('Error: ${e.message}');
}
```

### Using the Reusable Widget

```dart
import 'package:flutter_biometric_auth_plus/flutter_biometric_auth_plus.dart';

BiometricAuthButton(
  dialogTitle: 'Login Required',
  dialogSubtitle: 'Verify your identity',
  allowDeviceCredential: true,
  onAuthSuccess: () {
    // Navigate to home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  },
  onAuthFailure: (error) {
    // Show error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  },
)
```

## 🔧 Android Configuration

### Minimum Setup

Add to `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 24  // Required
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

### MainActivity Configuration

**Important:** Your `MainActivity` must extend `FlutterFragmentActivity`:

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```

## 📚 API Reference

### Main Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `canCheckBiometrics()` | `Future<bool>` | Check if device has biometric hardware |
| `getAvailableBiometrics()` | `Future<List<String>>` | Get list of available biometric types |
| `hasEnrolledBiometrics()` | `Future<bool>` | Check if user has enrolled biometrics |
| `canAuthenticateWithBiometricsStrong()` | `Future<bool>` | Check strong biometric support (Class 3) |
| `canAuthenticateWithBiometricsWeak()` | `Future<bool>` | Check weak biometric support (Class 2) |
| `canAuthenticateWithDeviceCredential()` | `Future<bool>` | Check if PIN/Pattern/Password is set |
| `authenticate()` | `Future<Map<String, dynamic>>` | Perform authentication |
| `getBiometricInfo()` | `Future<Map<String, dynamic>>` | Get comprehensive device info |
| `cancelAuthentication()` | `Future<void>` | Cancel current authentication |

### Authentication Parameters

```dart
authenticate({
  required String title,              // Dialog title
  String? subtitle,                   // Dialog subtitle (optional)
  String? description,                // Dialog description (optional)
  String negativeButtonText = 'Cancel', // Cancel button text
  bool confirmationRequired = false,  // Require explicit confirmation
  bool allowDeviceCredential = false, // Allow PIN/Pattern/Password
  String biometricStrength = 'strong', // 'strong', 'weak', or 'any'
})
```

### BiometricAuthResult

```dart
class BiometricAuthResult {
  final bool success;                    // Authentication success
  final String? errorCode;               // Error code if failed
  final String? errorMessage;            // Human-readable error
  final String? biometricType;           // Type used
  final bool usedDeviceCredential;       // PIN/Pattern used?
  final AuthenticationMethod authenticationMethod; // Method used
}
```

### Common Error Codes

| Error Code | Description | User Action |
|------------|-------------|-------------|
| `NO_BIOMETRICS` | No biometrics enrolled | Enroll in Settings |
| `LOCKOUT` | Too many failed attempts | Wait 30 seconds |
| `LOCKOUT_PERMANENT` | Biometric disabled | Use PIN/Pattern |
| `USER_CANCELED` | User canceled | Try again |
| `HW_NOT_PRESENT` | No biometric hardware | Use alternative auth |
| `HW_UNAVAILABLE` | Hardware temporarily unavailable | Try again later |
| `TIMEOUT` | Authentication timed out | Try again |

## 🎯 Use Cases

### 1. App Lock Screen

```dart
class AppLockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BiometricAuthButton(
          dialogTitle: 'Unlock App',
          allowDeviceCredential: true,
          onAuthSuccess: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          onAuthFailure: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error)),
            );
          },
        ),
      ),
    );
  }
}
```

### 2. Payment Confirmation

```dart
Future<bool> confirmPayment(double amount) async {
  final auth = FlutterBiometricAuthPlus();
  
  final result = await auth.authenticate(
    title: 'Confirm Payment',
    subtitle: '\$$amount',
    description: 'Authenticate to complete transaction',
    confirmationRequired: true,
    biometricStrength: 'strong',
  );
  
  return BiometricAuthResult.fromMap(result).success;
}
```

### 3. Secure Settings Access

```dart
Future<void> openSecureSettings() async {
  final auth = FlutterBiometricAuthPlus();
  
  final result = await auth.authenticate(
    title: 'Access Secure Settings',
    subtitle: 'Authentication required',
  );
  
  if (BiometricAuthResult.fromMap(result).success) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SecureSettingsPage()),
    );
  }
}
```

## 🔒 Security Best Practices

1. **Use Strong Biometrics for Sensitive Operations**
   ```dart
   biometricStrength: 'strong' // For payments, sensitive data
   ```

2. **Require Confirmation for Critical Actions**
   ```dart
   confirmationRequired: true // For transactions
   ```

3. **Implement Server-Side Validation**
   - Don't rely solely on client-side authentication
   - Use authentication result to obtain server session token

4. **Handle All Error Cases**
   - Provide clear user feedback
   - Offer alternative authentication methods

5. **Use Device Credential Fallback**
   ```dart
   allowDeviceCredential: true // Better UX
   ```

## 🐛 Troubleshooting

### "Plugin requires a foreground activity" Error

**Solution:** Ensure `MainActivity` extends `FlutterFragmentActivity`:

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```

### Biometric Dialog Not Showing

**Checklist:**
- ✅ Device has biometric hardware
- ✅ User has enrolled biometrics in Settings
- ✅ App has proper permissions
- ✅ MainActivity extends FlutterFragmentActivity
- ✅ minSdkVersion is 24 or higher

### Face Recognition Not Working

Face recognition detection is based on device manufacturer and model. If your device has face unlock but it's not detected, please file an issue with your device details.

## 📊 Comparison with Other Plugins

| Feature | flutter_biometric_auth_plus | local_auth | Other plugins |
|---------|---------------------------|------------|---------------|
| BiometricPrompt API | ✅ Full support | ⚠️ Partial | ❌ Old API |
| Strong/Weak Biometrics | ✅ Yes | ❌ No | ❌ No |
| Face Recognition | ✅ Full support | ⚠️ Limited | ⚠️ Limited |
| Iris Recognition | ✅ Yes | ❌ No | ❌ No |
| Device Credential Fallback | ✅ Seamless | ⚠️ Basic | ⚠️ Basic |
| Detailed Error Codes | ✅ 15+ codes | ⚠️ Basic | ❌ Limited |
| Reusable Widget | ✅ Yes | ❌ No | ❌ No |
| Android 14 Support | ✅ Yes | ⚠️ Partial | ❌ Unknown |

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Steps to Contribute

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with Flutter and AndroidX Biometric library
- Inspired by the need for comprehensive biometric authentication
- Thanks to all contributors and users

## 📧 Support

- **Issues:** [GitHub Issues](https://github.com/Poseidon1402/flutter_biometric_auth_plus/issues)
- **Email:** rjls.tiavina@gmail.com

## ⭐ Show Your Support

If you find this plugin helpful, please give it a ⭐ on GitHub!

---

**Made with ❤️ for the Flutter community**
