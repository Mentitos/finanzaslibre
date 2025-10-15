import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/savings_data_manager.dart';
import '../../l10n/app_localizations.dart';

class ExportImportDialogs {
  static Future<Directory> _getExportDirectory() async {
    late Directory exportDir;
    
    if (Platform.isAndroid) {
      try {
        final String? downloadsPath = await _getDownloadsPath();
        if (downloadsPath != null) {
          exportDir = Directory('$downloadsPath/SavingsExport');
          if (!await exportDir.exists()) {
            await exportDir.create(recursive: true);
          }
          debugPrint('✅ Carpeta SavingsExport creada en: ${exportDir.path}');
          return exportDir;
        }
      } catch (e) {
        debugPrint('⚠️ No se pudo acceder a Downloads: $e');
      }
      
      final appDocDir = await getApplicationDocumentsDirectory();
      exportDir = Directory('${appDocDir.path}/SavingsExport');
    } else {
      final appDocDir = await getApplicationDocumentsDirectory();
      exportDir = Directory('${appDocDir.path}/SavingsExport');
    }
    
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    
    debugPrint('✅ Carpeta SavingsExport creada en: ${exportDir.path}');
    return exportDir;
  }

  static Future<String?> _getDownloadsPath() async {
    final directory = Directory('/storage/emulated/0/Download');
    if (await directory.exists()) {
      return directory.path;
    }
    return null;
  }

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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              l10n.dataExported,
              style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
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
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.orange[900]?.withOpacity(0.3)
                      : Colors.orange[50],
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.orange[700]!
                        : Colors.orange,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.orange[400]
                          : Colors.orange[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.onlyJsonCanBeImported,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.orange[300]
                              : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${l10n.totalRecords}: $recordsCount',
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
              Text(
                '${l10n.categories}: $categoriesCount',
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.selectExportFormat,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              const SizedBox(height: 12),
              _buildExportOption(
                context,
                icon: Icons.description,
                title: 'JSON',
                subtitle: l10n.standardDataFormat,
                color: Colors.blue,
                onTap: () async {
                  final jsonString = jsonEncode(data);
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (context.mounted) {
                      _showJsonDialog(context, jsonString, l10n);
                    }
                  }
                },
              ),
              const SizedBox(height: 8),
              _buildExportOption(
                context,
                icon: Icons.table_chart,
                title: 'CSV',
                subtitle: l10n.simpleSpreadsheetFormat,
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
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
              ),
              const SizedBox(height: 8),
              _buildExportOption(
                context,
                icon: Icons.table_chart_outlined,
                title: 'Excel',
                subtitle: l10n.excelFormatWithMultipleSheets,
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
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
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

  static void _showJsonDialog(
    BuildContext context,
    String jsonString,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Row(
          children: [
            Icon(Icons.code, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              l10n.exportJson,
              style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.jsonFormat,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : Colors.grey[100],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Text(
                  jsonString,
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: jsonString));
                    if (dialogContext.mounted) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(l10n.jsonCopiedToClipboard),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy),
                  label: Text(l10n.copy),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final exportDir = await _getExportDirectory();
                      final file = File('${exportDir.path}/datos_finanzas.json');
                      await file.writeAsString(jsonString);
                      
                      debugPrint('✅ JSON guardado en: ${file.path}');

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                        
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
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
                                      Text(l10n.fileSaved('datos_finanzas.json')),
                                      const SizedBox(height: 4),
                                      Text(
                                        file.path,
                                        style: const TextStyle(fontSize: 9, color: Colors.white70),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(text: file.path));
                                              if (dialogContext.mounted) {
                                                ScaffoldMessenger.of(dialogContext).showSnackBar(
                                                  SnackBar(
                                                    content: Text(l10n.pathCopied),
                                                    duration: const Duration(seconds: 1),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Text(
                                              l10n.copyPath,
                                              style: const TextStyle(
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
                                            child: Text(
                                              l10n.share,
                                              style: const TextStyle(
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
                            duration: const Duration(seconds: 6),
                          ),
                        );
                      }
                    } catch (e) {
                      debugPrint('❌ Error guardando JSON: $e');
                      if (dialogContext.mounted) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.error, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(child: Text('${l10n.error}: $e')),
                              ],
                            ),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.download),
                  label: Text(l10n.download),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
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
      color: Colors.transparent,
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
                        color: Theme.of(context).textTheme.bodySmall?.color,
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
      final exportDir = await _getExportDirectory();
      final file = File('${exportDir.path}/$filename');

      await file.writeAsString(content);

      debugPrint('✅ Archivo guardado en: ${file.path}');

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
                      Text(l10n.fileSaved(filename)),
                      const SizedBox(height: 4),
                      Text(
                        file.path,
                        style: const TextStyle(fontSize: 9, color: Colors.white70),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: file.path));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.pathCopied),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              l10n.copyPath,
                              style: const TextStyle(
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
                            child: Text(
                              l10n.share,
                              style: const TextStyle(
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
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error guardando archivo: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('${l10n.error}: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  static Future<void> _saveToFileBytes(
    BuildContext context,
    List<int> bytes,
    String filename,
    AppLocalizations l10n,
  ) async {
    try {
      final exportDir = await _getExportDirectory();
      final file = File('${exportDir.path}/$filename');

      await file.writeAsBytes(bytes);

      debugPrint('✅ Archivo guardado en: ${file.path}');

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
                      Text(l10n.fileSaved(filename)),
                      const SizedBox(height: 4),
                      Text(
                        file.path,
                        style: const TextStyle(fontSize: 9, color: Colors.white70),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: file.path));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.pathCopied),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              l10n.copyPath,
                              style: const TextStyle(
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
                            child: Text(
                              l10n.share,
                              style: const TextStyle(
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
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error guardando archivo: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('${l10n.error}: $e')),
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
      scrollable: true, 
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(
        l10n.importData,
        style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
      ),
      content: SingleChildScrollView( 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue[900]?.withOpacity(0.3)
                    : Colors.blue[50],
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[700]!
                      : Colors.blue,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.blue[300]
                        : Colors.blue[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.onlyJsonFilesAccepted,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue[300]
                            : Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.pasteExportedData,
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final clipboardData =
                        await Clipboard.getData('text/plain');
                    if (clipboardData?.text != null) {
                      controller.text = clipboardData!.text!;
                      onShowSnackBar(l10n.jsonPastedFromClipboard, false);
                    } else {
                      onShowSnackBar(l10n.noTextInClipboard, true);
                    }
                  },
                  icon: const Icon(Icons.paste),
                  label: Text(l10n.paste),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final result = await _pickJsonFile();
                      if (result != null) {
                        controller.text = result;
                        onShowSnackBar(l10n.jsonFileLoaded, false);
                      }
                    } catch (e) {
                      debugPrint('Error al seleccionar archivo: $e');
                      onShowSnackBar(l10n.errorOpeningFile, true);
                    }
                  },
                  icon: const Icon(Icons.folder_open),
                  label: Text(l10n.file),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: '{"exportDate": "...", ...}',
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : Colors.grey[100],
                filled: true,
              ),
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
              maxLines: 8,
            ),
          ],
        ),
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


  static Future<String?> _pickJsonFile() async {
    try {
      if (Platform.isAndroid) {
        const platform = MethodChannel('com.example.finanzas/filepicker');
        
        try {
          final String result = await platform.invokeMethod('openJsonPicker');
          debugPrint('✅ Archivo seleccionado');
          return result;
        } on PlatformException catch (e) {
          debugPrint('❌ Error del método nativo: ${e.message}');
          return null;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error seleccionando archivo: $e');
      return null;
    }
  }
}