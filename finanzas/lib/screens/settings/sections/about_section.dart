import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../dialogs/about_dialog.dart';

class AboutSection extends StatelessWidget {
  final AppLocalizations l10n;

  const AboutSection({
    super.key,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info_outline, color: Colors.grey),
      title: Text(l10n.about),
      subtitle: Text('${l10n.appName} v${_getAppVersion()}'),
      onTap: () {
        Navigator.pop(context);
        AboutDialogWidget.show(context, l10n);
      },
    );
  }

  String _getAppVersion() {
    // Importar AppConstants desde constants/app_constants.dart
    return '1.0.0';
  }
}