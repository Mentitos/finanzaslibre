import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../main.dart';

class LanguageDialog {
  static void show(
    BuildContext context,
    String currentLanguage,
    AppLocalizations l10n,
  ) {
    final systemLocale =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: RadioGroup<String>(
          groupValue: currentLanguage,
          onChanged: (value) {
            if (value != null) {
              MyApp.of(context).changeLanguage(value);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(l10n.systemLanguage),
                subtitle: Text(
                  systemLocale == 'es'
                      ? 'Español (${l10n.system})'
                      : systemLocale == 'en'
                      ? 'English (${l10n.system})'
                      : 'English (${l10n.systemDefault})',
                ),
                value: 'system',
              ),
              const Divider(),
              RadioListTile<String>(title: const Text('Español'), value: 'es'),
              RadioListTile<String>(title: const Text('English'), value: 'en'),
            ],
          ),
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
}
