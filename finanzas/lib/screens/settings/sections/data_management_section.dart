import 'package:flutter/material.dart';
import '../../../services/savings_data_manager.dart';
import '../../../l10n/app_localizations.dart';
import '../../dialogs/export_import_dialogs.dart';

class DataManagementSection extends StatelessWidget {
  final SavingsDataManager dataManager;
  final Future<void> Function() onDataChanged;
  final Function(String message, bool isError) onShowSnackBar;
  final int allRecordsCount;
  final int categoriesCount;
  final AppLocalizations l10n;

  const DataManagementSection({
    super.key,
    required this.dataManager,
    required this.onDataChanged,
    required this.onShowSnackBar,
    required this.allRecordsCount,
    required this.categoriesCount,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          
        ),
        ListTile(
          leading: const Icon(Icons.file_download, color: Colors.blue),
          title: Text(l10n.exportData),
          subtitle: Text(l10n.exportDataSubtitle),
          onTap: () {
            Navigator.pop(context);
            _exportData(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.file_upload, color: Colors.green),
          title: Text(l10n.importData),
          subtitle: Text(l10n.importDataSubtitle),
          onTap: () {
            Navigator.pop(context);
            ExportImportDialogs.showImportDialog(
              context,
              dataManager,
              onDataChanged,
              onShowSnackBar,
              l10n,
            );
          },
        ),
      ],
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
          l10n,
          dataManager, 
        );
      }
      onShowSnackBar(l10n.dataExportSuccess, false);
    } catch (e) {
      onShowSnackBar(l10n.dataExportError, true);
    }
  }
}