/// Result of a biometric authentication attempt
class BiometricAuthResult {
  /// Whether the authentication was successful
  final bool success;

  /// Error code if authentication failed
  final String? errorCode;

  /// Human-readable error message
  final String? errorMessage;

  /// Type of biometric used for authentication
  final String? biometricType;

  /// Whether device credential was used as fallback
  final bool usedDeviceCredential;

  /// Authentication method used
  final AuthenticationMethod authenticationMethod;

  BiometricAuthResult({
    required this.success,
    this.errorCode,
    this.errorMessage,
    this.biometricType,
    this.usedDeviceCredential = false,
    this.authenticationMethod = AuthenticationMethod.biometric,
  });

  /// Create BiometricAuthResult from a map (from platform channel)
  factory BiometricAuthResult.fromMap(Map<String, dynamic> map) {
    return BiometricAuthResult(
      success: map['success'] as bool? ?? false,
      errorCode: map['errorCode'] as String?,
      errorMessage: map['errorMessage'] as String?,
      biometricType: map['biometricType'] as String?,
      usedDeviceCredential: map['usedDeviceCredential'] as bool? ?? false,
      authenticationMethod: AuthenticationMethod.fromString(
        map['authenticationMethod'] as String? ?? 'biometric',
      ),
    );
  }

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'errorCode': errorCode,
      'errorMessage': errorMessage,
      'biometricType': biometricType,
      'usedDeviceCredential': usedDeviceCredential,
      'authenticationMethod': authenticationMethod.name,
    };
  }

  @override
  String toString() {
    return 'BiometricAuthResult(success: $success, errorCode: $errorCode, '
        'errorMessage: $errorMessage, biometricType: $biometricType, '
        'usedDeviceCredential: $usedDeviceCredential, '
        'authenticationMethod: ${authenticationMethod.name})';
  }
}

/// Method used for authentication
enum AuthenticationMethod {
  /// Biometric authentication (fingerprint, face, iris)
  biometric,

  /// Device credential (PIN, pattern, password)
  deviceCredential,

  /// Unknown method
  unknown;

  /// Convert string to AuthenticationMethod enum
  static AuthenticationMethod fromString(String value) {
    switch (value.toLowerCase()) {
      case 'biometric':
        return AuthenticationMethod.biometric;
      case 'devicecredential':
      case 'device_credential':
        return AuthenticationMethod.deviceCredential;
      default:
        return AuthenticationMethod.unknown;
    }
  }
}

