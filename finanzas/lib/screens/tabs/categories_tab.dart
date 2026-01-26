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
  final Map<String, IconData> categoryIcons;
  final Function(String, Color, IconData) onAddCategory;
  final Function(String) onDeleteCategory;

  const CategoriesTab({
    super.key,
    required this.statistics,
    required this.categories,
    required this.onAddCategory,
    required this.categoryColors,
    required this.categoryIcons,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.defaultPadding),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            child: Text(
              'Balance por Categoría',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 12),
          _buildMobileBalanceList(context, l10n),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(
              left: AppConstants.defaultPadding,
              right: AppConstants.defaultPadding + 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.manageCategories,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => _showAddCategoryDialog(context, l10n),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildMobileManagementList(context, l10n),
          const SizedBox(height: 80), // Fab spacing
        ],
      ),
    );
  }

  Widget _buildMobileBalanceList(BuildContext context, AppLocalizations l10n) {
    final categoryTotals =
        statistics['categoryTotals'] as Map<String, double>? ?? {};
    final categoryTotalsList = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Ensure we show something if empty, or just the list
    if (categoryTotalsList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: Text(l10n.noDataAvailable),
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: categoryTotalsList.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.translateCategory(entry.key),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    Formatters.formatCurrencyWithSign(
                      entry.value,
                      showPositiveSign: false,
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: entry.value >= 0 ? Colors.green : Colors.red,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileManagementList(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(), // Scroll handled by parent
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final color = AppConstants.getCategoryColor(category, categoryColors);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                categoryIcons[category] ?? Icons.category,
                color: color,
                size: 20,
              ),
            ),
            title: Text(
              l10n.translateCategory(category),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: category != 'General'
                ? IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: () => _showDeleteCategoryConfirmation(
                      context,
                      category,
                      l10n,
                    ),
                  )
                : null,
          ),
        );
      },
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
                          childAspectRatio: 1.2,
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
          VerticalDivider(width: 1, color: Colors.grey.withValues(alpha: 0.2)),
          const SizedBox(width: 32),
          // RIGHT COLUMN: Management (List)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          l10n.manageCategories,
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                            ).withValues(alpha: 0.2),
                            child: Icon(
                              categoryIcons[category] ?? Icons.category,
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
    return _CategorySummaryCard(
      category: category,
      amount: amount,
      color: color,
      icon: categoryIcons[category] ?? Icons.category,
      l10n: l10n,
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
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
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
  final Function(String, Color, IconData) onAddCategory;
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
  IconData _selectedIcon = Icons.category;
  bool _showCustomColorPicker = false;
  bool _showIconPicker = false;

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
  void initState() {
    super.initState();
    // Rebuild on text change to update preview
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            width: isDesktop ? 800 : null,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.l10n.newCategory,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: _buildFormContent()),
                              const SizedBox(width: 32),
                              // VerticalDivider removed to prevent layout issues
                              const SizedBox(width: 32),
                              Expanded(flex: 2, child: _buildPreviewSection()),
                            ],
                          )
                        else ...[
                          _buildFormContent(),
                          const SizedBox(height: 24),
                          _buildPreviewSection(),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(widget.l10n.cancel),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(
                      onPressed: _handleAddCategory,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: Text(widget.l10n.add),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormContent() {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.l10n.categoryName,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.category),
            filled: true,
          ),
          textCapitalization: TextCapitalization.words,
          maxLength: AppConstants.maxCategoryNameLength,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.l10n.chooseColor,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            if (_showCustomColorPicker)
              TextButton.icon(
                onPressed: () => setState(() => _showCustomColorPicker = false),
                icon: Icon(isDesktop ? Icons.close : Icons.grid_view, size: 16),
                label: Text(isDesktop ? 'Ocultar' : 'Volver'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (isDesktop) ...[
          // Desktop: Always show grid, optional picker below
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ..._colorPalette.map((color) => _buildColorOption(color)),
                  _buildCustomColorButton(),
                ],
              ),
            ),
          ),
          if (_showCustomColorPicker) ...[
            const SizedBox(height: 24),
            _buildInlineColorPicker(),
          ],
        ] else
          // Mobile: Toggle between grid and picker
          AnimatedCrossFade(
            firstChild: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ..._colorPalette.map((color) => _buildColorOption(color)),
                    _buildCustomColorButton(),
                  ],
                ),
              ),
            ),
            secondChild: _buildInlineColorPicker(),
            crossFadeState: _showCustomColorPicker
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Elige un Ícono',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            if (_showIconPicker)
              TextButton.icon(
                onPressed: () => setState(() => _showIconPicker = false),
                icon: const Icon(Icons.grid_view, size: 16),
                label: const Text('Ocultar'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              )
            else
              TextButton.icon(
                onPressed: () => setState(() => _showIconPicker = true),
                icon: const Icon(Icons.grid_view, size: 16),
                label: const Text('Ver todos'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: AnimatedCrossFade(
            firstChild: _buildQuickIconPicker(),
            secondChild: _buildFullIconPicker(),
            crossFadeState: _showIconPicker
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickIconPicker() {
    final quickIcons = [
      Icons.category,
      Icons.work,
      Icons.home,
      Icons.favorite,
      Icons.pets,
      Icons.shopping_cart,
      Icons.restaurant,
      Icons.directions_car,
      Icons.medical_services,
      Icons.school,
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [...quickIcons.map((icon) => _buildIconOption(icon))],
        ),
      ),
    );
  }

  Widget _buildFullIconPicker() {
    final allIcons = [
      Icons.category,
      Icons.work,
      Icons.home,
      Icons.shopping_cart,
      Icons.restaurant,
      Icons.directions_car,
      Icons.flight,
      Icons.medical_services,
      Icons.school,
      Icons.pets,
      Icons.sports_soccer,
      Icons.videogame_asset,
      Icons.music_note,
      Icons.local_cafe,
      Icons.local_bar,
      Icons.build,
      Icons.savings,
      Icons.attach_money,
      Icons.laptop,
      Icons.phone_android,
      Icons.favorite,
      Icons.beach_access,
      Icons.fitness_center,
      Icons.local_pizza,
      Icons.movie,
      Icons.local_mall,
      Icons.child_care,
      Icons.bolt,
      Icons.water_drop,
      Icons.local_gas_station,
      Icons.favorite_border,
      Icons.kitchen,
      Icons.bed,
      Icons.chair,
      Icons.light,
      Icons.shower,
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      height: 200,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: allIcons.length,
        itemBuilder: (context, index) {
          return _buildIconOption(allIcons[index]);
        },
      ),
    );
  }

  Widget _buildIconOption(IconData icon) {
    final isSelected = _selectedIcon.codePoint == icon.codePoint;
    return GestureDetector(
      onTap: () => setState(() => _selectedIcon = icon),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? _selectedColor
              : Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: _selectedColor.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Theme.of(context).iconTheme.color,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildInlineColorPicker() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: ColorPicker(
        pickerColor: _selectedColor,
        onColorChanged: (color) {
          setState(() => _selectedColor = color);
        },
        labelTypes: const [],
        pickerAreaHeightPercent: 0.7,
        enableAlpha: false,
        displayThumbColor: true,
        paletteType: PaletteType.hsvWithHue,
        hexInputBar: true,
      ),
    );
  }

  Widget _buildPreviewSection() {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vista Previa',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (isDesktop)
          // Desktop: Show the summary card
          AspectRatio(
            aspectRatio: 1.5,
            child: _CategorySummaryCard(
              category: _controller.text.isEmpty
                  ? widget.l10n.categoryPreview
                  : _controller.text,
              amount: 0,
              color: _selectedColor,
              icon: _selectedIcon,
              l10n: widget.l10n,
              isPreview: true,
            ),
          )
        else
          // Mobile: Show a list tile style preview (Management style)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _selectedColor.withValues(alpha: 0.5)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_selectedIcon, color: _selectedColor, size: 20),
              ),
              title: Text(
                _controller.text.isEmpty
                    ? widget.l10n.categoryPreview
                    : _controller.text,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.delete_outline, color: Colors.grey),
            ),
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
    widget.onAddCategory(name, _selectedColor, _selectedIcon);
  }

  Widget _buildColorOption(Color color) {
    final isSelected = _selectedColor.toARGB32() == color.toARGB32();
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: isSelected ? 3 : 0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.6),
                blurRadius: 12,
                spreadRadius: 2,
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
              ),
          ],
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 24)
            : null,
      ),
    );
  }

  Widget _buildCustomColorButton() {
    final isCustomSelected = !_colorPalette.any(
      (c) => c.toARGB32() == _selectedColor.toARGB32(),
    );

    return GestureDetector(
      onTap: () {
        if (MediaQuery.of(context).size.width > 900) {
          setState(() => _showCustomColorPicker = true);
        } else {
          _showColorPicker();
        }
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          // Use a gradient or special style for custom
          gradient: const LinearGradient(
            colors: [Colors.purple, Colors.blue, Colors.green],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            if (isCustomSelected)
              BoxShadow(
                color: _selectedColor.withValues(alpha: 0.6),
                blurRadius: 12,
                spreadRadius: 2,
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
              ),
          ],
          border: isCustomSelected
              ? Border.all(color: Colors.white, width: 3)
              : null,
        ),
        child: isCustomSelected
            ? const Icon(Icons.check, color: Colors.white, size: 24)
            : const Icon(Icons.add, color: Colors.white, size: 24),
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
            labelTypes: const [],
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

class _CategorySummaryCard extends StatelessWidget {
  final String category;
  final double amount;
  final Color color;
  final IconData icon;
  final AppLocalizations l10n;
  final bool isPreview;

  const _CategorySummaryCard({
    required this.category,
    required this.amount,
    required this.color,
    required this.icon,
    required this.l10n,
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = amount >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
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
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPreview ? category : l10n.translateCategory(category),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: color, size: 24),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                amount >= 0 ? Icons.trending_up : Icons.trending_down,
                color: amount >= 0 ? Colors.green : Colors.red,
                size: 20,
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
                      Formatters.formatCurrencyWithSign(
                        amount.abs(),
                        showPositiveSign: false,
                      ),
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
        ],
      ),
    );
  }
}
