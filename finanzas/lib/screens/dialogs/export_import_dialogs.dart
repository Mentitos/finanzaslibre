import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/savings_data_manager.dart';

class ExportImportDialogs {
  static void showExportDialog(
    BuildContext context,
    Map<String, dynamic> data,
    int recordsCount,
    int categoriesCount,
    
  ) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final containerColor = isDarkMode ? Colors.grey[800] : Colors.grey[200];
  final textColor = isDarkMode ? Colors.white : Colors.black;



    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Datos exportados'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total de registros: $recordsCount'),
              Text('Categorías: $categoriesCount'),
              const SizedBox(height: 16),
              const Text(
                'Copia estos datos y guárdalos en un lugar seguro:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                jsonEncode(data),
                style: TextStyle(
                fontSize: 12,
                color: textColor,
    ),
  ),
)
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  static void showImportDialog(
    BuildContext context,
    SavingsDataManager dataManager,
    Future<void> Function() onDataChanged,
    Function(String message, bool isError) onShowSnackBar,
  ) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Importar datos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pega aquí los datos exportados:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '{"exportDate": "...", ...}',
              ),
              maxLines: 8,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final data = jsonDecode(controller.text);
                final success = await dataManager.importData(data);
                
                if (success) {
                  await onDataChanged();
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    onShowSnackBar('Datos importados exitosamente', false);
                  }
                } else {
                  onShowSnackBar('Error al importar datos', true);
                }
              } catch (e) {
                onShowSnackBar('Formato de datos inválido', true);
              }
            },
            child: const Text('Importar'),
          ),
        ],
      ),
    );
  }
}