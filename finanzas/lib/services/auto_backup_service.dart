import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'google_drive_service.dart';
import 'savings_data_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class AutoBackupService {
  static final AutoBackupService _instance = AutoBackupService._internal();
  factory AutoBackupService() => _instance;
  AutoBackupService._internal();

  static const String _autoBackupEnabledKey = 'auto_backup_enabled';
  static const String _autoBackupHourKey = 'auto_backup_hour';
  static const String _autoBackupMinuteKey = 'auto_backup_minute';
  static const String _lastAutoBackupKey = 'last_auto_backup_timestamp';
  static const int _maxAutoBackups = 2;
  static const int _maxManualBackups = 2;

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(initSettings);
      _isInitialized = true;
      debugPrint('✅ AutoBackupService inicializado');

      await _scheduleAutoBackupIfEnabled();
    } catch (e) {
      debugPrint('❌ Error inicializando AutoBackupService: $e');
    }
  }

  Future<bool> isAutoBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoBackupEnabledKey) ?? false;
  }

  Future<TimeOfDay> getAutoBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_autoBackupHourKey) ?? 23;
    final minute = prefs.getInt(_autoBackupMinuteKey) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> setAutoBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoBackupEnabledKey, enabled);
    
    if (enabled) {
      await _scheduleAutoBackup();
      debugPrint('✅ Backup automático habilitado');
    } else {
      await _cancelAutoBackup();
      debugPrint('❌ Backup automático deshabilitado');
    }
  }

  
  Future<void> setAutoBackupTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_autoBackupHourKey, time.hour);
    await prefs.setInt(_autoBackupMinuteKey, time.minute);
    
    
    final enabled = await isAutoBackupEnabled();
    if (enabled) {
      await _scheduleAutoBackup();
    }
    
    debugPrint('✅ Hora de backup configurada: ${time.hour}:${time.minute}');
  }

 
  Future<void> _scheduleAutoBackupIfEnabled() async {
    final enabled = await isAutoBackupEnabled();
    if (enabled) {
      await _scheduleAutoBackup();
    }
  }

  
  Future<void> _scheduleAutoBackup() async {
    try {
      final time = await getAutoBackupTime();
      final scheduledDate = _nextInstanceOfTime(time.hour, time.minute);
      
      await _notifications.zonedSchedule(
        1,
        '🔄 Backup Automático',
        'Creando respaldo de tus datos...',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'auto_backup',
            'Backup Automático',
            channelDescription: 'Notificaciones de backup automático',
            importance: Importance.low,
            priority: Priority.low,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: false,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('✅ Backup automático programado: ${time.hour}:${time.minute}');
    } catch (e) {
      debugPrint('❌ Error programando backup: $e');
    }
  }

  Future<void> _cancelAutoBackup() async {
    try {
      await _notifications.cancel(1);
      debugPrint('✅ Backup automático cancelado');
    } catch (e) {
      debugPrint('❌ Error cancelando backup: $e');
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<bool> executeAutoBackup(SavingsDataManager dataManager) async {
    try {
      debugPrint('🔄 Ejecutando backup automático...');
      
      final driveService = GoogleDriveService();
      
      if (!driveService.isSignedIn) {
        debugPrint('⚠️ No hay sesión activa en Google Drive');
        return false;
      }

      final data = await dataManager.exportData();
      
      
      final fileName = 'finanzas_libre_auto_${DateTime.now().millisecondsSinceEpoch}.json';
      final success = await driveService.uploadBackup(data, isAuto: true, customFileName: fileName);
      
      if (success) {
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_lastAutoBackupKey, DateTime.now().millisecondsSinceEpoch);
        
        
        await _cleanupOldAutoBackups();
        
        debugPrint('✅ Backup automático completado');
        
        
        await _showSuccessNotification();
        
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Error en backup automático: $e');
      await _showErrorNotification();
      return false;
    }
  }

  
  Future<bool> executeManualBackup(SavingsDataManager dataManager) async {
    try {
      debugPrint('🔄 Ejecutando backup manual...');
      
      final driveService = GoogleDriveService();
      
      if (!driveService.isSignedIn) {
        debugPrint('⚠️ No hay sesión activa en Google Drive');
        return false;
      }

      final data = await dataManager.exportData();
      
      final fileName = 'finanzas_libre_manual_${DateTime.now().millisecondsSinceEpoch}.json';
      final success = await driveService.uploadBackup(data, isAuto: false, customFileName: fileName);
      
      if (success) {
        
        await _cleanupOldManualBackups();
        debugPrint('✅ Backup manual completado');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Error en backup manual: $e');
      return false;
    }
  }

  
  Future<void> _cleanupOldAutoBackups() async {
    try {
      final driveService = GoogleDriveService();
      final backups = await driveService.listBackups();
      
      
      final autoBackups = backups
          .where((b) => b.name.contains('finanzas_libre_auto_'))
          .toList();
      
      
      autoBackups.sort((a, b) {
        if (a.createdTime == null || b.createdTime == null) return 0;
        return b.createdTime!.compareTo(a.createdTime!);
      });

      
      if (autoBackups.length > _maxAutoBackups) {
        final toDelete = autoBackups.sublist(_maxAutoBackups);
        
        for (final backup in toDelete) {
          await driveService.deleteBackup(backup.id);
          debugPrint('🗑️ Backup automático antiguo eliminado: ${backup.name}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error limpiando backups automáticos: $e');
    }
  }

 
  Future<void> _cleanupOldManualBackups() async {
    try {
      final driveService = GoogleDriveService();
      final backups = await driveService.listBackups();
      
      
      final manualBackups = backups
          .where((b) => b.name.contains('finanzas_libre_manual_'))
          .toList();
      
      
      manualBackups.sort((a, b) {
        if (a.createdTime == null || b.createdTime == null) return 0;
        return b.createdTime!.compareTo(a.createdTime!);
      });

      
      if (manualBackups.length > _maxManualBackups) {
        final toDelete = manualBackups.sublist(_maxManualBackups);
        
        for (final backup in toDelete) {
          await driveService.deleteBackup(backup.id);
          debugPrint('🗑️ Backup manual antiguo eliminado: ${backup.name}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error limpiando backups manuales: $e');
    }
  }

  
  Future<void> _showSuccessNotification() async {
    try {
      await _notifications.show(
        2,
        '✅ Backup Completado',
        'Tus datos se guardaron correctamente en Google Drive',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'backup_status',
            'Estado del Backup',
            channelDescription: 'Notificaciones sobre el estado del backup',
            importance: Importance.low,
            priority: Priority.low,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error mostrando notificación: $e');
    }
  }

  
  Future<void> _showErrorNotification() async {
    try {
      await _notifications.show(
        3,
        '❌ Error en Backup',
        'No se pudo completar el backup automático',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'backup_status',
            'Estado del Backup',
            channelDescription: 'Notificaciones sobre el estado del backup',
            importance: Importance.low,
            priority: Priority.low,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error mostrando notificación: $e');
    }
  }

 
  Future<DateTime?> getLastAutoBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastAutoBackupKey);
    
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    
    return null;
  }

  
  String getTimeUntilNextBackup(TimeOfDay time) {
    final now = DateTime.now();
    var nextBackup = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    
    if (nextBackup.isBefore(now)) {
      nextBackup = nextBackup.add(const Duration(days: 1));
    }
    
    final difference = nextBackup.difference(now);
    
    if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes.remainder(60)}m';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Menos de 1 minuto';
    }
  }
}