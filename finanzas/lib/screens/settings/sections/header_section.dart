import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class HeaderSection extends StatelessWidget {
  final AppLocalizations l10n;

  const HeaderSection({
    super.key,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
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
}