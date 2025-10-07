import 'package:flutter/material.dart';
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
            Text(l10n.dataExported), // traducido
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${l10n.totalRecords}: $recordsCount'), // traducido
              Text('${l10n.categories}: $categoriesCount'), // traducido
              const SizedBox(height: 16),
              Text(
                l10n.exportInstructions, // traducido
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  jsonEncode(data),
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close), // traducido
          ),
        ],
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
        title: Text(l10n.importData), // traducido
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.pasteExportedData), // traducido
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: '{"exportDate": "...", ...}', // traducido
              ),
              maxLines: 8,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel), // traducido
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
                    onShowSnackBar(l10n.dataImportedSuccessfully, false); // traducido
                  }
                } else {
                  onShowSnackBar(l10n.errorImportingData, true); // traducido
                }
              } catch (e) {
                onShowSnackBar(l10n.invalidDataFormat, true); // traducido
              }
            },
            child: Text(l10n.import), // traducido
          ),
        ],
      ),
    );
  }
}
