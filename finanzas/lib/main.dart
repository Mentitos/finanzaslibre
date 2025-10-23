import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/savings_screen.dart';
import 'screens/pin_lock_screen.dart';
import 'services/savings_data_manager.dart';
import 'services/user_manager.dart';
import 'services/google_drive_service.dart';
import 'services/auto_backup_service.dart';
import 'services/backup_scheduler.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await UserManager.initialize();
  
  SavingsDataManager.init();
  final dataManager = SavingsDataManager();
  await dataManager.initialize();

  await GoogleDriveService().initialize();
  await AutoBackupService().initialize();
  await NotificationService().initialize();
  
  final prefs = await SharedPreferences.getInstance();
  final themeModeString = prefs.getString('theme_mode') ?? 'system';

  ThemeMode initialTheme;
  switch (themeModeString) {
    case 'light':
      initialTheme = ThemeMode.light;
      break;
    case 'dark':
      initialTheme = ThemeMode.dark;
      break;
    default:
      initialTheme = ThemeMode.system;
  }

  runApp(MyApp(
    initialTheme: initialTheme,
    dataManager: dataManager,
  ));
}

class MyApp extends StatefulWidget {
  final ThemeMode initialTheme;
  final SavingsDataManager dataManager;

  const MyApp({
    super.key,
    required this.initialTheme,
    required this.dataManager,
  });

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) {
    return context.findAncestorStateOfType<_MyAppState>()!;
  }
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;
  Locale _locale = const Locale('es');

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialTheme;
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'system';

    if (languageCode == 'system') {
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      String effectiveLang = (systemLocale == 'es' || systemLocale == 'en') ? systemLocale : 'en';
      setState(() {
        _locale = Locale(effectiveLang);
      });
    } else {
      setState(() {
        _locale = Locale(languageCode);
      });
    }
  }

  void changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);

    if (languageCode == 'system') {
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      String effectiveLang = (systemLocale == 'es' || systemLocale == 'en') ? systemLocale : 'en';
      setState(() {
        _locale = Locale(effectiveLang);
      });
    } else {
      setState(() {
        _locale = Locale(languageCode);
      });
    }
  }

  void toggleTheme() async {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.dark;
      }
    });

    final prefs = await SharedPreferences.getInstance();
    String modeString = 'system';
    if (_themeMode == ThemeMode.light) modeString = 'light';
    if (_themeMode == ThemeMode.dark) modeString = 'dark';
    await prefs.setString('theme_mode', modeString);
  }

  @override
  Widget build(BuildContext context) {
    return BackupSchedulerListener(
      dataManager: widget.dataManager,
      child: MaterialApp(
        title: 'Mis Ahorros',
        debugShowCheckedModeBanner: false,
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: _themeMode,
        locale: _locale,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es'),
          Locale('en'),
        ],
        home: AuthWrapper(dataManager: widget.dataManager),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
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
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      primarySwatch: Colors.green,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        color: Colors.grey[850],
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  final SavingsDataManager dataManager;
  
  const AuthWrapper({
    super.key,
    required this.dataManager,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final UserManager _userManager = UserManager();
  
  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _needsPin = false;
  String? _savedPin;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
  }

  Future<void> _checkPinStatus() async {
    final pinEnabled = await widget.dataManager.isPinEnabled();
    final pin = await widget.dataManager.loadPin();
    final biometricStatus = await widget.dataManager.loadBiometricEnabled();

    setState(() {
      _needsPin = pinEnabled && pin != null;
      _savedPin = pin;
      _isBiometricEnabled = biometricStatus;
      _isAuthenticated = !_needsPin;
      _isLoading = false;
    });

    if (_needsPin && _savedPin != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPinLock();
      });
    }
  }

  Future<void> _showPinLock() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PinLockScreen(
          correctPin: _savedPin!,
          isBiometricEnabled: _isBiometricEnabled,
        ),
        fullscreenDialog: true,
      ),
    );

    if (result == true) {
      setState(() {
        _isAuthenticated = true;
      });
    } else {
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

    return SavingsScreen(userManager: _userManager);
  }
}