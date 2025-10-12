import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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
                onTap: () async {
                  await _saveToFile(
                    context,
                    jsonEncode(data),
                    'datos_finanzas.json',
                    l10n,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
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
                    await _saveToFile(
                      context,
                      csvData,
                      'datos_finanzas.csv',
                      l10n,
                    );
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
                  final excelBytes = await dataManager.exportToExcel();
                  if (context.mounted && excelBytes.isNotEmpty) {
                    await _saveToFileBytes(
                      context,
                      excelBytes,
                      'datos_finanzas.xlsx',
                      l10n,
                    );
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

  static Future<void> _saveToFile(
    BuildContext context,
    String content,
    String filename,
    AppLocalizations l10n,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');

      await file.writeAsString(content);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Archivo guardado'),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: file.path));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Ruta copiada'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: const Text(
                              'Copiar ruta',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Share.shareXFiles([XFile(file.path)]);
                            },
                            child: const Text(
                              'Compartir',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Nueva función para guardar bytes (para Excel)
  static Future<void> _saveToFileBytes(
    BuildContext context,
    List<int> bytes,
    String filename,
    AppLocalizations l10n,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');

      await file.writeAsBytes(bytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Archivo Excel guardado'),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: file.path));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Ruta copiada'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: const Text(
                              'Copiar ruta',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Share.shareXFiles([XFile(file.path)]);
                            },
                            child: const Text(
                              'Compartir',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error guardando Excel: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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