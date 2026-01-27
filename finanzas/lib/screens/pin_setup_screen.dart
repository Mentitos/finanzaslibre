import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../l10n/app_localizations.dart';

class PinSetupScreen extends StatefulWidget {
  final bool isChanging;
  final String? currentPin;

  const PinSetupScreen({super.key, this.isChanging = false, this.currentPin});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _isVerifyingCurrent = false;
  bool _biometricEnabled = false;

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  bool get _needsCurrentPin => widget.isChanging && widget.currentPin != null;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    if (_needsCurrentPin) {
      _isVerifyingCurrent = true;
    }
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      bool hasBiometrics = false;
      if (canCheck && isDeviceSupported) {
        final availableBiometrics = await _localAuth.getAvailableBiometrics();
        hasBiometrics = availableBiometrics.isNotEmpty;
      }

      setState(() {
        _canCheckBiometrics = canCheck && isDeviceSupported;
        _biometricEnabled = hasBiometrics;
      });
    } catch (e) {
      setState(() {
        _canCheckBiometrics = false;
        _biometricEnabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        title: Text(_getTitleText(l10n)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      _buildIcon(),
                      const SizedBox(height: 32),
                      _buildTitle(l10n),
                      const SizedBox(height: 48),
                      _buildPinDots(),
                      if (!_isVerifyingCurrent && !_isConfirming) ...[
                        const SizedBox(height: 32),
                        _buildBiometricToggle(l10n),
                      ],
                      const SizedBox(height: 48),
                      _buildNumPad(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTitleText(AppLocalizations l10n) {
    if (_isVerifyingCurrent) return l10n.currentPin;
    if (_isConfirming) return l10n.confirmPin;
    return widget.isChanging ? l10n.changePin : l10n.createPin;
  }

  Widget _buildIcon() {
    final primaryColor = Theme.of(
      context,
    ).colorScheme.primary.withValues(alpha: 0.8);
    final bgColor = Theme.of(
      context,
    ).colorScheme.primary.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(
        _isVerifyingCurrent
            ? Icons.lock_outline
            : _isConfirming
            ? Icons.lock_reset
            : Icons.lock_open,
        size: 64,
        color: primaryColor,
      ),
    );
  }

  Widget _buildTitle(AppLocalizations l10n) {
    String text;
    if (_isVerifyingCurrent) {
      text = l10n.enterCurrentPin;
    } else if (_isConfirming) {
      text = l10n.confirmNewPin;
    } else {
      text = l10n.createPinDigits;
    }

    return Text(
      text,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildBiometricToggle(AppLocalizations l10n) {
    if (!_canCheckBiometrics) return const SizedBox.shrink();

    final primaryColor = Theme.of(context).colorScheme.primary;
    final borderColor = primaryColor.withValues(alpha: 0.3);
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.fingerprint, color: primaryColor, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.biometricUnlock,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.useFingerprintOrFace,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _biometricEnabled,
            onChanged: (value) => setState(() => _biometricEnabled = value),
            activeThumbColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPinDots() {
    final currentPin = _isConfirming ? _confirmPin : _pin;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final inactiveColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.3);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < currentPin.length ? primaryColor : inactiveColor,
          ),
        );
      }),
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
          return const SizedBox(width: 72, height: 72);
        }

        if (number == 'delete') {
          return _buildDeleteButton();
        }

        return _buildNumButton(number);
      }).toList(),
    );
  }

  Widget _buildNumButton(String number) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final bgColor = Theme.of(context).colorScheme.surface;

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
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return InkWell(
      onTap: _onDeletePressed,
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red[50],
        ),
        child: const Center(
          child: Icon(Icons.backspace_outlined, color: Colors.red, size: 24),
        ),
      ),
    );
  }

  void _onNumberPressed(String number) {
    if (_isVerifyingCurrent) {
      if (_pin.length < 4) {
        setState(() => _pin += number);
        if (_pin.length == 4) {
          _verifyCurrentPin();
        }
      }
    } else if (_isConfirming) {
      if (_confirmPin.length < 4) {
        setState(() => _confirmPin += number);
        if (_confirmPin.length == 4) {
          _verifyConfirmation();
        }
      }
    } else {
      if (_pin.length < 4) {
        setState(() => _pin += number);
        if (_pin.length == 4) {
          _moveToConfirmation();
        }
      }
    }
  }

  void _onDeletePressed() {
    if (_isConfirming) {
      if (_confirmPin.isNotEmpty) {
        setState(
          () => _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1),
        );
      }
    } else {
      if (_pin.isNotEmpty) {
        setState(() => _pin = _pin.substring(0, _pin.length - 1));
      }
    }
  }

  void _verifyCurrentPin() {
    final l10n = AppLocalizations.of(context)!;
    if (_pin == widget.currentPin) {
      setState(() {
        _isVerifyingCurrent = false;
        _pin = '';
      });
    } else {
      _showError(l10n.incorrectPin);
      setState(() => _pin = '');
    }
  }

  void _moveToConfirmation() {
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() => _isConfirming = true);
    });
  }

  void _verifyConfirmation() {
    final l10n = AppLocalizations.of(context)!;
    if (_pin == _confirmPin) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        Navigator.pop(context, {
          'pin': _pin,
          'biometricEnabled': _biometricEnabled,
        });
      });
    } else {
      _showError(l10n.pinsDoNotMatch);
      setState(() {
        _confirmPin = '';
        _isConfirming = false;
        _pin = '';
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
