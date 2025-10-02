import 'package:flutter/material.dart';
import 'screens/savings_screen.dart';
import 'screens/pin_lock_screen.dart';
import 'services/savings_data_manager.dart'; // Asegúrate de que este servicio existe

void main() {
  // Inicializamos el gestor de datos para SharedPreferences o similar
  SavingsDataManager.init(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mis Ahorros',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final SavingsDataManager _dataManager = SavingsDataManager();
  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _needsPin = false;
  String? _savedPin;
  // ************* CORRECCIÓN 1: Añadir estado para biometría *************
  bool _isBiometricEnabled = false; 

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
  }

  Future<void> _checkPinStatus() async {
    final pinEnabled = await _dataManager.isPinEnabled();
    final pin = await _dataManager.loadPin();
    
    // ************* CORRECCIÓN 2: Cargar el estado de biometría *************
    final biometricStatus = await _dataManager.loadBiometricEnabled();

    setState(() {
      _needsPin = pinEnabled && pin != null;
      _savedPin = pin;
      _isBiometricEnabled = biometricStatus; // <--- Cargar el estado
      _isAuthenticated = !_needsPin; 
      _isLoading = false;
    });

    // Si necesita PIN, mostrarlo
    if (_needsPin && _savedPin != null && mounted) {
      // Usamos addPostFrameCallback para asegurar que el widget se haya dibujado
      // antes de intentar hacer una navegación (push).
      WidgetsBinding.instance.addPostFrameCallback((_) {
         _showPinLock();
      });
    }
  }

  Future<void> _showPinLock() async {
    // ************* CORRECCIÓN 3: Pasar el estado de biometría a PinLockScreen *************
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PinLockScreen(
          correctPin: _savedPin!,
          isBiometricEnabled: _isBiometricEnabled, // <--- ¡Valor corregido!
        ),
        fullscreenDialog: true,
      ),
    );

    if (result == true) {
      setState(() {
        _isAuthenticated = true;
      });
    } else {
      // Cerrar la app si falla la autenticación (ejemplo: 5 intentos fallidos)
      setState(() {
        _isAuthenticated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAuthenticated && _needsPin) {
      // Mostrar una pantalla básica mientras PinLockScreen está sobre ella
      return Scaffold(
        appBar: AppBar(title: const Text('Bloqueado')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Ingresa el PIN'),
            ],
          ),
        ),
      );
    }

    return const SavingsScreen();
  }
}
