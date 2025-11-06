/// Represents the type of biometric authentication available on the device
enum BiometricType {
  /// Fingerprint recognition
  fingerprint,

  /// Face recognition (including 2D and 3D face unlock)
  face,

  /// Iris recognition
  iris,

  /// Unknown or unsupported biometric type
  unknown;

  /// Convert string to BiometricType enum
  static BiometricType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'fingerprint':
        return BiometricType.fingerprint;
      case 'face':
        return BiometricType.face;
      case 'iris':
        return BiometricType.iris;
      default:
        return BiometricType.unknown;
    }
  }

  /// Get user-friendly name for the biometric type
  String get displayName {
    switch (this) {
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.face:
        return 'Face Recognition';
      case BiometricType.iris:
        return 'Iris Recognition';
      case BiometricType.unknown:
        return 'Unknown';
    }
  }
}

