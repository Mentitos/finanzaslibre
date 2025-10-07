import 'package:flutter/material.dart';
import '../../services/savings_data_manager.dart';
import '../../constants/app_constants.dart';
import 'security_section.dart';
import '../dialogs/export_import_dialogs.dart';
import '../dialogs/confirmation_dialogs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../../main.dart';
import '../../l10n/app_localizations.dart'; 

class SettingsMenu extends StatelessWidget {
  final SavingsDataManager dataManager;
  final Future<void> Function() onDataChanged;
  final Function(String message, bool isError) onShowSnackBar;
  final int allRecordsCount;
  final int categoriesCount;

  const SettingsMenu({
    super.key,
    required this.dataManager,
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
            _buildHeader(context, l10n),
            const Divider(height: 30),
            _buildAppearanceSection(context, l10n),
            const Divider(height: 30),
            SecuritySection(
              dataManager: dataManager,
              onShowSnackBar: onShowSnackBar,
              onCloseSettings: () => Navigator.pop(context),
            ),
            const Divider(height: 30),
            _buildDataManagementSection(context, l10n),
            const Divider(),
            _buildDangerZoneSection(context, l10n),
            const Divider(),
            _buildAboutSection(context, l10n),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        const Icon(Icons.settings, size: 28),
        const SizedBox(width: 12),
        Text(
          l10n.settings,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(BuildContext context, AppLocalizations l10n) {
    final currentLocale = Localizations.localeOf(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            l10n.appearance,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.language, color: Colors.blue),
          title: Text(l10n.language),
          subtitle: Text(
            currentLocale.languageCode == 'es' ? 'Español' : 'English',
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showLanguageDialog(context, currentLocale.languageCode, l10n);
          },
        ),
        ListTile(
          leading: Icon(
            Theme.of(context).brightness == Brightness.dark
                ? Icons.dark_mode
                : Icons.light_mode,
            color: Colors.amber,
          ),
          title: Text(l10n.darkMode),
          subtitle: Text(
            Theme.of(context).brightness == Brightness.dark
                ? l10n.darkModeOn
                : l10n.lightModeOn,
          ),
          trailing: Switch(
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (value) {
              MyApp.of(context).toggleTheme();
            },
          ),
        ),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context, String currentLanguage, AppLocalizations l10n) {
  final systemLocale = WidgetsBinding.instance.platformDispatcher.locale.languageCode;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.selectLanguage),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<String>(
            title: Text(l10n.systemLanguage),
            subtitle: Text(
              // Mostrar idioma detectado del sistema (ej: "Español (sistema)")
              systemLocale == 'es'
                  ? 'Español (${l10n.system})'
                  : systemLocale == 'en'
                      ? 'English (${l10n.system})'
                      : 'English (${l10n.systemDefault})',
            ),
            value: 'system',
            groupValue: currentLanguage,
            onChanged: (value) {
              if (value != null) {
                // Detecta idioma del sistema
                String locale = WidgetsBinding.instance.platformDispatcher.locale.languageCode;

                // Si no es español ni inglés, forzar inglés
                if (locale != 'es' && locale != 'en') {
                  locale = 'en';
                }

                MyApp.of(context).changeLanguage(locale);
                Navigator.pop(context);
              }
            },
          ),
          const Divider(),
          RadioListTile<String>(
            title: const Text('Español'),
            value: 'es',
            groupValue: currentLanguage,
            onChanged: (value) {
              if (value != null) {
                MyApp.of(context).changeLanguage(value);
                Navigator.pop(context);
              }
            },
          ),
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: currentLanguage,
            onChanged: (value) {
              if (value != null) {
                MyApp.of(context).changeLanguage(value);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    ),
  );
}


  Widget _buildDataManagementSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            l10n.dataManagement,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.file_download, color: Colors.blue),
          title: Text(l10n.exportData),
          subtitle: Text(l10n.exportDataSubtitle),
          onTap: () {
            Navigator.pop(context);
            _exportData(context, l10n);
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

  Widget _buildDangerZoneSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            l10n.dangerZone,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
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

  Widget _buildAboutSection(BuildContext context, AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.info_outline, color: Colors.grey),
      title: Text(l10n.about),
      subtitle: Text('${l10n.appName} v${AppConstants.appVersion}'),
      onTap: () {
        Navigator.pop(context);
        _showAboutDialog(context, l10n);
      },
    );
  }

  Future<void> _exportData(BuildContext context, AppLocalizations l10n) async {
    try {
      final data = await dataManager.exportData();
      
      if (context.mounted) {
        ExportImportDialogs.showExportDialog(
          context,
          data,
          allRecordsCount,
          categoriesCount,
          l10n,
        );
      }
      onShowSnackBar(l10n.dataExportSuccess, false);
    } catch (e) {
      onShowSnackBar(l10n.dataExportError, true);
    }
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.savings, color: Theme.of(context).primaryColor, size: 28),
            const SizedBox(width: 12),
            Text(l10n.appName),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l10n.version} ${AppConstants.appVersion}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(l10n.appDescription),
              const SizedBox(height: 16),
              Text(
                l10n.openSourceProject,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.openSourceDescription,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () {
                  launchUrl(Uri.parse('https://github.com/Mentitos/finanzaslibre'));
                },
                child: const Text(
                  'github.com/Mentitos/finanzaslibre',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.suggestions,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () async {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'sugerenciasfinanzaslibre@gmail.com',
                    query: 'subject=Feedback FinanzasLibre&body=Hola, quisiera sugerir...', 
                  );
                  await launchUrl(emailLaunchUri);
                },
                child: const Text(
                  'sugerenciasfinanzaslibre@gmail.com',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.creator,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('Matias Gabriel Tello'),
              const SizedBox(height: 16),
              Text(
  l10n.supportProject,
  style: const TextStyle(fontWeight: FontWeight.bold),
),
const SizedBox(height: 4),
Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.purple.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.purple.withOpacity(0.3)),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(Icons.favorite, color: Colors.purple[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.donateUala,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      InkWell(
        onTap: () async {
          const alias = 'MATIASTELLO54.UALA';
          await Clipboard.setData(const ClipboardData(text: alias));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('${l10n.aliasCopied}: $alias'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance_wallet,
                  color: Colors.purple[700], size: 18),
              const SizedBox(width: 8),
              const Text(
                'MATIASTELLO54.UALA',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.content_copy, color: Colors.purple[700], size: 16),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      InkWell(
  onTap: () async {
    try {
      final url = Uri.parse('https://www.paypal.com/paypalme/matiasgabrieltello');
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir PayPal: $e')),
        );
      }
    }
  },
  child: const Text(
    'PayPal: paypal.me/matiasgabrieltello',
    style: TextStyle(
      fontSize: 14,
      color: Colors.blue,
      decoration: TextDecoration.underline,
    ),
  ),
),


    ],
  ),
),
              const SizedBox(height: 16),
              Text(
                l10n.features,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildFeatureItem(l10n.feature1),
              _buildFeatureItem(l10n.feature2),
              _buildFeatureItem(l10n.feature3),
              _buildFeatureItem(l10n.feature4),
              _buildFeatureItem(l10n.feature5),
              _buildFeatureItem(l10n.feature6),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.dataStoredLocally,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}