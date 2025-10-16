import 'package:flutter/material.dart';
import '../../services/savings_data_manager.dart';
import '../../l10n/app_localizations.dart'; 
import '../../services/user_manager.dart';
import 'sections/header_section.dart';
import 'sections/account_section.dart';
import 'sections/appearance_section.dart';
import 'sections/data_management_section.dart';
import 'sections/danger_zone_section.dart';
import 'sections/about_section.dart';
import 'security_section.dart';
import 'sections/notifications_section.dart';

class SettingsMenu extends StatelessWidget {
  final SavingsDataManager dataManager;
  final UserManager userManager;
  final Future<void> Function() onDataChanged;
  final Function(String message, bool isError) onShowSnackBar;
  final int allRecordsCount;
  final int categoriesCount;

  const SettingsMenu({
    super.key,
    required this.dataManager,
    required this.userManager,
    required this.onDataChanged,
    required this.onShowSnackBar,
    required this.allRecordsCount,
    required this.categoriesCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
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
            HeaderSection(l10n: l10n),
            AccountSection(
              userManager: userManager,
              onShowSnackBar: onShowSnackBar,
              onDataChanged: onDataChanged,
            ),
            const Divider(height: 30),
            AppearanceSection(l10n: l10n),
            const Divider(height: 30),
            SecuritySection(
              dataManager: dataManager,
              onShowSnackBar: onShowSnackBar,
              onCloseSettings: () => Navigator.pop(context),
            ),
            const Divider(height: 30),
            NotificationsSection(),
            
            const Divider(height: 30),
            DataManagementSection(
              dataManager: dataManager,
              onDataChanged: onDataChanged,
              onShowSnackBar: onShowSnackBar,
              allRecordsCount: allRecordsCount,
              categoriesCount: categoriesCount,
              l10n: l10n,
            ),
            const Divider(),
            DangerZoneSection(
              dataManager: dataManager,
              onDataChanged: onDataChanged,
              onShowSnackBar: onShowSnackBar,
              l10n: l10n,
            ),
            const Divider(),
            AboutSection(l10n: l10n),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}