# Technical Architecture

## Overview

Flutter Biometric Auth Plus is a comprehensive biometric authentication plugin that bridges Flutter applications with Android's native BiometricPrompt API. This document describes the technical architecture and implementation details.

## Architecture Layers

```
┌─────────────────────────────────────────────┐
│           Flutter Application               │
│         (Dart/Flutter Code)                 │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│      Plugin Public API Layer                │
│   (FlutterBiometricAuthPlus)                │
│   - canCheckBiometrics()                    │
│   - authenticate()                          │
│   - getBiometricInfo()                      │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│      Platform Interface Layer               │
│   (FlutterBiometricAuthPlusPlatform)        │
│   - Abstract method definitions             │
│   - Platform-agnostic interface             │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│      Method Channel Layer                   │
│   (MethodChannelFlutterBiometricAuthPlus)   │
│   - Platform channel communication          │
│   - Data serialization/deserialization      │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│      Native Android Layer                   │
│   (FlutterBiometricAuthPlusPlugin.kt)       │
│   - BiometricPrompt implementation          │
│   - BiometricManager integration            │
│   - Hardware capability detection           │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│      Android OS APIs                        │
│   - BiometricPrompt API (Android 10+)       │
│   - BiometricManager                        │
│   - Hardware Abstraction Layer              │
└─────────────────────────────────────────────┘
```

## Core Components

### 1. Flutter Layer (Dart)

#### Main Plugin Class
**File**: `lib/flutter_biometric_auth_plus.dart`

Provides the public API that developers interact with:
- High-level authentication methods
- Device capability checks
- Biometric information queries

#### Platform Interface
**File**: `lib/flutter_biometric_auth_plus_platform_interface.dart`

Defines the contract between Flutter and platform-specific implementations:
- Abstract method declarations
- Platform verification using tokens
- Singleton instance management

#### Method Channel Implementation
**File**: `lib/flutter_biometric_auth_plus_method_channel.dart`

Handles communication with native code:
- Serializes Dart objects to platform-compatible maps
- Deserializes platform responses to Dart objects
- Manages method channel lifecycle

#### Data Models
**Directory**: `lib/src/models/`

Type-safe representations of authentication data:
- `BiometricAuthResult`: Authentication outcome
- `BiometricType`: Types of biometrics (fingerprint, face, iris)
- `BiometricStrength`: Security levels (strong, weak)
- `AuthenticationOptions`: Configuration for auth dialogs

### 2. Android Native Layer (Kotlin)

#### Plugin Implementation
**File**: `android/src/main/kotlin/.../FlutterBiometricAuthPlusPlugin.kt`

**Key Responsibilities**:
- Implements `FlutterPlugin` interface
- Implements `ActivityAware` for activity lifecycle
- Manages `BiometricPrompt` instances
- Handles method channel calls from Flutter

**Components**:
```kotlin
class FlutterBiometricAuthPlusPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var context: Context?
    private var activity: FragmentActivity?
    private var biometricManager: BiometricManager?
    private var currentPrompt: BiometricPrompt?
}
```

## Data Flow

### Authentication Flow

```
┌─────────────┐
│   User      │
│   Taps      │
│  "Auth"     │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────┐
│  Flutter App calls:                 │
│  biometricAuth.authenticate(...)    │
└──────┬──────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│  Method Channel sends:              │
│  {                                  │
│    method: "authenticate",          │
│    args: {                          │
│      title: "Login",                │
│      allowDeviceCredential: true    │
│    }                                │
│  }                                  │
└──────┬──────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│  Native Plugin receives call        │
│  handleAuthenticate(call, result)   │
└──────┬──────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│  BiometricPrompt.PromptInfo         │
│  built with parameters              │
└──────┬──────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│  BiometricPrompt.authenticate()     │
│  shows system dialog                │
└──────┬──────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│  User interacts with biometric      │
│  sensor (fingerprint/face/PIN)      │
└──────┬──────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│  Callback triggered:                │
│  - onAuthenticationSucceeded()      │
│  - onAuthenticationError()          │
│  - onAuthenticationFailed()         │
└──────┬──────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│  Result sent back to Flutter:       │
│  {                                  │
│    success: true/false,             │
│    errorCode: "...",                │
│    authenticationMethod: "..."      │
│  }                                  │
└──────┬──────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│  Flutter receives result            │
│  BiometricAuthResult.fromMap()      │
└──────┬──────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│  UI updated based on result         │
└─────────────────────────────────────┘
```

## Biometric Strength Levels

### Android Authenticator Constants

```kotlin
// Strong Biometric (Class 3)
BIOMETRIC_STRONG = 0x000F
- Fingerprint
- 3D Face (e.g., Pixel 4+)
- Iris

// Weak Biometric (Class 2)
BIOMETRIC_WEAK = 0x00FF
- 2D Face unlock
- Any biometric not meeting Class 3 requirements

// Device Credential
DEVICE_CREDENTIAL = 0x8000
- PIN
- Pattern
- Password

// Combined
BIOMETRIC_STRONG | DEVICE_CREDENTIAL = 0x800F
```

### Security Implications

**Strong Biometric**:
- Suitable for financial transactions
- Can be used for cryptographic operations
- Meets requirements for secure key storage
- Lower false acceptance rate (<0.002%)

**Weak Biometric**:
- Suitable for app unlock, low-risk operations
- Convenience over security
- Higher false acceptance rate

**Device Credential**:
- Always available if user has lock screen
- Knowledge-based authentication
- Can be used as fallback

## Error Handling Strategy

### Error Propagation

```
Android BiometricPrompt Error
         ↓
Mapped to error code string
         ↓
Sent via Method Channel
         ↓
Converted to BiometricAuthResult
         ↓
Presented to Flutter app
```

### Error Code Mapping

```kotlin
fun getErrorCode(errorCode: Int): String {
    return when (errorCode) {
        BiometricPrompt.ERROR_CANCELED -> "CANCELED"
        BiometricPrompt.ERROR_LOCKOUT -> "LOCKOUT"
        BiometricPrompt.ERROR_NO_BIOMETRICS -> "NO_BIOMETRICS"
        // ... etc
    }
}
```

## Memory Management

### Native Side
- `BiometricPrompt` instance lifecycle managed
- Cleaned up in `onDetachedFromActivity()`
- Activity references properly nullified to prevent leaks

### Flutter Side
- Models are immutable value objects
- No circular references
- Proper disposal in StatefulWidgets

## Thread Safety

### Main Thread Operations
All biometric operations run on the main thread:
```kotlin
executor = ContextCompat.getMainExecutor(context)
BiometricPrompt(activity, executor, callback)
```

### Async Communication
Method channel calls are asynchronous:
```dart
Future<Map<String, dynamic>> authenticate(...) async {
    final result = await methodChannel.invokeMethod(...);
    return result;
}
```

## Performance Considerations

### Initialization
- Lazy initialization of `BiometricManager`
- One-time setup in `onAttachedToEngine()`

### Response Time
- Native calls: < 10ms
- Biometric scan: 300ms - 2s (hardware dependent)
- Total round trip: < 3s typical

### Resource Usage
- Minimal memory footprint (~100KB)
- No background processes
- No persistent connections

## Compatibility Matrix

| Android Version | API Level | Support Level |
|----------------|-----------|---------------|
| 7.0 (Nougat)   | 24        | ✅ Full       |
| 8.0 (Oreo)     | 26        | ✅ Full       |
| 9.0 (Pie)      | 28        | ✅ Full       |
| 10             | 29        | ✅ Enhanced   |
| 11             | 30        | ✅ Enhanced   |
| 12             | 31        | ✅ Enhanced   |
| 13             | 33        | ✅ Enhanced   |
| 14             | 34        | ✅ Latest     |

### BiometricPrompt API
- Introduced: Android 9.0 (API 28)
- Mature: Android 10+ (API 29+)
- Our minimum: API 24 with AndroidX backport

## Security Best Practices

### Implemented in Plugin

1. **No credential storage**: Plugin never stores biometric data
2. **System-handled authentication**: All auth goes through Android OS
3. **Secure communication**: Method channel is secure
4. **No plaintext secrets**: No sensitive data in logs
5. **Proper cleanup**: Prompt instances properly disposed

### Recommended for Apps

1. **Server-side validation**: Don't trust client-only auth
2. **Token-based sessions**: Use auth result to obtain session token
3. **Secure storage**: Use flutter_secure_storage for tokens
4. **Certificate pinning**: For network requests
5. **Obfuscation**: Use ProGuard/R8 for release builds

## Testing Strategy

### Unit Tests
- Model serialization/deserialization
- Error code mapping
- State management

### Integration Tests
- Full authentication flow
- Error scenarios
- Capability detection

### Manual Tests
- Multiple device types
- Various Android versions
- Different biometric types

## Future Enhancements

### Planned Features
- iOS support (Face ID, Touch ID)
- Biometric cryptography support
- Custom UI theming options
- Advanced error recovery

### Performance Improvements
- Reduce first-call latency
- Optimize capability detection
- Cache capability results

## Contributing

See architecture when contributing:
1. Maintain layer separation
2. Follow existing patterns
3. Add tests for new features
4. Update documentation

---

For questions about the architecture, please open a GitHub discussion.

