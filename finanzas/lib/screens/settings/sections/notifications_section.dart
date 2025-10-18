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
  TimeOfDay _selectedTime = const TimeOfDay(hour: 21, minute: 0);
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;
  bool _useSystemTimeZone = true;
  String _selectedTimeZone = '';

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
      await prefs.setInt('notification_hour', 21);
      await prefs.setInt('notification_minute', 0);
      await prefs.setBool('use_system_timezone', true);
      
      final granted = await _notificationService.requestPermissions();
      if (granted && mounted) {
        final l10n = AppLocalizations.of(context)!;
        await _notificationService.scheduleDailyReminder(
          hour: 21,
          minute: 0,
          title: l10n.savingsReminderTitle,
          body: l10n.savingsReminderBody,
        );

        _showTimeRemainingBanner(21, 0);
      }
      
      setState(() {
        _notificationsEnabled = granted;
        _selectedTime = const TimeOfDay(hour: 21, minute: 0);
        _useSystemTimeZone = true;
        _selectedTimeZone = _notificationService.getCurrentTimeZone();
        _isLoading = false;
      });
    } else {
      final enabled = prefs.getBool('notifications_enabled') ?? true;
      final hour = prefs.getInt('notification_hour') ?? 21;
      final minute = prefs.getInt('notification_minute') ?? 0;
      final useSystemTz = prefs.getBool('use_system_timezone') ?? true;
      final savedTz = prefs.getString('selected_timezone') ?? '';

      if (!useSystemTz && savedTz.isNotEmpty) {
        _notificationService.setTimeZone(savedTz);
      }

      setState(() {
        _notificationsEnabled = enabled;
        _selectedTime = TimeOfDay(hour: hour, minute: minute);
        _useSystemTimeZone = useSystemTz;
        _selectedTimeZone = _notificationService.getCurrentTimeZone();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setInt('notification_hour', _selectedTime.hour);
    await prefs.setInt('notification_minute', _selectedTime.minute);
    await prefs.setBool('use_system_timezone', _useSystemTimeZone);
    if (!_useSystemTimeZone) {
      await prefs.setString('selected_timezone', _selectedTimeZone);
    }
  }

  void _showTimeRemainingBanner(int hour, int minute) {
    if (!mounted) return;

    final duration = _notificationService.getTimeUntilNextNotification(hour, minute);
    final timeText = _notificationService.formatTimeRemaining(duration);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    OverlayEntry? overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                    ? [Colors.orange.shade700, Colors.orange.shade900]
                    : [Colors.orange.shade400, Colors.orange.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '⏰ Recordatorio configurado',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Próximo aviso en $timeText',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(milliseconds: 2500), () {
      overlayEntry?.remove();
    });
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

      _showTimeRemainingBanner(_selectedTime.hour, _selectedTime.minute);
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

        _showTimeRemainingBanner(_selectedTime.hour, _selectedTime.minute);
      }

      await _saveSettings();
    }
  }

  Future<void> _selectTimeZone() async {
    final availableZones = _notificationService.getAvailableTimeZones();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : null,
        title: Row(
          children: [
            Icon(Icons.public, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            Text(
              'Zona horaria',
              style: TextStyle(
                color: isDark ? Colors.white : null,
              ),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        content: SizedBox(
          width: double.maxFinite,
          height: 450,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableZones.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSelected = _useSystemTimeZone;
                return InkWell(
                  onTap: () => Navigator.pop(context, 'SYSTEM'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? (isDark ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50)
                        : (isDark ? Colors.grey[850] : Colors.grey.shade50),
                      border: Border(
                        left: BorderSide(
                          color: isSelected ? Colors.blue : (isDark ? Colors.grey[700]! : Colors.grey.shade300),
                          width: 4,
                        ),
                        bottom: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle : Icons.settings_suggest,
                          color: isSelected 
                            ? Colors.blue 
                            : (isDark ? Colors.grey[400] : Colors.grey.shade600),
                          size: 22,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '⚙️ Automática (del sistema)',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected 
                                    ? (isDark ? Colors.blue.shade300 : Colors.blue.shade900)
                                    : (isDark ? Colors.white : Colors.black87),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Detectar zona horaria del dispositivo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey[400] : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              final zone = availableZones[index - 1];
              final isSelected = !_useSystemTimeZone && zone['name'] == _selectedTimeZone;
              
              return InkWell(
                onTap: () => Navigator.pop(context, zone['name']),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? (isDark ? Colors.orange.shade900.withOpacity(0.3) : Colors.orange.shade50)
                      : null,
                    border: Border(
                      left: BorderSide(
                        color: isSelected ? Colors.orange : Colors.transparent,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected 
                          ? Colors.orange 
                          : (isDark ? Colors.grey[600] : Colors.grey.shade400),
                        size: 20,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          zone['display']!,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected 
                              ? (isDark ? Colors.orange.shade300 : Colors.orange.shade900)
                              : (isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (selected != null) {
      if (selected == 'SYSTEM') {
        await _notificationService.initialize();
        setState(() {
          _useSystemTimeZone = true;
          _selectedTimeZone = _notificationService.getCurrentTimeZone();
        });
      } else if (selected != _selectedTimeZone) {
        _notificationService.setTimeZone(selected);
        setState(() {
          _selectedTimeZone = selected;
          _useSystemTimeZone = false;
        });
      }

      if (_notificationsEnabled) {
        final l10n = AppLocalizations.of(context)!;
        await _notificationService.scheduleDailyReminder(
          hour: _selectedTime.hour,
          minute: _selectedTime.minute,
          title: l10n.savingsReminderTitle,
          body: l10n.savingsReminderBody,
        );
        
        _showTimeRemainingBanner(_selectedTime.hour, _selectedTime.minute);
      }

      await _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    String getTimeZoneDisplay() {
      final zones = _notificationService.getAvailableTimeZones();
      final zone = zones.firstWhere(
        (z) => z['name'] == _selectedTimeZone,
        orElse: () => {'name': _selectedTimeZone, 'display': _selectedTimeZone},
      );
      return zone['display']!;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          secondary: Icon(
            _notificationsEnabled 
              ? Icons.notifications_active 
              : Icons.notifications_off_outlined,
            color: _notificationsEnabled 
              ? Colors.orange 
              : (isDark ? Colors.grey[600] : Colors.grey),
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
        
        if (_notificationsEnabled) ...[
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
          
          ListTile(
            leading: const Icon(Icons.public, color: Colors.orange),
            title: const Text('Zona horaria'),
            subtitle: Text(
              _useSystemTimeZone 
                ? '⚙️ Automática: ${getTimeZoneDisplay()}' 
                : getTimeZoneDisplay(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _useSystemTimeZone 
                  ? (isDark ? Colors.blue.shade300 : Colors.blue.shade700)
                  : (isDark ? Colors.orange.shade300 : Colors.orange.shade700),
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _selectTimeZone,
          ),
          
          if (!_useSystemTimeZone)
            Container(
              margin: const EdgeInsets.only(left: 72, right: 16, top: 4, bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark 
                  ? Colors.orange.shade900.withOpacity(0.2)
                  : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark 
                    ? Colors.orange.shade700.withOpacity(0.5)
                    : Colors.orange.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline, 
                    size: 16, 
                    color: isDark ? Colors.orange.shade300 : Colors.orange.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedTimeZone,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.orange.shade200 : Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}