## Flutter Biometric Auth Plus - Quick Start Guide

This guide will help you quickly integrate advanced biometric authentication into your Flutter app.

### Step 1: Installation

Add the plugin to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_biometric_auth_plus: ^1.0.0
```

Run:
```bash
flutter pub get
```

### Step 2: Basic Implementation

```dart
import 'package:flutter_biometric_auth_plus/flutter_biometric_auth_plus.dart';

class AuthService {
  final _auth = FlutterBiometricAuthPlus();

  // Check if biometrics are available
  Future<bool> isBiometricAvailable() async {
    return await _auth.hasEnrolledBiometrics();
  }

  // Simple authentication
  Future<bool> authenticate() async {
    final result = await _auth.authenticate(
      title: 'Authentication Required',
      subtitle: 'Please verify your identity',
    );
    
    final authResult = BiometricAuthResult.fromMap(result);
    return authResult.success;
  }
}
```

### Step 3: Advanced Usage

```dart
// Check device capabilities
Future<void> checkCapabilities() async {
  final info = await _auth.getBiometricInfo();
  
  print('Has biometric hardware: ${info['hasHardware']}');
  print('Strong biometric available: ${info['supportsStrongBiometric']}');
  print('Available types: ${info['availableBiometricTypes']}');
}

// Authenticate with fallback
Future<bool> authenticateWithFallback() async {
  final result = await _auth.authenticate(
    title: 'Secure Login',
    allowDeviceCredential: true, // Allow PIN/Pattern as backup
    biometricStrength: 'strong',
  );
  
  final authResult = BiometricAuthResult.fromMap(result);
  
  if (authResult.success) {
    if (authResult.usedDeviceCredential) {
      print('Logged in with PIN/Pattern/Password');
    } else {
      print('Logged in with biometric');
    }
    return true;
  }
  
  return false;
}
```

### Step 4: Error Handling

```dart
Future<void> authenticateWithErrorHandling() async {
  try {
    final result = await _auth.authenticate(
      title: 'Login',
      subtitle: 'Verify your identity',
    );
    
    final authResult = BiometricAuthResult.fromMap(result);
    
    if (authResult.success) {
      // Authentication successful
      navigateToHome();
    } else {
      // Handle specific errors
      switch (authResult.errorCode) {
        case 'NO_BIOMETRICS':
          showDialog('Please enroll biometrics in Settings');
          break;
        case 'LOCKOUT':
          showDialog('Too many attempts. Try again later');
          break;
        case 'USER_CANCELED':
          // User canceled, do nothing
          break;
        default:
          showDialog('Authentication failed: ${authResult.errorMessage}');
      }
    }
  } catch (e) {
    showDialog('Error: $e');
  }
}
```

### Common Use Cases

#### 1. App Lock Screen

```dart
class AppLockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final auth = FlutterBiometricAuthPlus();
            final result = await auth.authenticate(
              title: 'Unlock App',
              description: 'Use biometric to unlock',
              allowDeviceCredential: true,
            );
            
            final authResult = BiometricAuthResult.fromMap(result);
            if (authResult.success) {
              Navigator.pushReplacement(context, ...);
            }
          },
          child: Text('Unlock with Biometric'),
        ),
      ),
    );
  }
}
```

#### 2. Payment Confirmation

```dart
Future<bool> confirmPayment(double amount) async {
  final auth = FlutterBiometricAuthPlus();
  
  final result = await auth.authenticate(
    title: 'Confirm Payment',
    subtitle: '\$$amount',
    description: 'Authenticate to complete transaction',
    confirmationRequired: true, // Require explicit confirmation
    biometricStrength: 'strong', // Use strong biometrics only
  );
  
  final authResult = BiometricAuthResult.fromMap(result);
  return authResult.success;
}
```

#### 3. Settings Protection

```dart
class SecureSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authenticateForSettings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        
        if (snapshot.data == true) {
          return SettingsContent();
        }
        
        return UnauthorizedScreen();
      },
    );
  }
  
  Future<bool> _authenticateForSettings() async {
    final auth = FlutterBiometricAuthPlus();
    final result = await auth.authenticate(
      title: 'Access Settings',
      subtitle: 'Sensitive settings require authentication',
    );
    
    final authResult = BiometricAuthResult.fromMap(result);
    return authResult.success;
  }
}
```

### Best Practices

1. **Always check capabilities before authentication**
2. **Provide meaningful titles and descriptions**
3. **Handle all error cases gracefully**
4. **Use appropriate security levels for your use case**
5. **Implement device credential fallback for better UX**

### Need Help?

- Check the [full documentation](README.md)
- See the [example app](example/) for complete implementation
- Report issues on [GitHub](https://github.com/yourusername/flutter_biometric_auth_plus/issues)

---

Happy coding! 🚀

