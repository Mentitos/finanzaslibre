import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../../l10n/app_localizations.dart';

class PinLockScreen extends StatefulWidget {
  final String correctPin;
  final bool isBiometricEnabled;

  const PinLockScreen({
    super.key,
    required this.correctPin,
    this.isBiometricEnabled = false,
  });

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  int _attempts = 0;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canUseBiometrics = false;

  @override
  void initState() {
    super.initState();

    // animacion de sacudir
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _checkBiometricAvailability();

    if (widget.isBiometricEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _authenticateWithBiometrics();
      });
    }
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      setState(() {
        _canUseBiometrics = canCheck && isDeviceSupported;
      });
    } catch (_) {
      setState(() => _canUseBiometrics = false);
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: l10n.biometricAuthReason,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated && mounted) {
        Navigator.of(context).pop(true);
      }
    } on PlatformException catch (e) {
      debugPrint('Error biometrico: ${e.code}');
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bgColor = Theme.of(context).colorScheme.background;
    
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              _buildLogo(),
              const SizedBox(height: 32),
              _buildTitle(l10n),
              const SizedBox(height: 8),
              _buildSubtitle(l10n),
              const SizedBox(height: 48),
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  );
                },
                child: _buildPinDots(),
              ),
              if (_attempts > 0) ...[
                const SizedBox(height: 16),
                _buildAttemptWarning(l10n),
              ],
              const Spacer(),
              _buildNumPad(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.savings,
        size: 72,
        color: primary,
      ),
    );
  }

  Widget _buildTitle(AppLocalizations l10n) {
    return Text(
      l10n.appName,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onBackground,
      ),
    );
  }

  Widget _buildSubtitle(AppLocalizations l10n) {
    return Text(
      l10n.enterPinToContinue,
      style: TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
      ),
    );
  }

  Widget _buildPinDots() {
    final primary = Theme.of(context).colorScheme.primary;
    final inactive = Theme.of(context).colorScheme.onBackground.withOpacity(0.3);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < _pin.length ? primary : inactive,
          ),
        );
      }),
    );
  }

  Widget _buildAttemptWarning(AppLocalizations l10n) {
    final red = Colors.red;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: red[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, color: red[700], size: 18),
          const SizedBox(width: 8),
          Text(
            l10n.failedAttempts(_attempts),
            style: TextStyle(color: red[700], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildNumPad() {
    return Column(
      children: [
        _buildNumPadRow(['1', '2', '3']),
        const SizedBox(height: 16),
        _buildNumPadRow(['4', '5', '6']),
        const SizedBox(height: 16),
        _buildNumPadRow(['7', '8', '9']),
        const SizedBox(height: 16),
        _buildNumPadRow(['', '0', 'delete']),
      ],
    );
  }

  Widget _buildNumPadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        if (number.isEmpty) {
          if (widget.isBiometricEnabled && _canUseBiometrics) {
            return _buildBiometricButton();
          }
          return const SizedBox(width: 72, height: 72);
        }
        if (number == 'delete') return _buildDeleteButton();
        return _buildNumButton(number);
      }).toList(),
    );
  }

  Widget _buildBiometricButton() {
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: _authenticateWithBiometrics,
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primary.withOpacity(0.1),
        ),
        child: Icon(Icons.fingerprint, size: 32, color: primary),
      ),
    );
  }

  Widget _buildNumButton(String number) {
    final bgColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: () => _onNumberPressed(number),
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          border: Border.all(color: textColor, width: 2),
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: textColor),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    final red = Colors.red;
    return InkWell(
      onTap: _onDeletePressed,
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: red[50],
        ),
        child: Icon(Icons.backspace_outlined, color: red, size: 24),
      ),
    );
  }

  void _onNumberPressed(String number) {
    if (_pin.length < 4) {
      setState(() => _pin += number);
      if (_pin.length == 4) _verifyPin();
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _verifyPin() {
    final l10n = AppLocalizations.of(context)!;
    
    if (_pin == widget.correctPin) {
      Navigator.of(context).pop(true);
    } else {
      _shakeController.forward(from: 0);
      setState(() {
        _attempts++;
        _pin = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.incorrectPin),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      if (_attempts >= 5) _showTooManyAttemptsDialog();
    }
  }

  void _showTooManyAttemptsDialog() {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Row(children: [
          const Icon(Icons.warning, color: Colors.red),
          const SizedBox(width: 8),
          Text(l10n.tooManyAttempts),
        ]),
        content: Text(l10n.tooManyAttemptsMessage),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              SystemNavigator.pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.understood),
          ),
        ],
      ),
    );
  }
}