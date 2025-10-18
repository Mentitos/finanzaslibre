import 'package:flutter/material.dart';
import '../../services/savings_data_manager.dart';
import '../../services/user_manager.dart';
import '../../l10n/app_localizations.dart';
import 'sections/about_section.dart';
import 'sections/appearance_section.dart';
import 'sections/data_management_section.dart';
import 'sections/danger_zone_section.dart';
import 'sections/notifications_section.dart';
import 'security_section.dart';
import 'user_list_page.dart';

class SettingsScreen extends StatelessWidget {
  final SavingsDataManager dataManager;
  final UserManager userManager;
  final Future<void> Function() onDataChanged;
  final Function(String message, bool isError) onShowSnackBar;
  final int allRecordsCount;
  final int categoriesCount;

  const SettingsScreen({
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Usuarios
          _buildSettingsCard(
            context: context,
            icon: Icons.people,
            iconColor: Colors.blue,
            title: l10n.users,
            subtitle: 'Gestionar usuarios y billeteras',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserListPage(
                    userManager: userManager,
                    onUserChanged: onDataChanged,
                    onShowSnackBar: onShowSnackBar,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Preferencias
          _buildSettingsCard(
            context: context,
            icon: Icons.tune,
            iconColor: Colors.purple,
            title: 'Preferencias',
            subtitle: 'Apariencia, notificaciones y seguridad',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _PreferencesSettingsScreen(
                    dataManager: dataManager,
                    onShowSnackBar: onShowSnackBar,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Datos
          _buildSettingsCard(
            context: context,
            icon: Icons.storage,
            iconColor: Colors.orange,
            title: 'Datos',
            subtitle: 'Exportar, importar y gestionar datos',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _DataSettingsScreen(
                    dataManager: dataManager,
                    onDataChanged: onDataChanged,
                    onShowSnackBar: onShowSnackBar,
                    allRecordsCount: allRecordsCount,
                    categoriesCount: categoriesCount,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Notificaciones
          

          const Divider(height: 40),

          // Acerca de
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AboutSection(l10n: l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// PANTALLAS SECUNDARIAS (en el mismo archivo)
// ============================================

class _PreferencesSettingsScreen extends StatelessWidget {
  final SavingsDataManager dataManager;
  final Function(String message, bool isError) onShowSnackBar;

  const _PreferencesSettingsScreen({
    required this.dataManager,
    required this.onShowSnackBar,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferencias'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Apariencia
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        'Apariencia',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppearanceSection(l10n: l10n),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notificaciones
          
          

          // Seguridad
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'Seguridad',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SecuritySection(
                    dataManager: dataManager,
                    onShowSnackBar: onShowSnackBar,
                    onCloseSettings: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),


        const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notifications, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Notificaciones',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  NotificationsSection(),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}

class _DataSettingsScreen extends StatelessWidget {
  final SavingsDataManager dataManager;
  final Future<void> Function() onDataChanged;
  final Function(String message, bool isError) onShowSnackBar;
  final int allRecordsCount;
  final int categoriesCount;

  const _DataSettingsScreen({
    required this.dataManager,
    required this.onDataChanged,
    required this.onShowSnackBar,
    required this.allRecordsCount,
    required this.categoriesCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.import_export, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Gestión de datos',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DataManagementSection(
                    dataManager: dataManager,
                    onDataChanged: onDataChanged,
                    onShowSnackBar: onShowSnackBar,
                    allRecordsCount: allRecordsCount,
                    categoriesCount: categoriesCount,
                    l10n: l10n,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'Zona de peligro',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DangerZoneSection(
                    dataManager: dataManager,
                    onDataChanged: onDataChanged,
                    onShowSnackBar: onShowSnackBar,
                    l10n: l10n,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}