import 'package:flutter/material.dart';
import 'screens/savings_screen.dart';
import 'screens/pin_lock_screen.dart';
import 'services/savings_data_manager.dart';

void main() {
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

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
  }

  Future<void> _checkPinStatus() async {
    final pinEnabled = await _dataManager.isPinEnabled();
    final pin = await _dataManager.loadPin();

    setState(() {
      _needsPin = pinEnabled && pin != null;
      _savedPin = pin;
      _isAuthenticated = !_needsPin; // Si no necesita PIN, ya está autenticado
      _isLoading = false;
    });

    // Si necesita PIN, mostrarlo
    if (_needsPin && _savedPin != null && mounted) {
      _showPinLock();
    }
  }

  Future<void> _showPinLock() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PinLockScreen(correctPin: _savedPin!),
        fullscreenDialog: true,
      ),
    );

    if (result == true) {
      setState(() {
        _isAuthenticated = true;
      });
    } else {
      // Si el usuario no se autenticó correctamente, cerrar la app
      // En producción podrías usar SystemNavigator.pop()
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
      // Mostrar pantalla de bloqueo mientras espera autenticación
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'App bloqueada',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SavingsScreen();
  }
}