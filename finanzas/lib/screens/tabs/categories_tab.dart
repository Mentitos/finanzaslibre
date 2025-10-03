import 'package:flutter/material.dart';
import '../../utils/formatters.dart';
import '../../constants/app_constants.dart';

class CategoriesTab extends StatelessWidget {
  final Map<String, dynamic> statistics;
  final List<String> categories;
  final Map<String, Color> categoryColors;
  final Function(String, Color) onAddCategory;
  final Function(String) onDeleteCategory;

  const CategoriesTab({
    super.key,
    required this.statistics,
    required this.categories,
    required this.onAddCategory,
    required this.categoryColors,
    required this.onDeleteCategory,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          _buildCategoryTotalsCard(context),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildCategoryManagementCard(context),
        ],
      ),
    );
  }

  Widget _buildCategoryTotalsCard(BuildContext context) {
  final categoryTotals = statistics['categoryTotals'] as Map<String, double>? ?? {};
  final categoryTotalsList = categoryTotals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ahorros por Categoría',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          if (categoryTotalsList.isEmpty)
            const Text('No hay datos disponibles')
          else
            ...categoryTotalsList.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppConstants.getCategoryColor(entry.key, categoryColors), // CAMBIO AQUÍ
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(entry.key)),
                      Text(
                        '${AppConstants.currencySymbol}${Formatters.formatCurrency(entry.value)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: entry.value >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    ),
  );
}

Widget _buildCategoryManagementCard(BuildContext context) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Administrar Categorías',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                onPressed: () => _showAddCategoryDialog(context),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) => Chip(
              label: Text(category),
              avatar: CircleAvatar(
                backgroundColor: AppConstants.getCategoryColor(category, categoryColors), // CAMBIO AQUÍ
                radius: 8,
              ),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: category != 'General'
                  ? () => _showDeleteCategoryConfirmation(context, category)
                  : null,
            )).toList(),
          ),
        ],
      ),
    ),
  );
}

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => _CategoryDialog(
        categories: categories,
        onAddCategory: onAddCategory,
      ),
    );
  }

  void _showDeleteCategoryConfirmation(BuildContext context, String category) {
    // Obtener estadísticas de uso de la categoría
    final categoryTotals = statistics['categoryTotals'] as Map<String, double>? ?? {};
    final recordsCount = statistics['categoryRecordsCount'] as Map<String, int>? ?? {};
    final usageCount = recordsCount[category] ?? 0;
    final hasAmount = categoryTotals.containsKey(category) && categoryTotals[category] != 0;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              usageCount > 0 ? Icons.warning_amber : Icons.delete_outline,
              color: usageCount > 0 ? Colors.orange : Colors.red,
            ),
            const SizedBox(width: 8),
            const Expanded(child: Text(AppConstants.deleteCategoryTitle)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Eliminar la categoría "$category"?'),
            if (usageCount > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 20, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Categoría en uso',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('• $usageCount registro${usageCount > 1 ? 's' : ''} serán movidos a "General"'),
                    if (hasAmount)
                      Text(
                        '• Monto actual: \$${Formatters.formatCurrency(categoryTotals[category]!.abs())}',
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppConstants.cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onDeleteCategory(category);
            },
            style: FilledButton.styleFrom(
              backgroundColor: usageCount > 0 ? Colors.orange : Colors.red,
            ),
            child: Text(usageCount > 0 ? 'Mover y Eliminar' : AppConstants.deleteButtonLabel),
          ),
        ],
      ),
    );
  }
}

// Widget separado para el diálogo de agregar categoría con selector de color
// Widget separado para el diálogo de agregar categoría con selector de color
class _CategoryDialog extends StatefulWidget {
  final List<String> categories;
  final Function(String, Color) onAddCategory; // CAMBIA ESTO

  const _CategoryDialog({
    required this.categories,
    required this.onAddCategory,
  });

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _controller = TextEditingController();
  Color _selectedColor = Colors.blue;

  // Paleta de colores predefinida
  final List<Color> _colorPalette = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.cyan,
    Colors.amber,
    Colors.indigo,
    Colors.lime,
    Colors.deepOrange,
    Colors.brown,
    Colors.blueGrey,
    Colors.deepPurple,
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva Categoría'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Nombre de la categoría',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: AppConstants.maxCategoryNameLength,
            ),
            const SizedBox(height: 16),
            const Text(
              'Elige un color',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            // Selector de colores
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colorPalette.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey.shade300,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Vista previa
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _selectedColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _selectedColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _controller.text.isEmpty
                          ? 'Vista previa de tu categoría'
                          : _controller.text,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _selectedColor,
                      ),
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
          child: const Text(AppConstants.cancelButtonLabel),
        ),
        FilledButton(
          onPressed: _handleAddCategory,
          child: const Text(AppConstants.addButtonLabel),
        ),
      ],
    );
  }

  void _handleAddCategory() {
  final name = _controller.text.trim();
  
  if (!AppConstants.isValidCategoryName(name)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nombre de categoría inválido'),
        backgroundColor: AppConstants.errorColor,
      ),
    );
    return;
  }
  
  if (widget.categories.contains(name)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppConstants.categoryExistsError),
        backgroundColor: AppConstants.errorColor,
      ),
    );
    return;
  }

  Navigator.pop(context);
  widget.onAddCategory(name, _selectedColor); // ENVÍA EL COLOR
}
}