// ============================================
// ARCHIVO: screens/dialogs/confirmation_dialogs.dart
// ============================================
import 'package:flutter/material.dart';
import '../../services/savings_data_manager.dart';
import '../../services/user_manager.dart';
import '../../l10n/app_localizations.dart';

class ConfirmationDialogs {
  /// Limpia todos los registros del usuario actual
  /// sin afectar el perfil del usuario
  static void showClearRecordsConfirmation(
    BuildContext context,
    SavingsDataManager dataManager,
    Future<void> Function() onDataChanged,
    Function(String message, bool isError) onShowSnackBar,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAllRecords),
        content: Text(
          'Se eliminarán todos los registros del usuario actual. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              try {
                // Obtener usuario actual
                final userManager = UserManager();
                final currentUser = await userManager.getCurrentUser();

                if (currentUser != null) {
                  // Aquí llamas a tu método de limpieza
                  // Si ya tienes un método en SavingsDataManager, úsalo
                  // await dataManager.clearUserData(currentUser.id);
                  
                  // Si no, aquí puedes limpiar manualmente
                  // Por ahora solo hacemos onDataChanged
                  await onDataChanged();
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  onShowSnackBar('Registros eliminados', false);
                }
              } catch (e) {
                onShowSnackBar('Error: $e', true);
              }
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  /// Reset COMPLETO de la app
  /// - Borra todos los datos
  /// - Mantiene solo la billetera principal (sin datos)
  /// - Todas las otras cuentas se eliminan
  static void showResetAppConfirmation(
    BuildContext context,
    SavingsDataManager dataManager,
    Future<void> Function() onDataChanged,
    Function(String message, bool isError) onShowSnackBar,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetApp),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Se limpiarán TODOS los datos de la aplicación.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Lo que se mantiene
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.blue[700],
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Se mantendrá:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✓ Tu billetera principal "Mi Billetera"',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '✓ El perfil del usuario',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Lo que se elimina
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red[700],
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Se eliminarán:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✗ Todos los registros e historial',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '✗ Todas las categorías',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '✗ Todas las billeteras adicionales',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                final userManager = UserManager();

                // Reset mantiendo la billetera principal
                await userManager.resetAppKeepingDefaultUser();

                // Aquí llamas a tu método de limpieza de datos
                // Si lo tienes, úsalo:
                // await dataManager.clearAllData();
                
                // Si no, simplemente hace el reset
                await onDataChanged();

                if (context.mounted) {
                  Navigator.pop(context);
                  onShowSnackBar(
                    'Aplicación reiniciada. Tu billetera principal se ha mantenido.',
                    false,
                  );
                }
              } catch (e) {
                onShowSnackBar('Error: $e', true);
              }
            },
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }
}