import 'package:biometric_auth_advanced/biometric_auth_advanced.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biometric Auth Advanced Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const BiometricAuthHomePage(),
    );
  }
}

class BiometricAuthHomePage extends StatefulWidget {
  const BiometricAuthHomePage({super.key});

  @override
  State<BiometricAuthHomePage> createState() => _BiometricAuthHomePageState();
}

class _BiometricAuthHomePageState extends State<BiometricAuthHomePage> with TickerProviderStateMixin {
  final _biometricAuth = BiometricAuthAdvanced();

  // Biometric capability states
  bool _hasHardware = false;
  bool _hasEnrolledBiometrics = false;
  bool _canUseStrongBiometric = false;
  bool _canUseWeakBiometric = false;
  bool _hasDeviceCredential = false;
  List<String> _availableBiometrics = [];

  // Authentication result state
  String? _authResult;
  bool? _lastAuthSuccess;

  // Loading state
  bool _isLoading = false;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _successController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadBiometricInfo();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _successController.dispose();
    super.dispose();
  }

  /// Initialize animation controllers
  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _successController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  /// Load biometric information from device
  Future<void> _loadBiometricInfo() async {
    setState(() => _isLoading = true);

    try {
      final info = await _biometricAuth.getBiometricInfo();
      final availableBiometrics = await _biometricAuth.getAvailableBiometrics();

      setState(() {
        _hasHardware = info['hasHardware'] as bool? ?? false;
        _hasEnrolledBiometrics = info['hasEnrolledBiometrics'] as bool? ?? false;
        _canUseStrongBiometric = info['supportsStrongBiometric'] as bool? ?? false;
        _canUseWeakBiometric = info['supportsWeakBiometric'] as bool? ?? false;
        _hasDeviceCredential = info['hasDeviceCredential'] as bool? ?? false;
        _availableBiometrics = availableBiometrics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _authResult = 'Error loading biometric info: $e';
        _isLoading = false;
      });
    }
  }

  /// Authenticate with biometrics
  Future<void> _authenticate({
    bool allowDeviceCredential = false,
    String biometricStrength = 'strong',
  }) async {
    setState(() {
      _isLoading = true;
      _authResult = null;
      _lastAuthSuccess = null;
    });

    try {
      final result = await _biometricAuth.authenticate(
        title: 'Biometric Authentication',
        subtitle: 'Verify your identity',
        description: 'Place your finger on the sensor or look at the camera',
        negativeButtonText: 'Cancel',
        confirmationRequired: false,
        allowDeviceCredential: allowDeviceCredential,
        biometricStrength: biometricStrength,
      );

      final authResult = BiometricAuthResult.fromMap(result);

      setState(() {
        _lastAuthSuccess = authResult.success;
        _isLoading = false;

        if (authResult.success) {
          _authResult = '✅ Authentication successful!\n'
              'Method: ${authResult.authenticationMethod.name}\n'
              'Device credential used: ${authResult.usedDeviceCredential}';
          _successController.forward(from: 0);
        } else {
          _authResult = '❌ Authentication failed\n'
              'Error: ${authResult.errorCode}\n'
              'Message: ${authResult.errorMessage}';
        }
      });
    } on PlatformException catch (e) {
      setState(() {
        _lastAuthSuccess = false;
        _authResult = '❌ Platform error: ${e.message}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(
                colorScheme.primaryContainer.r.toInt(),
                colorScheme.primaryContainer.g.toInt(),
                colorScheme.primaryContainer.b.toInt(),
                0.3,
              ),
              Color.fromRGBO(
                colorScheme.secondaryContainer.r.toInt(),
                colorScheme.secondaryContainer.g.toInt(),
                colorScheme.secondaryContainer.b.toInt(),
                0.3,
              ),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading && _authResult == null
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    // App Bar
                    SliverAppBar.large(
                      backgroundColor: Colors.transparent,
                      title: const Text(
                        'Biometric Auth Plus',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadBiometricInfo,
                          tooltip: 'Refresh',
                        ),
                      ],
                    ),

                    // Content
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Hero Section
                          _buildHeroSection(colorScheme),
                          const SizedBox(height: 24),

                          // Device Capabilities
                          _buildCapabilitiesCard(colorScheme),
                          const SizedBox(height: 16),

                          // Available Biometric Types
                          _buildBiometricTypesCard(colorScheme),
                          const SizedBox(height: 16),

                          // Authentication Actions
                          _buildAuthenticationActions(colorScheme),
                          const SizedBox(height: 16),

                          // Result Display
                          if (_authResult != null) _buildResultCard(colorScheme),

                          const SizedBox(height: 32),
                        ]),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// Build hero section with main biometric icon
  Widget _buildHeroSection(ColorScheme colorScheme) {
    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.05).animate(
                CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fingerprint,
                  size: 80,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Advanced Biometric Security',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Secure your app with fingerprint, face, iris, or device credentials',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build device capabilities card
  Widget _buildCapabilitiesCard(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Device Capabilities',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildCapabilityRow(
              'Biometric Hardware',
              _hasHardware,
              Icons.hardware,
              colorScheme,
            ),
            _buildCapabilityRow(
              'Enrolled Biometrics',
              _hasEnrolledBiometrics,
              Icons.check_circle_outline,
              colorScheme,
            ),
            _buildCapabilityRow(
              'Strong Biometric (Class 3)',
              _canUseStrongBiometric,
              Icons.security,
              colorScheme,
            ),
            _buildCapabilityRow(
              'Weak Biometric (Class 2)',
              _canUseWeakBiometric,
              Icons.shield,
              colorScheme,
            ),
            _buildCapabilityRow(
              'Device Credential (PIN/Pattern)',
              _hasDeviceCredential,
              Icons.lock,
              colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  /// Build capability row
  Widget _buildCapabilityRow(
    String label,
    bool isAvailable,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isAvailable
                  ? colorScheme.primaryContainer
                  : colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAvailable ? Icons.check : Icons.close,
                  size: 16,
                  color: isAvailable
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  isAvailable ? 'Yes' : 'No',
                  style: TextStyle(
                    color: isAvailable
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build available biometric types card
  Widget _buildBiometricTypesCard(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 12,
              children: [
                Icon(Icons.face, color: colorScheme.primary),
                Expanded(
                  child: Text(
                    'Available Biometric Types',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_availableBiometrics.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 48,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No biometrics enrolled',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ],
                  ),
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableBiometrics.map((type) {
                  return _buildBiometricTypeChip(type, colorScheme);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  /// Build biometric type chip
  Widget _buildBiometricTypeChip(String type, ColorScheme colorScheme) {
    IconData icon;
    String label;

    switch (type.toLowerCase()) {
      case 'fingerprint':
        icon = Icons.fingerprint;
        label = 'Fingerprint';
        break;
      case 'face':
        icon = Icons.face;
        label = 'Face Recognition';
        break;
      case 'iris':
        icon = Icons.remove_red_eye;
        label = 'Iris Recognition';
        break;
      default:
        icon = Icons.security;
        label = type;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.secondary.withAlpha(30),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: colorScheme.onSecondaryContainer, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build authentication actions section
  Widget _buildAuthenticationActions(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.touch_app, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Authentication Methods',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Strong Biometric Button
            _buildAuthButton(
              label: 'Strong Biometric Only',
              subtitle: 'Fingerprint, 3D Face, Iris (Class 3)',
              icon: Icons.fingerprint,
              color: colorScheme.primary,
              enabled: _canUseStrongBiometric,
              onPressed: () => _authenticate(
                allowDeviceCredential: false,
                biometricStrength: 'strong',
              ),
            ),
            const SizedBox(height: 12),

            // Weak Biometric Button
            _buildAuthButton(
              label: 'Weak Biometric',
              subtitle: '2D Face unlock, any biometric (Class 2)',
              icon: Icons.face,
              color: colorScheme.secondary,
              enabled: _canUseWeakBiometric,
              onPressed: () => _authenticate(
                allowDeviceCredential: false,
                biometricStrength: 'weak',
              ),
            ),
            const SizedBox(height: 12),

            // Biometric + Device Credential Button
            _buildAuthButton(
              label: 'Biometric + Device Credential',
              subtitle: 'With PIN/Pattern/Password fallback',
              icon: Icons.lock_open,
              color: colorScheme.tertiary,
              enabled: _hasEnrolledBiometrics || _hasDeviceCredential,
              onPressed: () => _authenticate(
                allowDeviceCredential: true,
                biometricStrength: 'strong',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build authentication button
  Widget _buildAuthButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Material(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withAlpha(70),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build result card
  Widget _buildResultCard(ColorScheme colorScheme) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
      ),
      child: Card(
        color: _lastAuthSuccess == true
            ? colorScheme.primaryContainer
            : colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                _lastAuthSuccess == true ? Icons.check_circle : Icons.error,
                size: 48,
                color: _lastAuthSuccess == true
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onErrorContainer,
              ),
              const SizedBox(height: 16),
              Text(
                _authResult ?? '',
                style: TextStyle(
                  color: _lastAuthSuccess == true
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onErrorContainer,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
