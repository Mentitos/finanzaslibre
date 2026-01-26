import 'package:flutter/material.dart';
import '../../services/savings_data_manager.dart';
import '../../services/user_manager.dart';
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
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAllRecords),
        content: Text(l10n.clearRecordsConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              try {
                final userManager = UserManager();
                final currentUser = await userManager.getCurrentUser();

                if (currentUser != null) {
                  await dataManager.clearUserData();
                  await onDataChanged();
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  onShowSnackBar(l10n.recordsDeleted, false);
                }
              } catch (e) {
                onShowSnackBar('${l10n.error}: $e', true);
              }
            },
            child: Text(l10n.delete),
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
    bool keepRecords = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.resetApp),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.resetAppCompletelyMessage,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.blue[700],
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.alwaysKept,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 26),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.mainWalletKept,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.userProfileKept,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: keepRecords,
                            onChanged: (value) {
                              setState(() {
                                keepRecords = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.keepRecordsOption,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[800],
                                  ),
                                ),
                                Text(
                                  l10n.keepMainWalletHistory,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red[700],
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.willBeDeleted,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 26),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.additionalWalletsDeleted,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (keepRecords)
                              Text(
                                l10n.customCategoriesDeleted,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[700],
                                ),
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.allRecordsHistoryDeleted,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.allCategoriesDeleted,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                try {
                  final userManager = UserManager();

                  if (keepRecords) {
                    await userManager.resetAppKeepingDefaultUser();
                    await dataManager.clearAllDataExceptDefaultUser();

                    if (context.mounted) {
                      Navigator.pop(context);
                      onShowSnackBar(l10n.appResetWithRecordsKept, false);
                    }
                  } else {
                    await userManager.resetAppKeepingDefaultUser();
                    await dataManager.clearAllData();

                    if (context.mounted) {
                      Navigator.pop(context);
                      onShowSnackBar(l10n.appResetAsNew, false);
                    }
                  }

                  await onDataChanged();
                } catch (e) {
                  onShowSnackBar('${l10n.error}: $e', true);
                }
              },
              child: Text(l10n.reset),
            ),
          ],
        ),
      ),
    );
  }
}
