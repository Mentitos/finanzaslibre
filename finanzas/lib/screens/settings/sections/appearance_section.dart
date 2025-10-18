import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart';
import 'dialogs/language_dialog.dart';

class AppearanceSection extends StatelessWidget {
  final AppLocalizations l10n;

  const AppearanceSection({
    super.key,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          
        ),
        ListTile(
          leading: const Icon(Icons.language, color: Colors.blue),
          title: Text(l10n.language),
          subtitle: Text(
            currentLocale.languageCode == 'es' ? 'Español' : 'English',
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            LanguageDialog.show(context, currentLocale.languageCode, l10n);
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
}