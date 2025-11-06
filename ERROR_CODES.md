# Error Codes Reference

This document provides a comprehensive reference for all error codes that can be returned by the Flutter Biometric Auth Plus plugin.

## Error Code Categories

### 1. User Action Errors

#### `CANCELED`
- **Description**: Authentication was canceled by the system
- **Common Cause**: System interrupted the authentication process
- **User Action**: Try again
- **Code Example**:
```dart
if (authResult.errorCode == 'CANCELED') {
  showMessage('Authentication was canceled. Please try again.');
}
```

#### `USER_CANCELED`
- **Description**: User explicitly canceled authentication
- **Common Cause**: User pressed back button or canceled the prompt
- **User Action**: User chose not to authenticate
- **Code Example**:
```dart
if (authResult.errorCode == 'USER_CANCELED') {
  // User intentionally canceled, don't show error
  return;
}
```

#### `NEGATIVE_BUTTON`
- **Description**: User tapped the negative/cancel button
- **Common Cause**: User pressed the "Cancel" button in the dialog
- **User Action**: User chose to cancel
- **Code Example**:
```dart
if (authResult.errorCode == 'NEGATIVE_BUTTON') {
  // Show alternative authentication method
  showAlternativeAuth();
}
```

### 2. Hardware Errors

#### `HW_NOT_PRESENT`
- **Description**: No biometric hardware on device
- **Common Cause**: Device doesn't have fingerprint sensor, face unlock, etc.
- **User Action**: Use alternative authentication method
- **Code Example**:
```dart
if (authResult.errorCode == 'HW_NOT_PRESENT') {
  showMessage('This device does not support biometric authentication');
  showPasswordLogin();
}
```

#### `HW_UNAVAILABLE`
- **Description**: Biometric hardware currently unavailable
- **Common Cause**: Hardware is being used or disabled temporarily
- **User Action**: Try again later or use alternative method
- **Code Example**:
```dart
if (authResult.errorCode == 'HW_UNAVAILABLE') {
  showMessage('Biometric sensor is temporarily unavailable');
}
```

### 3. Enrollment Errors

#### `NO_BIOMETRICS`
- **Description**: No biometrics enrolled on device
- **Common Cause**: User hasn't registered fingerprint/face in device settings
- **User Action**: Enroll biometrics in device settings
- **Code Example**:
```dart
if (authResult.errorCode == 'NO_BIOMETRICS') {
  showDialog(
    title: 'No Biometrics Enrolled',
    message: 'Please add fingerprint or face recognition in device settings',
    actions: [
      TextButton(
        onPressed: () => openSecuritySettings(),
        child: Text('Open Settings'),
      ),
    ],
  );
}
```

#### `NO_DEVICE_CREDENTIAL`
- **Description**: No device credential (PIN/Pattern/Password) set
- **Common Cause**: User hasn't set up screen lock
- **User Action**: Set up screen lock in device settings
- **Code Example**:
```dart
if (authResult.errorCode == 'NO_DEVICE_CREDENTIAL') {
  showMessage('Please set up a PIN, pattern, or password in device settings');
}
```

### 4. Security Errors

#### `LOCKOUT`
- **Description**: Too many failed authentication attempts (temporary lockout)
- **Common Cause**: Multiple consecutive failed biometric attempts
- **User Action**: Wait 30 seconds and try again
- **Duration**: Typically 30 seconds
- **Code Example**:
```dart
if (authResult.errorCode == 'LOCKOUT') {
  showMessage('Too many attempts. Please wait 30 seconds and try again.');
  // Optionally show countdown timer
}
```

#### `LOCKOUT_PERMANENT`
- **Description**: Biometric authentication permanently disabled
- **Common Cause**: Too many failed attempts over time
- **User Action**: Use device credential (PIN/Pattern/Password)
- **Code Example**:
```dart
if (authResult.errorCode == 'LOCKOUT_PERMANENT') {
  showMessage('Biometric authentication has been disabled. Please use your PIN/Pattern/Password.');
  // Force device credential authentication
  authenticateWithDeviceCredential();
}
```

### 5. Operation Errors

#### `TIMEOUT`
- **Description**: Authentication timed out
- **Common Cause**: User didn't interact with biometric sensor in time
- **User Action**: Try again
- **Code Example**:
```dart
if (authResult.errorCode == 'TIMEOUT') {
  showMessage('Authentication timed out. Please try again.');
}
```

#### `UNABLE_TO_PROCESS`
- **Description**: Sensor unable to process biometric input
- **Common Cause**: Poor quality biometric sample, dirty sensor
- **User Action**: Clean sensor and try again
- **Code Example**:
```dart
if (authResult.errorCode == 'UNABLE_TO_PROCESS') {
  showMessage('Unable to process. Please clean the sensor and try again.');
}
```

#### `NO_SPACE`
- **Description**: Not enough storage for biometric operation
- **Common Cause**: Device storage full
- **User Action**: Free up storage space
- **Code Example**:
```dart
if (authResult.errorCode == 'NO_SPACE') {
  showMessage('Insufficient storage. Please free up space and try again.');
}
```

### 6. System Errors

#### `BIOMETRIC_UNAVAILABLE`
- **Description**: Biometric authentication not available
- **Common Cause**: Various reasons (no hardware, not enrolled, etc.)
- **User Action**: Check error message for details
- **Code Example**:
```dart
if (authResult.errorCode == 'BIOMETRIC_UNAVAILABLE') {
  showMessage(authResult.errorMessage ?? 'Biometric authentication unavailable');
}
```

#### `VENDOR_ERROR`
- **Description**: Vendor-specific error
- **Common Cause**: Device manufacturer's custom implementation issue
- **User Action**: Check error message, may vary by device
- **Code Example**:
```dart
if (authResult.errorCode == 'VENDOR_ERROR') {
  logError('Vendor error: ${authResult.errorMessage}');
  showMessage('An error occurred. Please try again.');
}
```

#### `UNKNOWN_ERROR`
- **Description**: An unknown error occurred
- **Common Cause**: Unexpected error condition
- **User Action**: Try again or use alternative method
- **Code Example**:
```dart
if (authResult.errorCode == 'UNKNOWN_ERROR') {
  logError('Unknown error: ${authResult.errorMessage}');
  showMessage('An unexpected error occurred');
}
```

## Complete Error Handling Example

```dart
Future<void> handleAuthResult(BiometricAuthResult result) async {
  if (result.success) {
    // Authentication successful
    navigateToSecureScreen();
    return;
  }

  // Handle specific errors
  switch (result.errorCode) {
    case 'NO_BIOMETRICS':
      await showEnrollmentDialog();
      break;
      
    case 'LOCKOUT':
      showTimedMessage('Too many attempts. Please wait 30 seconds.');
      break;
      
    case 'LOCKOUT_PERMANENT':
      await authenticateWithDeviceCredential();
      break;
      
    case 'HW_NOT_PRESENT':
      await showPasswordAuthentication();
      break;
      
    case 'USER_CANCELED':
    case 'NEGATIVE_BUTTON':
      // User chose not to authenticate
      break;
      
    default:
      showMessage('Authentication failed: ${result.errorMessage}');
  }
}
```

## Best Practices for Error Handling

### 1. User-Friendly Messages
```dart
String getUserFriendlyMessage(String errorCode) {
  switch (errorCode) {
    case 'NO_BIOMETRICS':
      return 'Please add your fingerprint in Settings → Security';
    case 'LOCKOUT':
      return 'Too many attempts. Try again in 30 seconds';
    case 'HW_NOT_PRESENT':
      return 'Your device doesn\'t support biometric authentication';
    default:
      return 'Authentication failed. Please try again';
  }
}
```

### 2. Graceful Degradation
```dart
Future<bool> authenticateWithFallback() async {
  final result = await _auth.authenticate(title: 'Login');
  final authResult = BiometricAuthResult.fromMap(result);
  
  if (authResult.success) {
    return true;
  }
  
  // Fallback to device credential if biometric fails
  if (authResult.errorCode == 'LOCKOUT_PERMANENT' || 
      authResult.errorCode == 'HW_NOT_PRESENT') {
    return await authenticateWithPassword();
  }
  
  return false;
}
```

### 3. Logging and Analytics
```dart
void logAuthenticationError(BiometricAuthResult result) {
  if (!result.success) {
    analytics.logEvent(
      'biometric_auth_failed',
      parameters: {
        'error_code': result.errorCode ?? 'unknown',
        'error_message': result.errorMessage ?? '',
      },
    );
  }
}
```

### 4. Retry Logic
```dart
Future<bool> authenticateWithRetry({int maxRetries = 3}) async {
  for (int i = 0; i < maxRetries; i++) {
    final result = await _auth.authenticate(title: 'Login');
    final authResult = BiometricAuthResult.fromMap(result);
    
    if (authResult.success) {
      return true;
    }
    
    // Don't retry on certain errors
    if (authResult.errorCode == 'NO_BIOMETRICS' ||
        authResult.errorCode == 'HW_NOT_PRESENT' ||
        authResult.errorCode == 'USER_CANCELED') {
      break;
    }
    
    // Wait before retry
    if (i < maxRetries - 1) {
      await Future.delayed(Duration(seconds: 2));
    }
  }
  
  return false;
}
```

## Testing Error Scenarios

### Simulate Lockout
1. Attempt authentication with wrong finger 5 times
2. Should trigger `LOCKOUT` error
3. Wait 30 seconds
4. Should be able to authenticate again

### Simulate No Biometrics
1. Remove all fingerprints/face data from device settings
2. Attempt authentication
3. Should trigger `NO_BIOMETRICS` error

### Simulate Hardware Unavailable
1. Use biometric sensor in another app
2. Immediately try to authenticate
3. May trigger `HW_UNAVAILABLE` error

## Additional Resources

- [Android BiometricPrompt Documentation](https://developer.android.com/reference/androidx/biometric/BiometricPrompt)
- [BiometricManager Error Codes](https://developer.android.com/reference/androidx/biometric/BiometricManager.Authenticators)
- [Plugin README](README.md)
- [Quick Start Guide](QUICKSTART.md)

---

For more help, please file an issue on GitHub.

