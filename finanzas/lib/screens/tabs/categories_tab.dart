import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../utils/formatters.dart';
import '../../constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/category_translations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return _buildDesktopLayout(context, l10n);
        }
        return _buildMobileLayout(context, l10n);
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          _buildCategoryTotalsCard(context, l10n),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildCategoryManagementCard(context, l10n),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AppLocalizations l10n) {
    // Sort categories by total value for the grid
    final categoryTotals =
        statistics['categoryTotals'] as Map<String, double>? ?? {};

    // Ensure all categories are in the list, even if 0
    final allCategoryEntries = categories.map((cat) {
      final amount = categoryTotals[cat] ?? 0.0;
      return MapEntry(cat, amount);
    }).toList();

    // Sort: Non-zero first (descending), then alphabetical
    allCategoryEntries.sort((a, b) {
      if (a.value != 0 || b.value != 0) {
        return b.value.compareTo(a.value);
      }
      return a.key.compareTo(b.key);
    });

    return Padding(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT COLUMN: Visual Stats (Grid)
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balance por Categoría',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          childAspectRatio: 1.4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: allCategoryEntries.length,
                    itemBuilder: (context, index) {
                      final entry = allCategoryEntries[index];
                      return _buildDesktopCategoryCard(
                        context,
                        entry.key,
                        entry.value,
                        l10n,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          VerticalDivider(width: 1, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(width: 32),
          // RIGHT COLUMN: Management (List)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.manageCategories,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      FilledButton.icon(
                        onPressed: () => _showAddCategoryDialog(context, l10n),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.separated(
                      itemCount: categories.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppConstants.getCategoryColor(
                              category,
                              categoryColors,
                            ).withOpacity(0.2),
                            child: Icon(
                              Icons.category,
                              color: AppConstants.getCategoryColor(
                                category,
                                categoryColors,
                              ),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            l10n.translateCategory(category),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: category != 'General'
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () =>
                                      _showDeleteCategoryConfirmation(
                                        context,
                                        category,
                                        l10n,
                                      ),
                                  tooltip: l10n.deleteCategory,
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopCategoryCard(
    BuildContext context,
    String category,
    double amount,
    AppLocalizations l10n,
  ) {
    final color = AppConstants.getCategoryColor(category, categoryColors);
    final isPositive = amount >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.translateCategory(category),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                amount >= 0 ? Icons.trending_up : Icons.trending_down,
                color: amount >= 0 ? Colors.green : Colors.red,
                size: 20,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${AppConstants.currencySymbol}${Formatters.formatCurrency(amount.abs())}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isPositive
                        ? Theme.of(context).colorScheme.onSurface
                        : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTotalsCard(BuildContext context, AppLocalizations l10n) {
    final categoryTotals =
        statistics['categoryTotals'] as Map<String, double>? ?? {};
    final categoryTotalsList = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.savingsByCategory,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            if (categoryTotalsList.isEmpty)
              Text(l10n.noDataAvailable)
            else
              ...categoryTotalsList.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppConstants.getCategoryColor(
                            entry.key,
                            categoryColors,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(l10n.translateCategory(entry.key))),
                      Text(
                        '${AppConstants.currencySymbol}${Formatters.formatCurrency(entry.value)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: entry.value >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryManagementCard(
    BuildContext context,
    AppLocalizations l10n,
  ) {
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
                  l10n.manageCategories,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () => _showAddCategoryDialog(context, l10n),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories
                  .map(
                    (category) => Chip(
                      label: Text(l10n.translateCategory(category)),
                      avatar: CircleAvatar(
                        backgroundColor: AppConstants.getCategoryColor(
                          category,
                          categoryColors,
                        ),
                        radius: 8,
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: category != 'General'
                          ? () => _showDeleteCategoryConfirmation(
                              context,
                              category,
                              l10n,
                            )
                          : null,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => _CategoryDialog(
        categories: categories,
        onAddCategory: onAddCategory,
        l10n: l10n,
      ),
    );
  }

  void _showDeleteCategoryConfirmation(
    BuildContext context,
    String category,
    AppLocalizations l10n,
  ) {
    final categoryTotals =
        statistics['categoryTotals'] as Map<String, double>? ?? {};
    final recordsCount =
        statistics['categoryRecordsCount'] as Map<String, int>? ?? {};
    final usageCount = recordsCount[category] ?? 0;
    final hasAmount =
        categoryTotals.containsKey(category) && categoryTotals[category] != 0;

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
            Expanded(child: Text(l10n.deleteCategory)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.deleteCategoryConfirm} "$category"?'),
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
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.categoryInUse,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('• $usageCount ${l10n.recordsWillBeMoved}'),
                    if (hasAmount)
                      Text(
                        '• ${l10n.currentAmount}: \$${Formatters.formatCurrency(categoryTotals[category]!.abs())}',
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
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onDeleteCategory(category);
            },
            style: FilledButton.styleFrom(
              backgroundColor: usageCount > 0 ? Colors.orange : Colors.red,
            ),
            child: Text(usageCount > 0 ? l10n.moveAndDelete : l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  final List<String> categories;
  final Function(String, Color) onAddCategory;
  final AppLocalizations l10n;

  const _CategoryDialog({
    required this.categories,
    required this.onAddCategory,
    required this.l10n,
  });

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _controller = TextEditingController();
  Color _selectedColor = Colors.blue;

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
      title: Text(widget.l10n.newCategory),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: widget.l10n.categoryName,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.category),
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: AppConstants.maxCategoryNameLength,
            ),
            const SizedBox(height: 16),
            Text(
              widget.l10n.chooseColor,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._colorPalette.map((color) => _buildColorOption(color)),
                _buildCustomColorButton(),
              ],
            ),
            const SizedBox(height: 16),
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
                          ? widget.l10n.categoryPreview
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
          child: Text(widget.l10n.cancel),
        ),
        FilledButton(
          onPressed: _handleAddCategory,
          child: Text(widget.l10n.add),
        ),
      ],
    );
  }

  void _handleAddCategory() {
    final name = _controller.text.trim();

    if (!AppConstants.isValidCategoryName(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.l10n.invalidCategoryName),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    if (widget.categories.contains(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.l10n.categoryExists),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    Navigator.pop(context);
    widget.onAddCategory(name, _selectedColor);
  }

  Widget _buildColorOption(Color color) {
    final isSelected = _selectedColor.value == color.value;
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
            ? const Icon(Icons.check, color: Colors.white, size: 24)
            : null,
      ),
    );
  }

  Widget _buildCustomColorButton() {
    // Check if current selected color is NOT in the predefined palette
    // But be careful: predefined palette contains Colors.blue which might be same value as default.
    // We compare value.
    // If selected color matches one of the palette colors, this button is NOT selected (unless it's the exact same custom value, but UI-wise we treat it as standard).
    // Actually, simply: if _selectedColor is NOT in _colorPalette, then it's custom.
    final isCustomSelected = !_colorPalette.any(
      (c) => c.value == _selectedColor.value,
    );

    return GestureDetector(
      onTap: _showColorPicker,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isCustomSelected ? _selectedColor : Colors.grey[200],
          shape: BoxShape.circle,
          border: Border.all(
            color: isCustomSelected ? Colors.black : Colors.grey.shade300,
            width: isCustomSelected ? 3 : 1,
          ),
          boxShadow: isCustomSelected
              ? [
                  BoxShadow(
                    color: _selectedColor.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: isCustomSelected
            ? const Icon(Icons.check, color: Colors.white, size: 24)
            : Icon(Icons.add, color: Colors.grey[600], size: 24),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Color Personalizado'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() => _selectedColor = color);
            },
            showLabel: false,
            pickerAreaHeightPercent: 0.7,
            enableAlpha: false,
            displayThumbColor: true,
            paletteType: PaletteType.hsvWithHue,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Listo'),
          ),
        ],
      ),
    );
  }
}
