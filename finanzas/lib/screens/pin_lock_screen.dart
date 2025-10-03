import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para SystemNavigator.pop
import 'package:local_auth/local_auth.dart';

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
    // 1. Configuración de animación (corregida)
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this, 
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // 2. Comprobar y autenticar con biometría
    if (widget.isBiometricEnabled) {
      // Usamos addPostFrameCallback para asegurar que el contexto (BuildContext) es válido
      // y no hay problemas al mostrar el diálogo de autenticación justo después de la navegación.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkBiometrics(); 
      });
    }
  }

  // 3. Método para verificar si el dispositivo soporta biometría
  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (mounted) {
        setState(() {
          _canUseBiometrics = canCheck && isDeviceSupported;
        });
      }

      // 4. Intenta autenticar automáticamente si está disponible
      if (_canUseBiometrics) {
        _authenticateWithBiometrics();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _canUseBiometrics = false);
      }
    }
  }
  
  // 5. Nuevo método para autenticación biométrica
  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      authenticated = await _localAuth.authenticate(
        localizedReason: 'Accede usando tu huella o Face ID',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      // Manejar el error si la autenticación falla por un problema del sistema
      debugPrint('Biometric Error: ${e.code}');
    }

    if (authenticated) {
      // Autenticación exitosa, cierra la pantalla de bloqueo
      if (mounted) {
        // Retornar 'true' para indicar éxito al AuthWrapper
        Navigator.of(context).pop(true); 
      }
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              _buildAppLogo(),
              const SizedBox(height: 32),
              _buildTitle(),
              const SizedBox(height: 8),
              _buildSubtitle(),
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
                _buildAttemptWarning(),
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

  Widget _buildAppLogo() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.savings,
        size: 72,
        color: Colors.green,
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Mis Ahorros',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Ingresa tu PIN para continuar',
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < _pin.length ? Colors.green : Colors.grey[300],
          ),
        );
      }),
    );
  }

  Widget _buildAttemptWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, color: Colors.red[700], size: 18),
          const SizedBox(width: 8),
          Text(
            'Intentos fallidos: $_attempts',
            style: TextStyle(
              color: Colors.red[700],
              fontWeight: FontWeight.w500,
            ),
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
          // Si el usuario habilitó biometría Y el dispositivo es compatible
          if (widget.isBiometricEnabled && _canUseBiometrics) {
            return _buildBiometricButton(); 
          }
          return const SizedBox(width: 72, height: 72);
        }

        if (number == 'delete') {
          return _buildDeleteButton();
        }

        return _buildNumButton(number);
      }).toList(),
    );
  }

  Widget _buildBiometricButton() {
    return InkWell(
      onTap: _authenticateWithBiometrics,
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green[50],
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.fingerprint,
            color: Colors.green[700],
            size: 32,
          ),
        ),
      ),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
    if (_pin.length < 4) {
      setState(() => _pin += number);
      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _verifyPin() {
    if (_pin == widget.correctPin) {
      // Retornar 'true' para indicar éxito al AuthWrapper
      Navigator.of(context).pop(true);
    } else {
      _shakeController.forward(from: 0);
      setState(() {
        _attempts++;
        _pin = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN incorrecto'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      if (_attempts >= 5) {
        _showTooManyAttemptsDialog();
      }
    }
  }

  void _showTooManyAttemptsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Demasiados intentos'),
          ],
        ),
        content: const Text(
          'Has fallado 5 intentos. Por seguridad, la aplicación se cerrará.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              // Cierra el diálogo y luego cierra la aplicación.
              Navigator.of(context).pop(); 
              SystemNavigator.pop(); 
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
