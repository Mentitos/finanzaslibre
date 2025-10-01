import 'package:flutter/material.dart';
import '../../services/savings_data_manager.dart';

class ConfirmationDialogs {
  static void showClearRecordsConfirmation(
    BuildContext context,
    SavingsDataManager dataManager,
    Future<void> Function() onDataChanged,
    Function(String message, bool isError) onShowSnackBar,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Eliminar registros'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todos los registros?\n\n'
          'Esta acción no se puede deshacer. Las categorías se mantendrán.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await dataManager.saveRecords([]);
              await onDataChanged();
              onShowSnackBar('Todos los registros eliminados', false);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Eliminar todo'),
          ),
        ],
      ),
    );
  }

  static void showResetAppConfirmation(
    BuildContext context,
    SavingsDataManager dataManager,
    Future<void> Function() onDataChanged,
    Function(String message, bool isError) onShowSnackBar,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.red),
            SizedBox(width: 8),
            Text('Restablecer app'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que quieres restablecer la aplicación?\n\n'
          'Esto eliminará:\n'
          '• Todos los registros\n'
          '• Todas las categorías personalizadas\n'
          '• Toda la configuración\n\n'
          'Esta acción NO se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await dataManager.clearAllData();
              await onDataChanged();
              onShowSnackBar('Aplicación restablecida', false);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );
  }
}