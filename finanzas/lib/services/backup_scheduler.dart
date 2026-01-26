import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'auto_backup_service.dart';
import 'savings_data_manager.dart';

class BackupSchedulerListener extends StatefulWidget {
  final Widget child;
  final SavingsDataManager dataManager;

  const BackupSchedulerListener({
    super.key,
    required this.child,
    required this.dataManager,
  });

  @override
  State<BackupSchedulerListener> createState() =>
      _BackupSchedulerListenerState();
}

class _BackupSchedulerListenerState extends State<BackupSchedulerListener>
    with WidgetsBindingObserver {
  final AutoBackupService _autoBackupService = AutoBackupService();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  DateTime? _lastCheck;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupNotificationListener();
    _schedulePeriodicCheck();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  void _setupNotificationListener() {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('📱 Notificación recibida: ${response.id}');

        if (response.id == 1) {
          _executeBackupIfNeeded();
        }
      },
    );
  }

  void _schedulePeriodicCheck() {
    _timer?.cancel();
    _timer = Timer(const Duration(hours: 1), () {
      if (mounted) {
        _checkIfBackupNeeded();
        _schedulePeriodicCheck();
      }
    });
  }

  Future<void> _checkIfBackupNeeded() async {
    try {
      final enabled = await _autoBackupService.isAutoBackupEnabled();
      if (!enabled) return;

      final backupTime = await _autoBackupService.getAutoBackupTime();
      final now = DateTime.now();

      if (now.hour == backupTime.hour &&
          (now.minute >= backupTime.minute - 5 &&
              now.minute <= backupTime.minute + 5)) {
        if (_lastCheck != null && now.difference(_lastCheck!).inHours < 1) {
          return;
        }

        await _executeBackupIfNeeded();
        _lastCheck = now;
      }
    } catch (e) {
      debugPrint('❌ Error verificando backup: $e');
    }
  }

  Future<void> _executeBackupIfNeeded() async {
    try {
      final enabled = await _autoBackupService.isAutoBackupEnabled();
      if (!enabled) {
        debugPrint('ℹ️ Backup automático deshabilitado');
        return;
      }

      final lastBackup = await _autoBackupService.getLastAutoBackupTime();
      final now = DateTime.now();

      if (lastBackup != null) {
        final difference = now.difference(lastBackup);
        if (difference.inHours < 23) {
          debugPrint(
            'ℹ️ Ya existe un backup reciente (${difference.inHours}h atrás)',
          );
          return;
        }
      }

      debugPrint('🔄 Ejecutando backup automático programado...');
      await _autoBackupService.executeAutoBackup(widget.dataManager);
    } catch (e) {
      debugPrint('❌ Error ejecutando backup: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      debugPrint('📱 App resumed - verificando backups pendientes...');
      _checkIfBackupNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
