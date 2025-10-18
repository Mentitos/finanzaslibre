import 'package:flutter/material.dart';
import '../../../services/savings_data_manager.dart';
import '../../../l10n/app_localizations.dart';
import '../../dialogs/confirmation_dialogs.dart';

class DangerZoneSection extends StatelessWidget {
  final SavingsDataManager dataManager;
  final Future<void> Function() onDataChanged;
  final Function(String message, bool isError) onShowSnackBar;
  final AppLocalizations l10n;

  const DangerZoneSection({
    super.key,
    required this.dataManager,
    required this.onDataChanged,
    required this.onShowSnackBar,
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
          leading: const Icon(Icons.delete_sweep, color: Colors.orange),
          title: Text(l10n.deleteAllRecords),
          subtitle: Text(l10n.deleteAllRecordsSubtitle),
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
          title: Text(l10n.resetApp),
          subtitle: Text(l10n.resetAppSubtitle),
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
}