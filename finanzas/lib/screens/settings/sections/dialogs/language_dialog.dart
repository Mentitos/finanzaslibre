import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../main.dart';

class LanguageDialog {
  static void show(BuildContext context, String currentLanguage, AppLocalizations l10n) {
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
                  String locale = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
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
}