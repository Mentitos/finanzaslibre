import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/notification_service.dart';

class NotificationsSection extends StatefulWidget {
  const NotificationsSection({super.key});

  @override
  State<NotificationsSection> createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<NotificationsSection> {
  bool _notificationsEnabled = true; // Por defecto activado
  TimeOfDay _selectedTime = const TimeOfDay(hour: 22, minute: 0); // 22:00 por defecto
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Si es la primera vez, configurar valores por defecto
    final isFirstTime = prefs.getBool('notifications_first_time') ?? true;
    
    if (isFirstTime) {
      // Primera vez: activar notificaciones y programarlas
      await prefs.setBool('notifications_first_time', false);
      await prefs.setBool('notifications_enabled', true);
      await prefs.setInt('notification_hour', 22);
      await prefs.setInt('notification_minute', 0);
      
      // Solicitar permisos y programar
      final granted = await _notificationService.requestPermissions();
      if (granted) {
        await _notificationService.scheduleDailyReminder(
          hour: 22,
          minute: 0,
          title: '💰 Recordatorio de Ahorros',
          body: '¿Ya registraste tus movimientos de hoy?',
        );
      }
      
      setState(() {
        _notificationsEnabled = granted;
        _selectedTime = const TimeOfDay(hour: 22, minute: 0);
        _isLoading = false;
      });
    } else {
      // Cargar configuración guardada
      final enabled = prefs.getBool('notifications_enabled') ?? true;
      final hour = prefs.getInt('notification_hour') ?? 22;
      final minute = prefs.getInt('notification_minute') ?? 0;

      setState(() {
        _notificationsEnabled = enabled;
        _selectedTime = TimeOfDay(hour: hour, minute: minute);
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setInt('notification_hour', _selectedTime.hour);
    await prefs.setInt('notification_minute', _selectedTime.minute);
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      // Solicitar permisos
      final granted = await _notificationService.requestPermissions();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se necesitan permisos para mostrar notificaciones'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Programar notificación
      await _notificationService.scheduleDailyReminder(
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
        title: '💰 Recordatorio de Ahorros',
        body: '¿Ya registraste tus movimientos de hoy?',
      );

      setState(() {
        _notificationsEnabled = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Recordatorio activado para las ${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      await _notificationService.cancelDailyReminder();
      setState(() {
        _notificationsEnabled = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recordatorio desactivado'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    await _saveSettings();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });

      // Si las notificaciones están activas, reprogramar
      if (_notificationsEnabled) {
        await _notificationService.scheduleDailyReminder(
          hour: _selectedTime.hour,
          minute: _selectedTime.minute,
          title: '💰 Recordatorio de Ahorros',
          body: '¿Ya registraste tus movimientos de hoy?',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Hora actualizada: ${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

      await _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            'Notificaciones',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        
        SwitchListTile(
          secondary: Icon(
            _notificationsEnabled 
              ? Icons.notifications_active 
              : Icons.notifications_off_outlined,
            color: _notificationsEnabled 
              ? Colors.orange 
              : Colors.grey,
          ),
          title: const Text('Recordatorio diario'),
          subtitle: Text(
            _notificationsEnabled 
              ? 'Recibirás un recordatorio cada día' 
              : 'Los recordatorios están desactivados'
          ),
          value: _notificationsEnabled,
          onChanged: _toggleNotifications,
        ),
        
        if (_notificationsEnabled)
          ListTile(
            leading: const Icon(Icons.access_time, color: Colors.orange),
            title: const Text('Hora del recordatorio'),
            subtitle: Text(
              '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _selectTime,
          ),
      ],
    );
  }
}