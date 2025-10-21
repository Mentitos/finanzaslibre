import 'package:flutter/material.dart';
import '../services/google_drive_service.dart';
import '../services/savings_data_manager.dart';
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
  bool _isLoading = false;
  bool _isSignedIn = false;
  List<DriveBackupFile> _backups = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);
    await _driveService.initialize();
    
    if (mounted) {
      setState(() {
        _isSignedIn = _driveService.isSignedIn;
        _isLoading = false;
      });

      if (_isSignedIn) {
        await _loadBackups();
      }
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
      await _loadBackups();
    } else {
      setState(() => _isLoading = false);
      widget.onShowSnackBar(
        '❌ Error al iniciar sesión.\nVerifica tu configuración de Google Cloud Console',
        true
      );
    }
  }

  Future<void> _signOut() async {
    await _driveService.signOut();
    
    if (!mounted) return;
    
    setState(() {
      _isSignedIn = false;
      _backups = [];
    });
    widget.onShowSnackBar('Sesión cerrada', false);
  }

  Future<void> _uploadBackup() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await widget.dataManager.exportData();
      final success = await _driveService.uploadBackup(data);
      
      if (!mounted) return;
      
      if (success) {
        widget.onShowSnackBar('✅ Backup subido a Google Drive', false);
        await _loadBackups();
      } else {
        setState(() => _isLoading = false);
        widget.onShowSnackBar('❌ Error al subir backup', true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      widget.onShowSnackBar('❌ Error: $e', true);
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
              Icons.sync,
              'Sincronización',
              'Mantén tus dispositivos sincronizados',
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
    return RefreshIndicator(
      onRefresh: _loadBackups,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAccountCard(isDark),
          const SizedBox(height: 16),
          _buildActionButton(
            icon: Icons.backup,
            label: 'Crear Backup Ahora',
            color: Colors.green,
            onPressed: _uploadBackup,
          ),
          const SizedBox(height: 24),
          Text(
            'Backups Disponibles',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (_backups.isEmpty)
            _buildEmptyBackupsCard(isDark)
          else
            ..._backups.map((backup) => _buildBackupCard(backup, isDark)),
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

  Widget _buildEmptyBackupsCard(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.cloud_off,
              size: 64,
              color: isDark ? Colors.grey[700] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay backups disponibles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primer backup para comenzar',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupCard(DriveBackupFile backup, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.cloud_done, color: Colors.blue[700]),
        ),
        title: Text(
          backup.formattedDate,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          backup.formattedSize,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _downloadBackup(backup),
              icon: const Icon(Icons.download),
              tooltip: 'Restaurar',
            ),
            IconButton(
              onPressed: () => _deleteBackup(backup),
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Eliminar',
            ),
          ],
        ),
      ),
    );
  }
}