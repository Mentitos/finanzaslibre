import 'package:flutter/material.dart';
import '../../services/savings_data_manager.dart';
import '../pin_setup_screen.dart';

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
                'Seguridad',
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
              title: const Text('PIN de seguridad'),
              subtitle: Text(isPinEnabled 
                  ? 'Protección activa con PIN de 4 dígitos' 
                  : 'Protege tu app con un PIN'),
              trailing: Switch(
                value: isPinEnabled,
                onChanged: (value) async {
                  onCloseSettings();
                  if (value) {
                    await _setupPin(context);
                  } else {
                    await _disablePin(context);
                  }
                },
              ),
            ),
            if (isPinEnabled)
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Cambiar PIN'),
                subtitle: const Text('Modificar tu PIN actual'),
                onTap: () async {
                  onCloseSettings();
                  await _changePin(context);
                },
              ),
          ],
        );
      },
    );
  }

  Future<void> _setupPin(BuildContext context) async {
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
      onShowSnackBar('PIN configurado correctamente', false);
    }
  }

  Future<void> _changePin(BuildContext context) async {
    final currentPin = await dataManager.loadPin();
    
    if (currentPin == null) {
      onShowSnackBar('No hay PIN configurado', true);
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
      onShowSnackBar('PIN actualizado correctamente', false);
    }
  }

  Future<void> _disablePin(BuildContext context) async {
    final currentPin = await dataManager.loadPin();
    
    if (currentPin == null) {
      await dataManager.setPinEnabled(false);
      onShowSnackBar('PIN deshabilitado', false);
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desactivar PIN'),
        content: const Text(
          '¿Estás seguro de que quieres desactivar la protección por PIN?\n\n'
          'Tus datos quedarán sin protección.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await dataManager.removePin();
              onShowSnackBar('PIN deshabilitado', false);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
  }
}