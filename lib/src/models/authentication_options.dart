import 'biometric_strength.dart';

/// Configuration options for biometric authentication
class AuthenticationOptions {
  /// Title displayed in the biometric prompt dialog
  final String title;

  /// Subtitle displayed in the biometric prompt dialog (optional)
  final String? subtitle;

  /// Description/instructions displayed in the dialog (optional)
  final String? description;

  /// Text for the negative/cancel button
  /// Note: Not shown when allowDeviceCredential is true
  final String negativeButtonText;

  /// Whether to require explicit user confirmation after successful biometric auth
  /// Useful for high-security operations
  final bool confirmationRequired;

  /// Allow device credentials (PIN, Pattern, Password) as fallback
  /// When true, the negative button is hidden and system handles fallback
  final bool allowDeviceCredential;

  /// Required strength of biometric authentication
  final BiometricStrength biometricStrength;

  const AuthenticationOptions({
    required this.title,
    this.subtitle,
    this.description,
    this.negativeButtonText = 'Cancel',
    this.confirmationRequired = false,
    this.allowDeviceCredential = false,
    this.biometricStrength = BiometricStrength.strong,
  });

  /// Convert to map for platform channel
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'negativeButtonText': negativeButtonText,
      'confirmationRequired': confirmationRequired,
      'allowDeviceCredential': allowDeviceCredential,
      'biometricStrength': biometricStrength.name,
    };
  }

  /// Create from map
  factory AuthenticationOptions.fromMap(Map<String, dynamic> map) {
    return AuthenticationOptions(
      title: map['title'] as String? ?? 'Authenticate',
      subtitle: map['subtitle'] as String?,
      description: map['description'] as String?,
      negativeButtonText: map['negativeButtonText'] as String? ?? 'Cancel',
      confirmationRequired: map['confirmationRequired'] as bool? ?? false,
      allowDeviceCredential: map['allowDeviceCredential'] as bool? ?? false,
      biometricStrength: BiometricStrength.fromString(
        map['biometricStrength'] as String? ?? 'strong',
      ),
    );
  }

  /// Create a copy with modified fields
  AuthenticationOptions copyWith({
    String? title,
    String? subtitle,
    String? description,
    String? negativeButtonText,
    bool? confirmationRequired,
    bool? allowDeviceCredential,
    BiometricStrength? biometricStrength,
  }) {
    return AuthenticationOptions(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      negativeButtonText: negativeButtonText ?? this.negativeButtonText,
      confirmationRequired: confirmationRequired ?? this.confirmationRequired,
      allowDeviceCredential: allowDeviceCredential ?? this.allowDeviceCredential,
      biometricStrength: biometricStrength ?? this.biometricStrength,
    );
  }
}

