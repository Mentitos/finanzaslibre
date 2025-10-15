import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Inicializar timezone
    tz.initializeTimeZones();
    
    // Configurar zona horaria local (Buenos Aires)
    tz.setLocalLocation(tz.getLocation('America/Argentina/Buenos_Aires'));

    // Configuración Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Inicializar con callback para cuando se toca la notificación
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  // Callback cuando se toca la notificación
  void _onNotificationTapped(NotificationResponse response) {
    // Aquí puedes agregar lógica para cuando el usuario toca la notificación
    // Por ejemplo, navegar a una pantalla específica
  }

  // Solicitar todos los permisos necesarios
  Future<bool> requestPermissions() async {
    // Permiso de notificaciones (Android 13+)
    if (!await Permission.notification.isGranted) {
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        return false;
      }
    }

    // Permiso de alarmas exactas (Android 12+)
    if (Platform.isAndroid) {
      if (!await Permission.scheduleExactAlarm.isGranted) {
        await Permission.scheduleExactAlarm.request();
        // No retornamos false porque algunas versiones de Android no lo requieren
      }
    }

    return true;
  }

  // Programar notificación diaria
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final scheduledDate = _nextInstanceOfTime(hour, minute);
    
    await _notifications.zonedSchedule(
      0, // ID único para la notificación diaria
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Recordatorios Diarios',
          channelDescription: 'Recordatorios para registrar movimientos',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Calcular la próxima instancia de la hora configurada
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

    // Si la hora ya pasó hoy, programar para mañana
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Cancelar notificación diaria
  Future<void> cancelDailyReminder() async {
    await _notifications.cancel(0);
  }

  // Verificar si hay notificaciones programadas
  Future<bool> hasScheduledNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();
    return pending.isNotEmpty;
  }
}