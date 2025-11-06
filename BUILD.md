# Flutter Biometric Auth Plus - Build & Test Guide

## Prerequisites

- Flutter SDK (3.3.0 or higher)
- Android Studio or VS Code
- Android SDK (API 24+)
- Physical Android device or emulator with biometric support

## Project Structure

```
flutter_biometric_auth_plus/
├── android/                          # Native Android implementation
│   ├── src/main/kotlin/             # Kotlin source code
│   │   └── FlutterBiometricAuthPlusPlugin.kt
│   └── build.gradle                 # Android build configuration
├── lib/                             # Flutter/Dart code
│   ├── src/
│   │   ├── models/                  # Data models
│   │   │   ├── authentication_options.dart
│   │   │   ├── biometric_auth_result.dart
│   │   │   ├── biometric_strength.dart
│   │   │   └── biometric_type.dart
│   │   └── widgets/                 # Reusable widgets
│   │       └── biometric_auth_button.dart
│   ├── flutter_biometric_auth_plus.dart
│   ├── flutter_biometric_auth_plus_platform_interface.dart
│   └── flutter_biometric_auth_plus_method_channel.dart
├── example/                         # Example application
│   └── lib/main.dart               # Beautiful demo app
├── README.md                        # Main documentation
├── QUICKSTART.md                    # Quick start guide
├── ERROR_CODES.md                   # Error reference
├── CHANGELOG.md                     # Version history
└── pubspec.yaml                     # Package configuration

## Build Instructions

### 1. Get Dependencies

```bash
# Navigate to plugin root
cd flutter_biometric_auth_plus

# Get plugin dependencies
flutter pub get

# Navigate to example app
cd example

# Get example dependencies
flutter pub get
```

### 2. Build Android APK

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# Split APKs by ABI (smaller file size)
flutter build apk --split-per-abi
```

### 3. Run on Device

```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d <device_id>

# Run in release mode
flutter run --release
```

## Testing

### Manual Testing Checklist

#### Device Capabilities
- [ ] Test on device with fingerprint only
- [ ] Test on device with face unlock
- [ ] Test on device with multiple biometric types
- [ ] Test on device with no biometrics
- [ ] Test on device with only PIN/Pattern

#### Authentication Scenarios
- [ ] Successful fingerprint authentication
- [ ] Successful face authentication
- [ ] Failed authentication (wrong finger)
- [ ] User cancellation
- [ ] Timeout scenario
- [ ] Lockout after multiple failures
- [ ] Device credential fallback

#### Strong vs Weak Biometrics
- [ ] Strong biometric authentication
- [ ] Weak biometric authentication
- [ ] Fallback to device credential

#### UI/UX
- [ ] Custom dialog titles and descriptions
- [ ] Loading states
- [ ] Error messages
- [ ] Animation smoothness
- [ ] Dark mode support

### Automated Testing

```bash
# Run Dart tests
flutter test

# Run integration tests on device
flutter test integration_test/
```

## Common Issues & Solutions

### Issue 1: "No implementation found"
**Solution**: Run `flutter clean && flutter pub get`

### Issue 2: Gradle build fails
**Solution**: 
```bash
cd example/android
./gradlew clean
cd ../..
flutter clean
flutter pub get
```

### Issue 3: Biometric not working on emulator
**Solution**: 
1. Open emulator settings
2. Go to Fingerprint section
3. Enroll fingerprint in emulator

### Issue 4: Build version conflicts
**Solution**: Ensure your `android/app/build.gradle` has:
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 24
        targetSdkVersion 34
    }
}
```

## Performance Optimization

### 1. Reduce APK Size
```bash
# Use ProGuard/R8 for release builds
flutter build apk --release --shrink

# Split by ABI
flutter build apk --split-per-abi
```

### 2. Code Optimization
- Plugin uses lazy initialization
- Native code is optimized for minimal overhead
- No unnecessary dependencies

## Publishing Checklist

Before publishing to pub.dev:

- [ ] Update version in `pubspec.yaml`
- [ ] Update `CHANGELOG.md`
- [ ] Verify all code is commented
- [ ] Run `flutter analyze` (no errors)
- [ ] Run `flutter format lib/`
- [ ] Test on multiple devices
- [ ] Update README with any new features
- [ ] Generate API documentation: `dart doc`
- [ ] Create GitHub release with tag

### Publishing Commands

```bash
# Dry run to check for issues
flutter pub publish --dry-run

# Publish to pub.dev
flutter pub publish
```

## Development Setup

### For Contributors

1. Fork the repository
2. Clone your fork
3. Create a feature branch
4. Make your changes
5. Run tests
6. Submit pull request

```bash
git clone https://github.com/yourusername/flutter_biometric_auth_plus.git
cd flutter_biometric_auth_plus
git checkout -b feature/my-feature
# Make changes
flutter test
git commit -m "Add my feature"
git push origin feature/my-feature
```

## Code Quality

### Run Analysis
```bash
flutter analyze
```

### Format Code
```bash
flutter format lib/ example/lib/
```

### Check Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Documentation Generation

```bash
# Generate API documentation
dart doc

# Documentation will be in doc/api/
```

## Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/flutter_biometric_auth_plus/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/flutter_biometric_auth_plus/discussions)
- **Email**: support@example.com

## License

MIT License - see LICENSE file for details.

---

Happy building! 🚀

