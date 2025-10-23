import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'auto_backup_service.dart';
import 'savings_data_manager.dart';

/// Widget que escucha las notificaciones de backup automático
/// y ejecuta el backup cuando se dispara
class BackupSchedulerListener extends StatefulWidget {
  final Widget child;
  final SavingsDataManager dataManager;

  const BackupSchedulerListener({
    super.key,
    required this.child,
    required this.dataManager,
  });

  @override
  State<BackupSchedulerListener> createState() => _BackupSchedulerListenerState();
}

class _BackupSchedulerListenerState extends State<BackupSchedulerListener> with WidgetsBindingObserver {
  final AutoBackupService _autoBackupService = AutoBackupService();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  DateTime? _lastCheck;
  
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
    super.dispose();
  }

  /// Configurar listener de notificaciones
  void _setupNotificationListener() {
    // Este método se llama cuando se toca una notificación
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('📱 Notificación recibida: ${response.id}');
        
        // Si es la notificación de backup automático (ID = 1)
        if (response.id == 1) {
          _executeBackupIfNeeded();
        }
      },
    );
  }

  /// Programar verificación periódica (cada hora)
  void _schedulePeriodicCheck() {
    Future.delayed(const Duration(hours: 1), () {
      if (mounted) {
        _checkIfBackupNeeded();
        _schedulePeriodicCheck();
      }
    });
  }

  /// Verificar si es necesario hacer backup
  Future<void> _checkIfBackupNeeded() async {
    try {
      final enabled = await _autoBackupService.isAutoBackupEnabled();
      if (!enabled) return;

      final backupTime = await _autoBackupService.getAutoBackupTime();
      final now = DateTime.now();
      
      // Si la hora actual coincide con la hora de backup (±5 minutos)
      if (now.hour == backupTime.hour && 
          (now.minute >= backupTime.minute - 5 && now.minute <= backupTime.minute + 5)) {
        
        // Verificar que no se haya ejecutado en la última hora
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

  /// Ejecutar backup si está habilitado y es necesario
  Future<void> _executeBackupIfNeeded() async {
    try {
      final enabled = await _autoBackupService.isAutoBackupEnabled();
      if (!enabled) {
        debugPrint('ℹ️ Backup automático deshabilitado');
        return;
      }

      final lastBackup = await _autoBackupService.getLastAutoBackupTime();
      final now = DateTime.now();
      
      // Si ya se hizo backup hoy, no hacer otro
      if (lastBackup != null) {
        final difference = now.difference(lastBackup);
        if (difference.inHours < 23) {
          debugPrint('ℹ️ Ya existe un backup reciente (${difference.inHours}h atrás)');
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
    
    // Cuando la app vuelve al primer plano, verificar si es necesario hacer backup
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

/// Servicio para Android en segundo plano (opcional)
/// Este código debe agregarse en el archivo MainActivity.kt en Android

/*
// En android/app/src/main/kotlin/com/example/finanzas/MainActivity.kt

import android.content.Context
import androidx.work.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.TimeUnit

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.finanzas/backup"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleBackup" -> {
                    val hour = call.argument<Int>("hour") ?: 23
                    val minute = call.argument<Int>("minute") ?: 0
                    scheduleBackupWork(hour, minute)
                    result.success(true)
                }
                "cancelBackup" -> {
                    cancelBackupWork()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun scheduleBackupWork(hour: Int, minute: Int) {
        val currentDate = java.util.Calendar.getInstance()
        val dueDate = java.util.Calendar.getInstance()
        
        dueDate.set(java.util.Calendar.HOUR_OF_DAY, hour)
        dueDate.set(java.util.Calendar.MINUTE, minute)
        dueDate.set(java.util.Calendar.SECOND, 0)
        
        if (dueDate.before(currentDate)) {
            dueDate.add(java.util.Calendar.HOUR_OF_DAY, 24)
        }
        
        val timeDiff = dueDate.timeInMillis - currentDate.timeInMillis
        
        val backupWorkRequest = PeriodicWorkRequestBuilder<BackupWorker>(
            24, TimeUnit.HOURS
        )
            .setInitialDelay(timeDiff, TimeUnit.MILLISECONDS)
            .addTag("backup_work")
            .build()
        
        WorkManager.getInstance(applicationContext)
            .enqueueUniquePeriodicWork(
                "backup_work",
                ExistingPeriodicWorkPolicy.REPLACE,
                backupWorkRequest
            )
    }

    private fun cancelBackupWork() {
        WorkManager.getInstance(applicationContext)
            .cancelAllWorkByTag("backup_work")
    }
}

class BackupWorker(
    context: Context,
    params: WorkerParameters
) : Worker(context, params) {
    
    override fun doWork(): Result {
        // Aquí se ejecutaría el backup
        // En una implementación real, necesitarías comunicarte con Flutter
        return Result.success()
    }
}
*/