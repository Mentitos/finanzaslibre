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
                final userManager = UserManager();
                final currentUser = await userManager.getCurrentUser();

                if (currentUser != null) {
                  await dataManager.clearUserData();
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

  /// Reset de la app con opción de mantener registros de la billetera principal
  /// La billetera principal SIEMPRE se mantiene, la opción es si conservar sus registros
  static void showResetAppConfirmation(
    BuildContext context,
    SavingsDataManager dataManager,
    Future<void> Function() onDataChanged,
    Function(String message, bool isError) onShowSnackBar,
  ) {
    final l10n = AppLocalizations.of(context)!;
    bool keepRecords = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.resetApp),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Se reiniciará la aplicación completamente.',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // SIEMPRE se mantiene
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
                            'Se mantendrá siempre:',
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
                              '✓ Tu perfil de usuario',
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
                const SizedBox(height: 16),

                // Checkbox para mantener registros de la billetera principal
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: keepRecords,
                            onChanged: (value) {
                              setState(() {
                                keepRecords = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Conservar registros',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[800],
                                  ),
                                ),
                                Text(
                                  'Mantener el historial de la billetera principal',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Resumen de lo que pasará
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
                              '✗ Todas las billeteras adicionales',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (keepRecords)
                              Text(
                                '✗ Todas las categorías personalizadas',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[700],
                                ),
                              )
                            else
                              Column(
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
                                ],
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

                  if (keepRecords) {
                    // Reset: mantener billetera principal CON sus registros
                    // Eliminar otros usuarios y todas las categorías
                    await userManager.resetAppKeepingDefaultUser();
                    await dataManager.clearAllDataExceptDefaultUser();
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      onShowSnackBar(
                        'Aplicación reiniciada. Tu billetera principal se mantiene con todos sus registros.',
                        false,
                      );
                    }
                  } else {
                    // Reset total: billetera principal vacía como nueva instalación
                    await userManager.resetAppKeepingDefaultUser();
                    await dataManager.clearAllData();
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      onShowSnackBar(
                        'Aplicación reiniciada como nueva. Tu billetera principal está vacía.',
                        false,
                      );
                    }
                  }

                  await onDataChanged();
                } catch (e) {
                  onShowSnackBar('Error: $e', true);
                }
              },
              child: Text(l10n.reset),
            ),
          ],
        ),
      ),
    );
  }
}