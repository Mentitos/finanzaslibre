import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/user_manager.dart';
import '../user_list_page.dart';

class AccountSection extends StatelessWidget {
  final UserManager userManager;
  final Function(String message, bool isError) onShowSnackBar;
  final Future<void> Function() onDataChanged;

  const AccountSection({
    super.key,
    required this.userManager,
    required this.onShowSnackBar,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            l10n.accounts,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.people, color: Colors.blueGrey),
          title: Text(l10n.userManagement),
          subtitle: Text(l10n.manageUsersAndWallets),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => UserListPage(
                  userManager: userManager,
                  onShowSnackBar: onShowSnackBar,
                  onUserChanged: onDataChanged,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}