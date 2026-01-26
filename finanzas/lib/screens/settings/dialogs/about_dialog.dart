import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/app_localizations.dart';
import '../../../constants/app_constants.dart';

class AboutDialogWidget {
  static void show(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.savings,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
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
              _buildOpenSourceSection(context, l10n),
              const SizedBox(height: 16),
              _buildSuggestionsSection(context, l10n),
              const SizedBox(height: 16),
              _buildCreatorSection(l10n),
              const SizedBox(height: 16),
              _buildSupportSection(context, l10n),
              const SizedBox(height: 16),
              _buildFeaturesSection(l10n),
              const SizedBox(height: 16),
              _buildDataStorageInfo(context, l10n),
              const SizedBox(height: 16),
              _buildWhatsNewSection(context),
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

  static Widget _buildOpenSourceSection(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.openSourceProject,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(l10n.openSourceDescription, style: const TextStyle(fontSize: 13)),
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
      ],
    );
  }

  static Widget _buildSuggestionsSection(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              query:
                  'subject=Feedback FinanzasLibre&body=Hola, quisiera sugerir...',
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
      ],
    );
  }

  static Widget _buildCreatorSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.creator, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Matias Gabriel Tello'),
      ],
    );
  }

  static Widget _buildSupportSection(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
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
          _buildUalaButton(context, l10n),
          const SizedBox(height: 12),
          _buildPaypalButton(context),
        ],
      ),
    );
  }

  static Widget _buildUalaButton(BuildContext context, AppLocalizations l10n) {
    return InkWell(
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
          color: Colors.purple.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: Colors.purple[700],
              size: 18,
            ),
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
    );
  }

  static Widget _buildPaypalButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        try {
          final url = Uri.parse(
            'https://www.paypal.com/paypalme/matiasgabrieltello',
          );
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
    );
  }

  static Widget _buildFeaturesSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  static Widget _buildFeatureItem(String text) {
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

  static Widget _buildDataStorageInfo(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
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
    );
  }

  static Widget _buildWhatsNewSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Novedades v1.2.4',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildFeatureItem('Nuevas paletas de colores personalizables'),
        _buildFeatureItem('Mejoras de calidad de vida'),
        _buildFeatureItem('Corrección de errores menores'),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Gracias Morena por esta actualización ❤️',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
