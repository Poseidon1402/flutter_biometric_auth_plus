# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-11-06

### Added
- 🎯 Complete biometric authentication support for Android
- 👆 Fingerprint recognition support
- 👤 Face recognition support (2D and 3D)
- 👁️ Iris recognition support (Samsung Galaxy S8/S9/Note 8/Note 9)
- 🔐 Device credential fallback (PIN, Pattern, Password)
- 💪 Strong biometric authentication (Class 3)
- 🌟 Weak biometric authentication (Class 2)
- 📊 Comprehensive device capability checking
- 🔍 Intelligent biometric type detection based on device manufacturer and model
- ⚙️ Modern BiometricPrompt API implementation
- 📱 Support for Android 7.0 (API 24) to Android 14+ (API 36)
- 🎨 Beautiful Material Design 3 example app
- ✅ Extensive error handling with 15+ error codes
- 🔄 Authentication cancellation support
- 🎯 Confirmation required option for high-security operations
- 🧩 Reusable BiometricAuthButton widget

### Technical Details
- Built with Kotlin 2.1.0
- Uses AndroidX Biometric 1.2.0-alpha05
- Minimum SDK: 24 (Android 7.0)
- Compile SDK: 36 (Android 14+)
- Full null safety support

### Security Features
- No credential storage
- System-handled authentication via BiometricPrompt
- Secure method channel communication
- Proper activity lifecycle management
- Memory leak prevention

[1.0.0]: https://github.com/yourusername/flutter_biometric_auth_plus/releases/tag/v1.0.0
