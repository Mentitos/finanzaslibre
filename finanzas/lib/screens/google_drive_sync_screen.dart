import 'package:flutter/material.dart';
import '../services/google_drive_service.dart';
import '../services/savings_data_manager.dart';
import '../services/auto_backup_service.dart';
import '../l10n/app_localizations.dart';

class GoogleDriveSyncScreen extends StatefulWidget {
  final SavingsDataManager dataManager;
  final Function(String message, bool isError) onShowSnackBar;
  final Future<void> Function() onDataChanged;

  const GoogleDriveSyncScreen({
    super.key,
    required this.dataManager,
    required this.onShowSnackBar,
    required this.onDataChanged,
  });

  @override
  State<GoogleDriveSyncScreen> createState() => _GoogleDriveSyncScreenState();
}

class _GoogleDriveSyncScreenState extends State<GoogleDriveSyncScreen> {
  final GoogleDriveService _driveService = GoogleDriveService();
  final AutoBackupService _autoBackupService = AutoBackupService();

  bool _isLoading = false;
  bool _isSignedIn = false;
  bool _autoBackupEnabled = false;
  TimeOfDay _autoBackupTime = const TimeOfDay(hour: 23, minute: 0);
  DateTime? _lastAutoBackup;
  List<DriveBackupFile> _backups = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);

    await _driveService.initialize();
    await _autoBackupService.initialize();

    if (mounted) {
      setState(() {
        _isSignedIn = _driveService.isSignedIn;
        _isLoading = false;
      });

      if (_isSignedIn) {
        await _loadSettings();
        await _loadBackups();
      }
    }
  }

  Future<void> _loadSettings() async {
    final enabled = await _autoBackupService.isAutoBackupEnabled();
    final time = await _autoBackupService.getAutoBackupTime();
    final lastBackup = await _autoBackupService.getLastAutoBackupTime();

    if (mounted) {
      setState(() {
        _autoBackupEnabled = enabled;
        _autoBackupTime = time;
        _lastAutoBackup = lastBackup;
      });
    }
  }

  Future<void> _loadBackups() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    final backups = await _driveService.listBackups();

    if (mounted) {
      setState(() {
        _backups = backups;
        _isLoading = false;
      });
    }
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    final success = await _driveService.signIn();

    if (!mounted) return;

    if (success) {
      setState(() => _isSignedIn = true);
      widget.onShowSnackBar('✅ Sesión iniciada correctamente', false);
      await _loadSettings();
      await _loadBackups();
    } else {
      setState(() => _isLoading = false);
      widget.onShowSnackBar('❌ Error al iniciar sesión', true);
    }
  }

  Future<void> _signOut() async {
    await _driveService.signOut();

    if (!mounted) return;

    setState(() {
      _isSignedIn = false;
      _backups = [];
      _autoBackupEnabled = false;
    });
    widget.onShowSnackBar('Sesión cerrada', false);
  }

  Future<void> _uploadManualBackup() async {
    setState(() => _isLoading = true);

    try {
      final success = await _autoBackupService.executeManualBackup(
        widget.dataManager,
      );

      if (!mounted) return;

      if (success) {
        widget.onShowSnackBar('✅ Backup manual creado', false);
        await _loadBackups();
      } else {
        setState(() => _isLoading = false);
        widget.onShowSnackBar('❌ Error al crear backup', true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      widget.onShowSnackBar('❌ Error: $e', true);
    }
  }

  Future<void> _toggleAutoBackup(bool value) async {
    setState(() => _autoBackupEnabled = value);

    await _autoBackupService.setAutoBackupEnabled(value);

    if (value) {
      widget.onShowSnackBar(
        '✅ Backup automático activado\nPróximo: ${_autoBackupService.getTimeUntilNextBackup(_autoBackupTime)}',
        false,
      );
    } else {
      widget.onShowSnackBar('Backup automático desactivado', false);
    }
  }

  Future<void> _selectBackupTime() async {
    final l10n = AppLocalizations.of(context)!;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _autoBackupTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _autoBackupTime) {
      setState(() => _autoBackupTime = picked);

      await _autoBackupService.setAutoBackupTime(picked);

      if (_autoBackupEnabled) {
        widget.onShowSnackBar(
          'Hora actualizada\nPróximo: ${_autoBackupService.getTimeUntilNextBackup(picked)}',
          false,
        );
      }
    }
  }

  Future<void> _downloadBackup(DriveBackupFile backup) async {
    final l10n = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('⚠️ ${l10n.restoreBackup}'),
        content: Text(
          '¿Deseas restaurar el backup del ${backup.formattedDate}?\n\n'
          '⚠️ Esto reemplazará todos tus datos actuales.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final data = await _driveService.downloadBackup(backup.id);

      if (!mounted) return;

      if (data != null) {
        final success = await widget.dataManager.importData(data);

        if (!mounted) return;

        if (success) {
          await widget.onDataChanged();
          widget.onShowSnackBar('✅ Datos restaurados correctamente', false);
        } else {
          widget.onShowSnackBar('❌ Error al importar datos', true);
        }
      } else {
        widget.onShowSnackBar('❌ Error al descargar backup', true);
      }
    } catch (e) {
      if (!mounted) return;
      widget.onShowSnackBar('❌ Error: $e', true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteBackup(DriveBackupFile backup) async {
    final l10n = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🗑️ ${l10n.deleteBackup}'),
        content: Text(
          '¿Deseas eliminar el backup del ${backup.formattedDate}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final success = await _driveService.deleteBackup(backup.id);

      if (!mounted) return;

      if (success) {
        widget.onShowSnackBar('✅ Backup eliminado', false);
        await _loadBackups();
      } else {
        setState(() => _isLoading = false);
        widget.onShowSnackBar('❌ Error al eliminar backup', true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      widget.onShowSnackBar('❌ Error: $e', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.cloud, size: 24, color: Colors.blue[700]),
            const SizedBox(width: 8),
            const Text('Google Drive'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_isSignedIn
          ? _buildSignInView(isDark)
          : _buildSyncView(isDark),
    );
  }

  Widget _buildSignInView(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_outlined,
                size: 80,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Sincroniza con Google Drive',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Mantén tus datos seguros en la nube y accede a ellos desde cualquier dispositivo',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildFeatureItem(
              Icons.backup,
              'Backup automático',
              'Tus datos se guardan automáticamente',
              isDark,
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              Icons.schedule,
              'Programación',
              'Elige cuándo hacer los backups',
              isDark,
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              Icons.security,
              'Seguridad',
              'Tus datos están protegidos por Google',
              isDark,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: _signIn,
              icon: const Icon(Icons.login),
              label: const Text('Iniciar sesión con Google'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String subtitle,
    bool isDark,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue[700], size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSyncView(bool isDark) {
    final autoBackups = _backups
        .where((b) => b.name.contains('_auto_'))
        .toList();
    final manualBackups = _backups
        .where((b) => b.name.contains('_manual_'))
        .toList();

    return RefreshIndicator(
      onRefresh: _loadBackups,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAccountCard(isDark),
          const SizedBox(height: 16),
          _buildAutoBackupCard(isDark),
          const SizedBox(height: 16),
          _buildActionButton(
            icon: Icons.backup,
            label: 'Crear Backup Manual Ahora',
            color: Colors.green,
            onPressed: _uploadManualBackup,
          ),
          const SizedBox(height: 24),

          if (autoBackups.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Backups Automáticos (${autoBackups.length}/2)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...autoBackups.map(
              (backup) => _buildBackupCard(backup, isDark, isAuto: true),
            ),
            const SizedBox(height: 24),
          ],

          // Sección de backups manuales
          Row(
            children: [
              Icon(Icons.touch_app, color: Colors.green[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Backups Manuales (${manualBackups.length}/2)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (manualBackups.isEmpty)
            _buildEmptyBackupsCard(isDark, 'No hay backups manuales')
          else
            ...manualBackups.map(
              (backup) => _buildBackupCard(backup, isDark, isAuto: false),
            ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: _driveService.userPhotoUrl != null
                      ? NetworkImage(_driveService.userPhotoUrl!)
                      : null,
                  child: _driveService.userPhotoUrl == null
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _driveService.userName ?? 'Usuario',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _driveService.userEmail ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoBackupCard(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: _autoBackupEnabled ? Colors.blue[700] : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Backup Automático',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _autoBackupEnabled
                            ? 'Activo - Se guardan solo los últimos 2'
                            : 'Inactivo',
                        style: TextStyle(
                          fontSize: 12,
                          color: _autoBackupEnabled
                              ? Colors.blue[700]
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _autoBackupEnabled,
                  onChanged: _toggleAutoBackup,
                  activeColor: Colors.blue[700],
                ),
              ],
            ),

            if (_autoBackupEnabled) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              InkWell(
                onTap: _selectBackupTime,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hora programada',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_autoBackupTime.hour.toString().padLeft(2, '0')}:${_autoBackupTime.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.edit, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Próximo backup: ${_autoBackupService.getTimeUntilNextBackup(_autoBackupTime)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_lastAutoBackup != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Último: ${_formatDateTime(_lastAutoBackup!)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyBackupsCard(bool isDark, String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.cloud_off,
              size: 48,
              color: isDark ? Colors.grey[700] : Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupCard(
    DriveBackupFile backup,
    bool isDark, {
    required bool isAuto,
  }) {
    final color = isAuto ? Colors.blue : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isAuto ? Icons.schedule : Icons.touch_app,
            color: color[700],
            size: 20,
          ),
        ),
        title: Text(
          backup.formattedDate,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isAuto ? 'AUTO' : 'MANUAL',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color[700],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              backup.formattedSize,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _downloadBackup(backup),
              icon: const Icon(Icons.download),
              tooltip: 'Restaurar',
              color: Colors.blue[700],
            ),
            IconButton(
              onPressed: () => _deleteBackup(backup),
              icon: const Icon(Icons.delete),
              tooltip: 'Eliminar',
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
