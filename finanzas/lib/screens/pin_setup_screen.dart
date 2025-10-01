import 'package:flutter/material.dart';

class PinSetupScreen extends StatefulWidget {
  final bool isChanging;
  final String? currentPin;

  const PinSetupScreen({
    super.key,
    this.isChanging = false,
    this.currentPin,
  });

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _isVerifyingCurrent = false;

  bool get _needsCurrentPin => widget.isChanging && widget.currentPin != null;

  @override
  void initState() {
    super.initState();
    // Si necesita verificar el PIN actual primero
    if (_needsCurrentPin) {
      _isVerifyingCurrent = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_getTitleText()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              _buildIcon(),
              const SizedBox(height: 32),
              _buildTitle(),
              const SizedBox(height: 48),
              _buildPinDots(),
              const Spacer(),
              _buildNumPad(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitleText() {
    if (_isVerifyingCurrent) return 'PIN actual';
    if (_isConfirming) return 'Confirmar PIN';
    return widget.isChanging ? 'Cambiar PIN' : 'Crear PIN';
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _isVerifyingCurrent
            ? Icons.lock_outline
            : _isConfirming
                ? Icons.lock_reset
                : Icons.lock_open,
        size: 64,
        color: Colors.green,
      ),
    );
  }

  Widget _buildTitle() {
    String text;
    if (_isVerifyingCurrent) {
      text = 'Ingresa tu PIN actual';
    } else if (_isConfirming) {
      text = 'Confirma tu nuevo PIN';
    } else {
      text = 'Crea un PIN de 4 dígitos';
    }

    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPinDots() {
    final currentPin = _isConfirming ? _confirmPin : _pin;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < currentPin.length ? Colors.green : Colors.grey[300],
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
    return InkWell(
      onTap: () => _onNumberPressed(number),
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[100],
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
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
          child: Icon(
            Icons.backspace_outlined,
            color: Colors.red,
            size: 24,
          ),
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
        setState(() => _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1));
      }
    } else {
      if (_pin.isNotEmpty) {
        setState(() => _pin = _pin.substring(0, _pin.length - 1));
      }
    }
  }

  void _verifyCurrentPin() {
    if (_pin == widget.currentPin) {
      setState(() {
        _isVerifyingCurrent = false;
        _pin = '';
      });
    } else {
      _showError('PIN incorrecto');
      setState(() => _pin = '');
    }
  }

  void _moveToConfirmation() {
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() => _isConfirming = true);
    });
  }

  void _verifyConfirmation() {
    if (_pin == _confirmPin) {
      Future.delayed(const Duration(milliseconds: 200), () {
        Navigator.pop(context, _pin);
      });
    } else {
      _showError('Los PINs no coinciden');
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