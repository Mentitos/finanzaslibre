import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../services/savings_data_manager.dart';
import '../../l10n/app_localizations.dart';

class ExportImportDialogs {
  static void showExportDialog(
    BuildContext context,
    Map<String, dynamic> data,
    int recordsCount,
    int categoriesCount,
    AppLocalizations l10n,
    SavingsDataManager dataManager,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDarkMode ? Colors.grey[800] : Colors.grey[200];
    final textColor = isDarkMode ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(l10n.dataExported),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${l10n.totalRecords}: $recordsCount'),
              Text('${l10n.categories}: $categoriesCount'),
              const SizedBox(height: 16),
              Text(
                'Selecciona formato de exportación:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              // Opción 1: JSON
              _buildExportOption(
                context,
                icon: Icons.description,
                title: 'JSON',
                subtitle: 'Formato de datos estándar',
                color: Colors.blue,
                onTap: () {
                  _copyToClipboard(
                    context,
                    jsonEncode(data),
                    l10n,
                  );
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              
              // Opción 2: CSV
              _buildExportOption(
                context,
                icon: Icons.table_chart,
                title: 'CSV',
                subtitle: 'Formato de hoja de cálculo simple',
                color: Colors.green,
                onTap: () async {
                  final csvData = await dataManager.exportToCSV();
                  if (context.mounted) {
                    _copyToClipboard(context, csvData, l10n);
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 8),
              
              // Opción 3: Excel
              _buildExportOption(
                context,
                icon: Icons.table_chart_outlined,
                title: 'Excel',
                subtitle: 'Formato Excel con múltiples hojas',
                color: Colors.orange,
                onTap: () async {
                  final excelData = await dataManager.exportToExcel();
                  if (context.mounted) {
                    _copyToClipboard(context, excelData, l10n);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  static Widget _buildExportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }

  static void _copyToClipboard(
    BuildContext context,
    String data,
    AppLocalizations l10n,
  ) {
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Datos copiados al portapapeles'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showImportDialog(
    BuildContext context,
    SavingsDataManager dataManager,
    Future<void> Function() onDataChanged,
    Function(String message, bool isError) onShowSnackBar,
    AppLocalizations l10n,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.importData),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.pasteExportedData),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: '{"exportDate": "...", ...}',
              ),
              maxLines: 8,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final data = jsonDecode(controller.text);
                final success = await dataManager.importData(data);

                if (success) {
                  await onDataChanged();
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    onShowSnackBar(l10n.dataImportedSuccessfully, false);
                  }
                } else {
                  onShowSnackBar(l10n.errorImportingData, true);
                }
              } catch (e) {
                onShowSnackBar(l10n.invalidDataFormat, true);
              }
            },
            child: Text(l10n.import),
          ),
        ],
      ),
    );
  }
}