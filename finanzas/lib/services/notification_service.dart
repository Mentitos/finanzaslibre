import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() {
    return _instance;
  }
  
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Inicializar timezone
    tz.initializeTimeZones();
    
    // Detectar y configurar la zona horaria del dispositivo
    final String timeZoneName = await _getDeviceTimeZone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

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

  // Detectar la zona horaria del dispositivo
  Future<String> _getDeviceTimeZone() async {
    try {
      final String timeZoneName = DateTime.now().timeZoneName;
      
      // Mapeo de zonas horarias comunes
      final Map<String, String> timeZoneMap = {
        'ART': 'America/Argentina/Buenos_Aires',
        'EST': 'America/New_York',
        'PST': 'America/Los_Angeles',
        'CST': 'America/Chicago',
        'MST': 'America/Denver',
        'GMT': 'Europe/London',
        'CET': 'Europe/Paris',
        'JST': 'Asia/Tokyo',
        'IST': 'Asia/Kolkata',
        'AEST': 'Australia/Sydney',
        'NZST': 'Pacific/Auckland',
      };

      // Intentar encontrar la zona horaria en el mapa
      if (timeZoneMap.containsKey(timeZoneName)) {
        return timeZoneMap[timeZoneName]!;
      }

      // Si no se encuentra, intentar usar la zona horaria de Argentina por defecto
      // o detectar por offset
      final offset = DateTime.now().timeZoneOffset;
      if (offset.inHours == -3) {
        return 'America/Argentina/Buenos_Aires';
      }

      // Fallback a UTC si no se puede determinar
      return 'UTC';
    } catch (e) {
      // En caso de error, usar Buenos Aires como default
      return 'America/Argentina/Buenos_Aires';
    }
  }

  // Obtener la zona horaria actual configurada
  String getCurrentTimeZone() {
    return tz.local.name;
  }

  // Cambiar la zona horaria manualmente
  void setTimeZone(String timeZoneName) {
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Si falla, mantener la actual
    }
  }

  // Obtener lista de zonas horarias disponibles
  List<Map<String, String>> getAvailableTimeZones() {
    return [
      {'name': 'America/Argentina/Buenos_Aires', 'display': '🇦🇷 Argentina (GMT-3)'},
      {'name': 'America/Mexico_City', 'display': '🇲🇽 México - CDMX (GMT-6/-5)'},
      {'name': 'America/Cancun', 'display': '🇲🇽 México - Cancún (GMT-5)'},
      {'name': 'America/Tijuana', 'display': '🇲🇽 México - Tijuana (GMT-8/-7)'},
      {'name': 'America/Sao_Paulo', 'display': '🇧🇷 Brasil - São Paulo (GMT-3/-2)'},
      {'name': 'America/Manaus', 'display': '🇧🇷 Brasil - Manaus (GMT-4)'},
      {'name': 'America/Bogota', 'display': '🇨🇴 Colombia (GMT-5)'},
      {'name': 'America/Lima', 'display': '🇵🇪 Perú (GMT-5)'},
      {'name': 'America/Santiago', 'display': '🇨🇱 Chile (GMT-4/-3)'},
      {'name': 'America/Caracas', 'display': '🇻🇪 Venezuela (GMT-4)'},
      {'name': 'America/Montevideo', 'display': '🇺🇾 Uruguay (GMT-3)'},
      {'name': 'America/New_York', 'display': '🇺🇸 USA - Nueva York (GMT-5/-4)'},
      {'name': 'America/Los_Angeles', 'display': '🇺🇸 USA - Los Ángeles (GMT-8/-7)'},
      {'name': 'America/Chicago', 'display': '🇺🇸 USA - Chicago (GMT-6/-5)'},
      {'name': 'America/Denver', 'display': '🇺🇸 USA - Denver (GMT-7/-6)'},
      {'name': 'Europe/London', 'display': '🇬🇧 Reino Unido (GMT+0/+1)'},
      {'name': 'Europe/Paris', 'display': '🇫🇷 Francia (GMT+1/+2)'},
      {'name': 'Europe/Madrid', 'display': '🇪🇸 España (GMT+1/+2)'},
      {'name': 'Europe/Berlin', 'display': '🇩🇪 Alemania (GMT+1/+2)'},
      {'name': 'Europe/Rome', 'display': '🇮🇹 Italia (GMT+1/+2)'},
      {'name': 'Asia/Tokyo', 'display': '🇯🇵 Japón (GMT+9)'},
      {'name': 'Asia/Shanghai', 'display': '🇨🇳 China (GMT+8)'},
      {'name': 'Asia/Dubai', 'display': '🇦🇪 Emiratos Árabes (GMT+4)'},
      {'name': 'Asia/Kolkata', 'display': '🇮🇳 India (GMT+5:30)'},
      {'name': 'Australia/Sydney', 'display': '🇦🇺 Australia - Sídney (GMT+10/+11)'},
      {'name': 'Pacific/Auckland', 'display': '🇳🇿 Nueva Zelanda (GMT+12/+13)'},
    ];
  }

  // Callback cuando se toca la notificación
  void _onNotificationTapped(NotificationResponse response) {
    // Aquí puedes agregar lógica para cuando el usuario toca la notificación
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

  // Obtener tiempo restante hasta la próxima notificación
  Duration getTimeUntilNextNotification(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    final nextNotification = _nextInstanceOfTime(hour, minute);
    return nextNotification.difference(now);
  }

  // Formatear duración de forma legible
  String formatTimeRemaining(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 24) {
      final days = hours ~/ 24;
      final remainingHours = hours % 24;
      if (remainingHours > 0) {
        return '$days día${days != 1 ? 's' : ''} y $remainingHours hora${remainingHours != 1 ? 's' : ''}';
      }
      return '$days día${days != 1 ? 's' : ''}';
    } else if (hours > 0) {
      if (minutes > 0) {
        return '$hours hora${hours != 1 ? 's' : ''} y $minutes minuto${minutes != 1 ? 's' : ''}';
      }
      return '$hours hora${hours != 1 ? 's' : ''}';
    } else if (minutes > 0) {
      return '$minutes minuto${minutes != 1 ? 's' : ''}';
    } else {
      return 'menos de 1 minuto';
    }
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