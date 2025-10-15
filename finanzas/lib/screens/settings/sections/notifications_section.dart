import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/notification_service.dart';
import '../../../l10n/app_localizations.dart';

class NotificationsSection extends StatefulWidget {
  const NotificationsSection({super.key});

  @override
  State<NotificationsSection> createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<NotificationsSection> {
  bool _notificationsEnabled = true; 
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
    
    
    final isFirstTime = prefs.getBool('notifications_first_time') ?? true;
    
    if (isFirstTime) {
      
      await prefs.setBool('notifications_first_time', false);
      await prefs.setBool('notifications_enabled', true);
      await prefs.setInt('notification_hour', 22);
      await prefs.setInt('notification_minute', 0);
      
      
      final granted = await _notificationService.requestPermissions();
      if (granted && mounted) {
        final l10n = AppLocalizations.of(context)!;
        await _notificationService.scheduleDailyReminder(
          hour: 22,
          minute: 0,
          title: l10n.savingsReminderTitle,
          body: l10n.savingsReminderBody,
        );
      }
      
      setState(() {
        _notificationsEnabled = granted;
        _selectedTime = const TimeOfDay(hour: 22, minute: 0);
        _isLoading = false;
      });
    } else {
      
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
    final l10n = AppLocalizations.of(context)!;
    
    if (value) {
      
      final granted = await _notificationService.requestPermissions();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.notificationPermissionRequired),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      
      await _notificationService.scheduleDailyReminder(
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
        title: l10n.savingsReminderTitle,
        body: l10n.savingsReminderBody,
      );

      setState(() {
        _notificationsEnabled = true;
      });

      if (mounted) {
        final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.reminderActivatedAt(timeStr)),
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
          SnackBar(
            content: Text(l10n.reminderDeactivated),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    await _saveSettings();
  }

  Future<void> _selectTime() async {
    final l10n = AppLocalizations.of(context)!;
    
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

      
      if (_notificationsEnabled) {
        await _notificationService.scheduleDailyReminder(
          hour: _selectedTime.hour,
          minute: _selectedTime.minute,
          title: l10n.savingsReminderTitle,
          body: l10n.savingsReminderBody,
        );

        if (mounted) {
          final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.timeUpdated(timeStr)),
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
    final l10n = AppLocalizations.of(context)!;
    
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
            l10n.notifications,
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
          title: Text(l10n.dailyReminder),
          subtitle: Text(
            _notificationsEnabled 
              ? l10n.reminderEnabled
              : l10n.reminderDisabled
          ),
          value: _notificationsEnabled,
          onChanged: _toggleNotifications,
        ),
        
        if (_notificationsEnabled)
          ListTile(
            leading: const Icon(Icons.access_time, color: Colors.orange),
            title: Text(l10n.reminderTime),
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