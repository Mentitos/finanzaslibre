import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class NotificationService {
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

    try {
      tz.initializeTimeZones();

      final String timeZoneName = await _getDeviceTimeZone();
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        debugPrint('⚠️ Error setting location, using default: $e');
        // Fallback to UTC if location invalid
        try {
          tz.setLocalLocation(tz.getLocation('UTC'));
        } catch (_) {}
      }

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
        linux: LinuxInitializationSettings(
          defaultActionName: 'Open notification',
        ),
        windows: WindowsInitializationSettings(
          appName: 'Mis Ahorros',
          guid: '2c332145-6804-4537-b353-84c47b0a7401',
          appUserModelId: 'com.tello.finanzas',
        ),
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _initialized = true;
    } catch (e) {
      debugPrint('❌ Error initializing NotificationService: $e');
    }
  }

  Future<String> _getDeviceTimeZone() async {
    try {
      final String timeZoneName = DateTime.now().timeZoneName;

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

      if (timeZoneMap.containsKey(timeZoneName)) {
        return timeZoneMap[timeZoneName]!;
      }

      final offset = DateTime.now().timeZoneOffset;
      if (offset.inHours == -3) {
        return 'America/Argentina/Buenos_Aires';
      }

      return 'UTC';
    } catch (e) {
      return 'America/Argentina/Buenos_Aires';
    }
  }

  String getCurrentTimeZone() {
    return tz.local.name;
  }

  void setTimeZone(String timeZoneName) {
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Ignore invalid timezones
    }
  }

  List<Map<String, String>> getAvailableTimeZones() {
    return [
      {
        'name': 'America/Argentina/Buenos_Aires',
        'display': '🇦🇷 Argentina (GMT-3)',
      },
      {
        'name': 'America/Mexico_City',
        'display': '🇲🇽 México - CDMX (GMT-6/-5)',
      },
      {'name': 'America/Cancun', 'display': '🇲🇽 México - Cancún (GMT-5)'},
      {
        'name': 'America/Tijuana',
        'display': '🇲🇽 México - Tijuana (GMT-8/-7)',
      },
      {
        'name': 'America/Sao_Paulo',
        'display': '🇧🇷 Brasil - São Paulo (GMT-3/-2)',
      },
      {'name': 'America/Manaus', 'display': '🇧🇷 Brasil - Manaus (GMT-4)'},
      {'name': 'America/Bogota', 'display': '🇨🇴 Colombia (GMT-5)'},
      {'name': 'America/Lima', 'display': '🇵🇪 Perú (GMT-5)'},
      {'name': 'America/Santiago', 'display': '🇨🇱 Chile (GMT-4/-3)'},
      {'name': 'America/Caracas', 'display': '🇻🇪 Venezuela (GMT-4)'},
      {'name': 'America/Montevideo', 'display': '🇺🇾 Uruguay (GMT-3)'},
      {
        'name': 'America/New_York',
        'display': '🇺🇸 USA - Nueva York (GMT-5/-4)',
      },
      {
        'name': 'America/Los_Angeles',
        'display': '🇺🇸 USA - Los Ángeles (GMT-8/-7)',
      },
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
      {
        'name': 'Australia/Sydney',
        'display': '🇦🇺 Australia - Sídney (GMT+10/+11)',
      },
      {
        'name': 'Pacific/Auckland',
        'display': '🇳🇿 Nueva Zelanda (GMT+12/+13)',
      },
    ];
  }

  void _onNotificationTapped(NotificationResponse response) {}

  Future<bool> requestPermissions() async {
    if (!await Permission.notification.isGranted) {
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        return false;
      }
    }

    if (Platform.isAndroid) {
      if (!await Permission.scheduleExactAlarm.isGranted) {
        await Permission.scheduleExactAlarm.request();
      }
    }

    return true;
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final scheduledDate = _nextInstanceOfTime(hour, minute);

    await _notifications.zonedSchedule(
      0,
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

  Duration getTimeUntilNextNotification(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    final nextNotification = _nextInstanceOfTime(hour, minute);
    return nextNotification.difference(now);
  }

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

  Future<void> cancelDailyReminder() async {
    await _notifications.cancel(0);
  }

  Future<bool> hasScheduledNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();
    return pending.isNotEmpty;
  }
}
