import 'package:flutter/material.dart';
import '../../services/savings_data_manager.dart';
import '../../l10n/app_localizations.dart';

class ConfirmationDialogs {
  static void showClearRecordsConfirmation(
    BuildContext context,
    SavingsDataManager dataManager,
    Future<void> Function() onDataChanged,
    Function(String message, bool isError) onShowSnackBar,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
            Text(l10n.deleteRecordsTitle), // antes 'Eliminar registros'
          ],
        ),
        content: Text(l10n.deleteRecordsSubtitle), // antes '¿Estás seguro...'
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel), // antes 'Cancelar'
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await dataManager.saveRecords([]);
              await onDataChanged();
              onShowSnackBar(l10n.allRecordsDeleted, false); // antes 'Todos los registros eliminados'
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(l10n.deleteAll), // antes 'Eliminar todo'
          ),
        ],
      ),
    );
  }

  static void showResetAppConfirmation(
    BuildContext context,
    SavingsDataManager dataManager,
    Future<void> Function() onDataChanged,
    Function(String message, bool isError) onShowSnackBar,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.red),
            const SizedBox(width: 8),
            Text(l10n.resetAppTitle), // antes 'Restablecer app'
          ],
        ),
        content: Text(l10n.resetAppSubtext), // antes '¿Estás seguro...'
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel), // antes 'Cancelar'
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await dataManager.clearAllData();
              await onDataChanged();
              onShowSnackBar(l10n.appReset, false); // antes 'Aplicación restablecida'
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.reset), // antes 'Restablecer'
          ),
        ],
      ),
    );
  }
}
