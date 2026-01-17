import 'package:finanzas/screens/settings/dialogs/palette_selector_dialog.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart';
import '../../../models/color_palette.dart';
import '../../../services/palette_manager.dart';
import 'dialogs/language_dialog.dart';


class AppearanceSection extends StatefulWidget {
  final AppLocalizations l10n;

  const AppearanceSection({
    super.key,
    required this.l10n,
  });

  @override
  State<AppearanceSection> createState() => _AppearanceSectionState();
}

class _AppearanceSectionState extends State<AppearanceSection> {
  ColorPalette? _currentPalette;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentPalette();
  }

  Future<void> _loadCurrentPalette() async {
    final palette = await PaletteManager.loadPalette();
    setState(() {
      _currentPalette = palette;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
        ),
        
        // Selector de Idioma
        ListTile(
          leading: const Icon(Icons.language, color: Colors.blue),
          title: Text(widget.l10n.language),
          subtitle: Text(
            currentLocale.languageCode == 'es' ? 'Español' : 'English',
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            LanguageDialog.show(context, currentLocale.languageCode, widget.l10n);
          },
        ),

        // Selector de Paleta de Colores
        ListTile(
          leading: Icon(
            Icons.palette,
            color: _currentPalette?.seedColor ?? Colors.green,
          ),
          title: const Text('Paleta de Colores'),
          subtitle: Text(
            _currentPalette?.name ?? '🌿 Verde',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Círculo de color actual
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _currentPalette?.seedColor ?? Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => PaletteSelectorDialog(
                currentPalette: _currentPalette ?? ColorPalette.predefinedPalettes.first,
                onPaletteSelected: (palette) async {
                  setState(() => _currentPalette = palette);
                  // Aplicar tema
                  if (context.mounted) {
                    MyApp.of(context).changePalette(palette);
                  }
                },
              ),
            );
          },
        ),
        
        // Modo Oscuro
        ListTile(
          leading: Icon(
            Theme.of(context).brightness == Brightness.dark
                ? Icons.dark_mode
                : Icons.light_mode,
            color: Colors.amber,
          ),
          title: Text(widget.l10n.darkMode),
          subtitle: Text(
            Theme.of(context).brightness == Brightness.dark
                ? widget.l10n.darkModeOn
                : widget.l10n.lightModeOn,
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