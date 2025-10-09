import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/user_manager.dart';
import 'user_management_section.dart';

class UserListPage extends StatelessWidget {
  final UserManager userManager;
  final VoidCallback onUserChanged;
  final Function(String message, bool isError) onShowSnackBar;

  const UserListPage({
    super.key,
    required this.userManager,
    required this.onUserChanged,
    required this.onShowSnackBar,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.users), // Usaremos 'users' como título de la página
      ),
      // Usamos SingleChildScrollView para manejar el scroll de la lista de usuarios
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: UserManagementSection(
          userManager: userManager,
          // onUserChanged aquí todavía notifica a SettingsMenu.onDataChanged
          // Esto lo controlaremos en SettingsMenu.
          onUserChanged: onUserChanged, 
          onShowSnackBar: onShowSnackBar,
        ),
      ),
    );
  }
}