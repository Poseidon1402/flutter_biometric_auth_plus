/// Represents the strength level of biometric authentication
/// Based on Android BiometricManager.Authenticators constants
enum BiometricStrength {
  /// Strong biometrics (Class 3)
  /// Examples: Fingerprint, 3D Face (like Pixel 4), Iris
  /// Meets the requirements for cryptographic operations
  strong,

  /// Weak biometrics (Class 2)
  /// Examples: 2D Face unlock on some devices
  /// Provides convenience but may not be suitable for high-security operations
  weak,

  /// Any biometric (Strong or Weak)
  any;

  /// Convert string to BiometricStrength enum
  static BiometricStrength fromString(String value) {
    switch (value.toLowerCase()) {
      case 'strong':
        return BiometricStrength.strong;
      case 'weak':
        return BiometricStrength.weak;
      case 'any':
        return BiometricStrength.any;
      default:
        return BiometricStrength.strong;
    }
  }

  /// Convert to Android Authenticators constant value
  int toAuthenticatorValue() {
    switch (this) {
      case BiometricStrength.strong:
        return 15; // BIOMETRIC_STRONG
      case BiometricStrength.weak:
        return 255; // BIOMETRIC_WEAK
      case BiometricStrength.any:
        return 255; // BIOMETRIC_WEAK (includes strong)
    }
  }

  /// Get user-friendly description
  String get description {
    switch (this) {
      case BiometricStrength.strong:
        return 'Strong biometrics (Class 3): Fingerprint, 3D Face, Iris';
      case BiometricStrength.weak:
        return 'Weak biometrics (Class 2): 2D Face unlock';
      case BiometricStrength.any:
        return 'Any available biometric authentication';
    }
  }
}

