import 'package:flutter/material.dart';
import '../../services/savings_data_manager.dart';
import '../pin_setup_screen.dart';
import '../../l10n/app_localizations.dart';

class SecuritySection extends StatefulWidget {
  final SavingsDataManager dataManager;
  final Function(String message, bool isError) onShowSnackBar;
  final VoidCallback onCloseSettings;

  const SecuritySection({
    super.key,
    required this.dataManager,
    required this.onShowSnackBar,
    required this.onCloseSettings,
  });

  @override
  State<SecuritySection> createState() => _SecuritySectionState();
}

class _SecuritySectionState extends State<SecuritySection> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<bool>(
      future: widget.dataManager.isPinEnabled(),
      builder: (context, snapshot) {
        final isPinEnabled = snapshot.data ?? false;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.only(left: 16, bottom: 8)),
            ListTile(
              leading: Icon(
                isPinEnabled ? Icons.lock : Icons.lock_outline,
                color: isPinEnabled ? Colors.green : Colors.grey,
              ),
              title: Text(l10n.pinSecurityTitle),
              subtitle: Text(
                isPinEnabled
                    ? l10n.pinActiveSubtitle
                    : l10n.pinInactiveSubtitle,
              ),
              trailing: Switch(
                value: isPinEnabled,
                onChanged: (value) async {
                  widget.onCloseSettings();
                  if (value) {
                    await _setupPin(context, l10n);
                  } else {
                    await _disablePin(context, l10n);
                  }
                },
              ),
            ),
            if (isPinEnabled)
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: Text(l10n.changePinTitle),
                subtitle: Text(l10n.changePinSubtitle),
                onTap: () async {
                  widget.onCloseSettings();
                  await _changePin(context, l10n);
                },
              ),
            // Opción para ocultar saldos al iniciar
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),
            FutureBuilder<bool>(
              future: widget.dataManager.loadHideBalancesOnStartup(),
              builder: (context, snapshot) {
                final hideOnStartup = snapshot.data ?? false;
                return ListTile(
                  leading: Icon(
                    hideOnStartup ? Icons.visibility_off : Icons.visibility,
                    color: hideOnStartup ? Colors.indigo : Colors.grey,
                  ),
                  title: const Text('Ocultar saldos al iniciar'),
                  subtitle: const Text(
                    'Activa automáticamente el modo privacidad al abrir la app',
                  ),
                  trailing: Switch(
                    value: hideOnStartup,
                    onChanged: (value) async {
                      await widget.dataManager.saveHideBalancesOnStartup(value);
                      setState(() {}); // Reconstruir para actualizar el switch
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _setupPin(BuildContext context, AppLocalizations l10n) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const PinSetupScreen(isChanging: false),
      ),
    );

    if (result != null) {
      await widget.dataManager.savePin(result['pin']);
      await widget.dataManager.setPinEnabled(true);
      await widget.dataManager.setBiometricEnabled(
        result['biometricEnabled'] ?? false,
      );
      widget.onShowSnackBar(l10n.pinSetupSuccess, false);
    }
  }

  Future<void> _changePin(BuildContext context, AppLocalizations l10n) async {
    final currentPin = await widget.dataManager.loadPin();

    if (currentPin == null) {
      widget.onShowSnackBar(l10n.noPinConfigured, true);
      return;
    }

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PinSetupScreen(isChanging: true, currentPin: currentPin),
      ),
    );

    if (result != null) {
      await widget.dataManager.savePin(result['pin']);
      await widget.dataManager.setBiometricEnabled(
        result['biometricEnabled'] ?? false,
      );
      widget.onShowSnackBar(l10n.pinUpdated, false);
    }
  }

  Future<void> _disablePin(BuildContext context, AppLocalizations l10n) async {
    final currentPin = await widget.dataManager.loadPin();

    if (currentPin == null) {
      await widget.dataManager.setPinEnabled(false);
      widget.onShowSnackBar(l10n.pinDisabled, false);
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.disablePinTitle),
        content: Text(l10n.disablePinSubtitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await widget.dataManager.removePin();
              widget.onShowSnackBar(l10n.pinDisabled, false);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(l10n.disable),
          ),
        ],
      ),
    );
  }
}
