/// Reusable Biometric Authentication Widget
///
/// This widget provides a ready-to-use biometric authentication button
/// with built-in error handling and loading states.

import 'package:flutter/material.dart';
import 'package:flutter_biometric_auth_plus/flutter_biometric_auth_plus.dart';

/// A customizable biometric authentication button widget
class BiometricAuthButton extends StatefulWidget {
  /// Callback when authentication succeeds
  final VoidCallback onAuthSuccess;

  /// Callback when authentication fails
  final Function(String error)? onAuthFailure;

  /// Button label text
  final String? label;

  /// Authentication dialog title
  final String dialogTitle;

  /// Authentication dialog subtitle
  final String? dialogSubtitle;

  /// Authentication dialog description
  final String? dialogDescription;

  /// Allow device credential (PIN/Pattern/Password) as fallback
  final bool allowDeviceCredential;

  /// Required biometric strength ('strong', 'weak', 'any')
  final String biometricStrength;

  /// Require explicit user confirmation
  final bool confirmationRequired;

  /// Custom button color
  final Color? buttonColor;

  /// Custom button icon
  final IconData? icon;

  const BiometricAuthButton({
    Key? key,
    required this.onAuthSuccess,
    this.onAuthFailure,
    this.label,
    this.dialogTitle = 'Authentication Required',
    this.dialogSubtitle,
    this.dialogDescription,
    this.allowDeviceCredential = false,
    this.biometricStrength = 'strong',
    this.confirmationRequired = false,
    this.buttonColor,
    this.icon,
  }) : super(key: key);

  @override
  State<BiometricAuthButton> createState() => _BiometricAuthButtonState();
}

class _BiometricAuthButtonState extends State<BiometricAuthButton> {
  final _biometricAuth = FlutterBiometricAuthPlus();
  bool _isLoading = false;
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  /// Check if biometric authentication is available
  Future<void> _checkAvailability() async {
    try {
      final isAvailable = widget.biometricStrength == 'strong'
          ? await _biometricAuth.canAuthenticateWithBiometricsStrong()
          : await _biometricAuth.hasEnrolledBiometrics();

      if (mounted) {
        setState(() => _isAvailable = isAvailable);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAvailable = false);
      }
    }
  }

  /// Perform authentication
  Future<void> _authenticate() async {
    if (!_isAvailable) {
      widget.onAuthFailure?.call('Biometric authentication not available');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _biometricAuth.authenticate(
        title: widget.dialogTitle,
        subtitle: widget.dialogSubtitle,
        description: widget.dialogDescription,
        allowDeviceCredential: widget.allowDeviceCredential,
        biometricStrength: widget.biometricStrength,
        confirmationRequired: widget.confirmationRequired,
      );

      final authResult = BiometricAuthResult.fromMap(result);

      if (mounted) {
        setState(() => _isLoading = false);

        if (authResult.success) {
          widget.onAuthSuccess();
        } else {
          widget.onAuthFailure?.call(
            authResult.errorMessage ?? 'Authentication failed',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        widget.onAuthFailure?.call('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = widget.buttonColor ?? theme.colorScheme.primary;
    final icon = widget.icon ?? Icons.fingerprint;
    final label = widget.label ?? 'Authenticate with Biometric';

    if (!_isAvailable) {
      return Opacity(
        opacity: 0.5,
        child: FilledButton.icon(
          onPressed: null,
          icon: Icon(Icons.block),
          label: Text('Biometric Not Available'),
        ),
      );
    }

    if (_isLoading) {
      return FilledButton.icon(
        onPressed: null,
        icon: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.onPrimary,
            ),
          ),
        ),
        label: Text('Authenticating...'),
      );
    }

    return FilledButton.icon(
      onPressed: _authenticate,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: buttonColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}

/// Example usage:
///
/// ```dart
/// BiometricAuthButton(
///   dialogTitle: 'Login Required',
///   dialogSubtitle: 'Verify your identity',
///   allowDeviceCredential: true,
///   onAuthSuccess: () {
///     // Navigate to home screen
///     Navigator.pushReplacement(context, ...);
///   },
///   onAuthFailure: (error) {
///     // Show error message
///     ScaffoldMessenger.of(context).showSnackBar(
///       SnackBar(content: Text(error)),
///     );
///   },
/// )
/// ```

