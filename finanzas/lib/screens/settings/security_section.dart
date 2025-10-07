import 'package:flutter/material.dart';
import '../../services/savings_data_manager.dart';
import '../pin_setup_screen.dart';
import '../../l10n/app_localizations.dart';


class SecuritySection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<bool>(
      future: dataManager.isPinEnabled(),
      builder: (context, snapshot) {
        final isPinEnabled = snapshot.data ?? false;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text(
                l10n.security, // antes 'Seguridad'
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                isPinEnabled ? Icons.lock : Icons.lock_outline,
                color: isPinEnabled ? Colors.green : Colors.grey,
              ),
              title: Text(l10n.pinSecurityTitle), // antes 'PIN de seguridad'
              subtitle: Text(isPinEnabled 
                  ? l10n.pinActiveSubtitle // antes 'Protección activa con PIN de 4 dígitos'
                  : l10n.pinInactiveSubtitle // antes 'Protege tu app con un PIN'
              ),
              trailing: Switch(
                value: isPinEnabled,
                onChanged: (value) async {
                  onCloseSettings();
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
                title: Text(l10n.changePinTitle), // antes 'Cambiar PIN'
                subtitle: Text(l10n.changePinSubtitle), // antes 'Modificar tu PIN actual'
                onTap: () async {
                  onCloseSettings();
                  await _changePin(context, l10n);
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
      await dataManager.savePin(result['pin']);
      await dataManager.setPinEnabled(true);
      await dataManager.setBiometricEnabled(result['biometricEnabled'] ?? false);
      onShowSnackBar(l10n.pinSetupSuccess, false); // antes 'PIN configurado correctamente'
    }
  }

  Future<void> _changePin(BuildContext context, AppLocalizations l10n) async {
    final currentPin = await dataManager.loadPin();
    
    if (currentPin == null) {
      onShowSnackBar(l10n.noPinConfigured, true); // antes 'No hay PIN configurado'
      return;
    }

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => PinSetupScreen(
          isChanging: true,
          currentPin: currentPin,
        ),
      ),
    );

    if (result != null) {
      await dataManager.savePin(result['pin']);
      await dataManager.setBiometricEnabled(result['biometricEnabled'] ?? false);
      onShowSnackBar(l10n.pinUpdated, false); // antes 'PIN actualizado correctamente'
    }
  }

  Future<void> _disablePin(BuildContext context, AppLocalizations l10n) async {
    final currentPin = await dataManager.loadPin();
    
    if (currentPin == null) {
      await dataManager.setPinEnabled(false);
      onShowSnackBar(l10n.pinDisabled, false); // antes 'PIN deshabilitado'
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.disablePinTitle), // antes 'Desactivar PIN'
        content: Text(
          l10n.disablePinSubtitle, // antes '¿Estás seguro de que quieres desactivar ...'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel), // antes 'Cancelar'
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await dataManager.removePin();
              onShowSnackBar(l10n.pinDisabled, false); // antes 'PIN deshabilitado'
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(l10n.disable), // antes 'Desactivar'
          ),
        ],
      ),
    );
  }
}
