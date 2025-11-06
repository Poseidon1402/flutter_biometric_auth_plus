# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-06

### Added
- 🎯 Complete biometric authentication support for Android
- 👆 Fingerprint recognition support
- 👤 Face recognition support (2D and 3D)
- 👁️ Iris recognition support
- 🔐 Device credential fallback (PIN, Pattern, Password)
- 💪 Strong biometric authentication (Class 3)
- 🌟 Weak biometric authentication (Class 2)
- 📊 Comprehensive device capability checking
- 🔍 Detailed biometric type detection
- ⚙️ Modern BiometricPrompt API implementation
- 📱 Support for Android 7.0 (API 24) to Android 14+ (API 36)
- 🎨 Beautiful Material Design 3 example app
- 📚 Complete API documentation
- ✅ Extensive error handling and reporting
- 🔄 Authentication cancellation support
- 🎯 Confirmation required option for high-security operations
- 📖 Comprehensive README with examples
- 🧪 Well-commented codebase in English

### Features
- **Device Capability Checks:**
  - Check for biometric hardware availability
  - Detect enrolled biometrics
  - Check strong vs weak biometric support
  - Verify device credential setup
  - Get list of available biometric types

- **Authentication Options:**
  - Customizable dialog (title, subtitle, description)
  - Configurable negative button text
  - Optional confirmation requirement
  - Device credential fallback toggle
  - Biometric strength selection (strong/weak/any)

- **Result Information:**
  - Success/failure status
  - Detailed error codes and messages
  - Authentication method used
  - Device credential usage indicator

- **Error Handling:**
  - User cancellation
  - Hardware unavailability
  - Lockout scenarios
  - Missing enrollments
  - And more...

### Technical Details
- Built with Kotlin 2.1.0
- Uses AndroidX Biometric 1.2.0-alpha05
- Minimum SDK: 24 (Android 7.0)
- Compile SDK: 36 (Android 14+)
- Material Design 3 UI
- Null safety enabled

### Example App Features
- Real-time capability detection
- Visual biometric type indicators
- Three authentication modes demonstration
- Animated UI feedback
- Dark mode support
- Comprehensive error display

[1.0.0]: https://github.com/yourusername/flutter_biometric_auth_plus/releases/tag/v1.0.0
