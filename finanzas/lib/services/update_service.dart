import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  static const String _versionCheckUrl =
      'https://drive.google.com/uc?export=download&id=1wnJeAwIAgcudn5PVkEzHJPU_LiYEuZZz';

  static const String _lastUpdateDateKey = 'last_known_update_date';
  static const String _dismissedUpdateKey = 'dismissed_update_date';

  Future<UpdateInfo?> checkForUpdates() async {
    try {
      debugPrint('🔄 Verificando actualizaciones...');

      final prefs = await SharedPreferences.getInstance();
      final lastKnownUpdate = prefs.getString(_lastUpdateDateKey);

      debugPrint(
        '📱 Última actualización conocida: ${lastKnownUpdate ?? "Ninguna"}',
      );

      final response = await http.get(Uri.parse(_versionCheckUrl));

      if (response.statusCode != 200) {
        debugPrint(
          '❌ Error al obtener info de actualización: ${response.statusCode}',
        );
        return null;
      }

      final updateData = jsonDecode(response.body) as Map<String, dynamic>;
      final lastUpdateDate = updateData['lastUpdateDate'] as String;
      final appVersion = updateData['appVersion'] as String;
      final downloadUrl = updateData['downloadUrl'] as String;
      final releaseNotes = updateData['releaseNotes'] as Map<String, dynamic>?;
      final mandatory = updateData['mandatory'] as bool? ?? false;

      debugPrint('🆕 Última actualización disponible: $lastUpdateDate');

      final remoteDate = DateTime.parse(lastUpdateDate);
      final localDate = lastKnownUpdate != null
          ? DateTime.parse(lastKnownUpdate)
          : DateTime(2000);

      if (remoteDate.isAfter(localDate)) {
        return UpdateInfo(
          lastUpdateDate: remoteDate,
          appVersion: appVersion,
          downloadUrl: downloadUrl,
          releaseNotesEs: releaseNotes?['es'] as List<dynamic>? ?? [],
          releaseNotesEn: releaseNotes?['en'] as List<dynamic>? ?? [],
          isMandatory: mandatory,
        );
      }

      debugPrint('✅ App actualizada');
      return null;
    } catch (e) {
      debugPrint('❌ Error verificando actualizaciones: $e');
      return null;
    }
  }

  Future<void> checkForUpdatesOnStartup(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));

    final updateInfo = await checkForUpdates();

    if (updateInfo != null && context.mounted) {
      final prefs = await SharedPreferences.getInstance();
      final dismissedUpdate = prefs.getString(_dismissedUpdateKey);

      if (!updateInfo.isMandatory &&
          dismissedUpdate == updateInfo.lastUpdateDate.toIso8601String()) {
        debugPrint(
          '⏭️ Usuario descartó actualización del ${updateInfo.formattedDate}',
        );
        return;
      }

      _showUpdateBanner(context, updateInfo);
    }
  }

  void _showUpdateBanner(BuildContext context, UpdateInfo info) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 8,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -50 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: GestureDetector(
              onTap: () {
                overlayEntry.remove();
                showUpdateDialog(context, info);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: info.isMandatory
                        ? [Colors.orange.shade600, Colors.orange.shade800]
                        : [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.tertiary,
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (info.isMandatory
                                  ? Colors.orange
                                  : Theme.of(context).colorScheme.primary)
                              .withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        info.isMandatory ? Icons.warning : Icons.system_update,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info.isMandatory
                                ? 'Actualización Requerida'
                                : 'Nueva Actualización Disponible',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Versión ${info.appVersion} • ${info.formattedDate}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.touch_app,
                      color: Colors.white.withOpacity(0.9),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    if (!info.isMandatory) {
      Future.delayed(const Duration(seconds: 6), () {
        if (overlayEntry.mounted) {
          overlayEntry.remove();
        }
      });
    }
  }

  void showUpdateDialog(BuildContext context, UpdateInfo info) {
    final locale = Localizations.localeOf(context).languageCode;
    final releaseNotes = locale == 'es'
        ? info.releaseNotesEs
        : info.releaseNotesEn;

    showDialog(
      context: context,
      barrierDismissible: !info.isMandatory,
      builder: (context) => PopScope(
        canPop: !info.isMandatory,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(
                info.isMandatory ? Icons.warning : Icons.system_update,
                color: info.isMandatory
                    ? Colors.orange
                    : Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  info.isMandatory
                      ? 'Actualización Requerida'
                      : 'Nueva Versión Disponible',
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        (info.isMandatory
                                ? Colors.orange
                                : Theme.of(context).colorScheme.primary)
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          (info.isMandatory
                                  ? Colors.orange
                                  : Theme.of(context).colorScheme.primary)
                              .withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.new_releases,
                            color: info.isMandatory
                                ? Colors.orange[700]
                                : Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Versión ${info.appVersion}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: info.isMandatory
                                  ? Colors.orange[700]
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Actualizado: ${info.formattedDate}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (info.isMandatory) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Esta actualización es obligatoria para continuar usando la app',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (releaseNotes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Novedades:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...releaseNotes.map(
                    (note) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        note.toString(),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            if (!info.isMandatory)
              TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString(
                    _dismissedUpdateKey,
                    info.lastUpdateDate.toIso8601String(),
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Después'),
              ),

            FilledButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await _downloadUpdate(info.downloadUrl);

                // Guardar que se conoce la actualización
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(
                  _lastUpdateDateKey,
                  info.lastUpdateDate.toIso8601String(),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('Descargar'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadUpdate(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        debugPrint('✅ Descarga iniciada');
      } else {
        debugPrint('❌ No se pudo abrir URL de descarga');
      }
    } catch (e) {
      debugPrint('❌ Error al descargar: $e');
    }
  }
}

class UpdateInfo {
  final DateTime lastUpdateDate;
  final String appVersion;
  final String downloadUrl;
  final List<dynamic> releaseNotesEs;
  final List<dynamic> releaseNotesEn;
  final bool isMandatory;

  UpdateInfo({
    required this.lastUpdateDate,
    required this.appVersion,
    required this.downloadUrl,
    required this.releaseNotesEs,
    required this.releaseNotesEn,
    this.isMandatory = false,
  });

  String get formattedDate {
    final day = lastUpdateDate.day.toString().padLeft(2, '0');
    final month = lastUpdateDate.month.toString().padLeft(2, '0');
    final year = lastUpdateDate.year;
    return '$day/$month/$year';
  }

  String get formattedDateTime {
    final day = lastUpdateDate.day.toString().padLeft(2, '0');
    final month = lastUpdateDate.month.toString().padLeft(2, '0');
    final year = lastUpdateDate.year;
    final hour = lastUpdateDate.hour.toString().padLeft(2, '0');
    final minute = lastUpdateDate.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
