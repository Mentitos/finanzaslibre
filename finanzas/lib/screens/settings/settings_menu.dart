import 'package:flutter/material.dart';
import '../../services/savings_data_manager.dart';
import '../../constants/app_constants.dart';
import 'security_section.dart';
import '../dialogs/export_import_dialogs.dart';
import '../dialogs/confirmation_dialogs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // Para Clipboard
import '../../main.dart';

class SettingsMenu extends StatelessWidget {
  final SavingsDataManager dataManager;
  final Future<void> Function() onDataChanged;
  final Function(String message, bool isError) onShowSnackBar;
  final int allRecordsCount;
  final int categoriesCount;

  const SettingsMenu({
    super.key,
    required this.dataManager,
    required this.onDataChanged,
    required this.onShowSnackBar,
    required this.allRecordsCount,
    required this.categoriesCount,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(height: 30),
            _buildAppearanceSection(context), // AGREGAR AQUÍ
            const Divider(height: 30),
            SecuritySection(
              dataManager: dataManager,
              onShowSnackBar: onShowSnackBar,
              onCloseSettings: () => Navigator.pop(context),
            ),
            const Divider(height: 30),
            _buildDataManagementSection(context),
            const Divider(),
            _buildDangerZoneSection(context),
            const Divider(),
            _buildAboutSection(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.settings, size: 28),
        const SizedBox(width: 12),
        Text(
          'Configuración',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }
Widget _buildAppearanceSection(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 8),
        child: Text(
          'Apariencia',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ),
      ListTile(
        leading: Icon(
          Theme.of(context).brightness == Brightness.dark
              ? Icons.dark_mode
              : Icons.light_mode,
          color: Colors.amber,
        ),
        title: const Text('Modo oscuro'),
        subtitle: Text(
          Theme.of(context).brightness == Brightness.dark
              ? 'Tema oscuro activado'
              : 'Tema claro activado',
        ),
        trailing: Switch(
          value: Theme.of(context).brightness == Brightness.dark,
          onChanged: (value) {
            MyApp.of(context).toggleTheme();
          },
        ),
      ),
    ],
  );
}
  Widget _buildDataManagementSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            'Gestión de Datos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.file_download, color: Colors.blue),
          title: const Text('Exportar datos'),
          subtitle: const Text('Guardar respaldo de tus registros'),
          onTap: () {
            Navigator.pop(context);
            _exportData(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.file_upload, color: Colors.green),
          title: const Text('Importar datos'),
          subtitle: const Text('Restaurar desde un respaldo'),
          onTap: () {
            Navigator.pop(context);
            ExportImportDialogs.showImportDialog(
              context,
              dataManager,
              onDataChanged,
              onShowSnackBar,
            );
          },
        ),
      ],
    );
  }

  Widget _buildDangerZoneSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            'Zona de Peligro',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.delete_sweep, color: Colors.orange),
          title: const Text('Eliminar todos los registros'),
          subtitle: const Text('Borrar historial manteniendo categorías'),
          onTap: () {
            Navigator.pop(context);
            ConfirmationDialogs.showClearRecordsConfirmation(
              context,
              dataManager,
              onDataChanged,
              onShowSnackBar,
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.restore, color: Colors.red),
          title: const Text('Restablecer aplicación'),
          subtitle: const Text('Borrar todo y volver al inicio'),
          onTap: () {
            Navigator.pop(context);
            ConfirmationDialogs.showResetAppConfirmation(
              context,
              dataManager,
              onDataChanged,
              onShowSnackBar,
            );
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info_outline, color: Colors.grey),
      title: const Text('Acerca de'),
      subtitle: Text('${AppConstants.appName} v${AppConstants.appVersion}'),
      onTap: () {
        Navigator.pop(context);
        _showAboutDialog(context);
      },
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final data = await dataManager.exportData();
      
      if (context.mounted) {
        ExportImportDialogs.showExportDialog(
          context,
          data,
          allRecordsCount,
          categoriesCount,
        );
      }
      onShowSnackBar('Datos exportados exitosamente', false);
    } catch (e) {
      onShowSnackBar('Error al exportar datos', true);
    }
  }

  void _showAboutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.savings, color: Theme.of(context).primaryColor, size: 28),
          const SizedBox(width: 12),
          const Text(AppConstants.appName),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versión ${AppConstants.appVersion}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(AppConstants.appDescription),
            const SizedBox(height: 16),

            // ---- NUEVA SECCION OPEN SOURCE ----
            const Text(
              'Proyecto Open Source',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Este proyecto es de código abierto. Podes ver el repositorio en:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: () {
                // abre el link al repo
                // necesitas agregar url_launcher en pubspec.yaml
                // url_launcher: ^6.3.0 (o la ultima version)
                launchUrl(Uri.parse('https://github.com/Mentitos/finanzaslibre'));
              },
              child: const Text(
                'github.com/Mentitos/finanzaslibre',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ---- CREATOR ----
            const Text(
              'Creador:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('Matias Gabriel Tello'),

            const SizedBox(height: 16),

            // ---- DONACIONES ----
            // ---- DONACIONES ----
const Text(
  'Apoya el proyecto:',
  style: TextStyle(fontWeight: FontWeight.bold),
),
const SizedBox(height: 4),
Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.purple.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.purple.withOpacity(0.3)),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(Icons.favorite, color: Colors.purple[700], size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Si querés apoyar podés donar por Ualá:',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      InkWell(
        onTap: () async {
          const alias = 'MATIASTELLO54.UALA'; // Cambia esto por tu alias real
          await Clipboard.setData(const ClipboardData(text: alias));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('Alias copiado: $alias'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance_wallet, 
                   color: Colors.purple[700], 
                   size: 18),
              const SizedBox(width: 8),
              const Text(
                'MATIASTELLO54.UALA', // Cambia esto por tu alias real
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.content_copy, 
                   color: Colors.purple[700], 
                   size: 16),
            ],
          ),
        ),
      ),
    ],
  ),
),

            // ---- CARACTERISTICAS ORIGINALES ----
            const Text(
              'Características:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem('Gestión de dinero físico y digital'),
            _buildFeatureItem('Categorías personalizadas'),
            _buildFeatureItem('Historial completo de movimientos'),
            _buildFeatureItem('Estadísticas detalladas'),
            _buildFeatureItem('Exportación e importación de datos'),
            _buildFeatureItem('Retroalimentación y soporte'),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tus datos se guardan localmente en tu dispositivo',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}


  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}