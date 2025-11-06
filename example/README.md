# biometric_auth_advanced_example

Demonstrates how to use the biometric_auth_advanced plugin for advanced biometric authentication on Android.

## Features Demonstrated

- ✅ Real-time device capability detection
- ✅ Display of available biometric types (fingerprint, face, iris)
- ✅ Three authentication modes:
  - Strong biometric only (Class 3)
  - Weak biometric (Class 2)
  - Biometric with device credential fallback
- ✅ Beautiful Material Design 3 UI
- ✅ Dark mode support
- ✅ Animated feedback for authentication results
- ✅ Comprehensive error handling

## Running the Example

```bash
cd example
flutter pub get
flutter run
```

## Requirements

- Android device or emulator with:
  - Biometric hardware (fingerprint sensor, face unlock, etc.)
  - Enrolled biometrics or device credentials
  - Android 7.0 (API 24) or higher

## Screenshots

The example app shows:
1. Device capabilities card
2. Available biometric types
3. Three authentication method buttons
4. Real-time authentication results

For more information, see the [main plugin documentation](https://pub.dev/packages/biometric_auth_advanced).
