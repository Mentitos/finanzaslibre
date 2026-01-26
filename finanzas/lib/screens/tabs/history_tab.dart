import 'package:flutter/material.dart';
import '../../models/savings_record.dart';
import '../../widgets/record_item.dart';
import '../../constants/app_constants.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/category_translations.dart';
import 'package:intl/intl.dart';

class HistoryTab extends StatefulWidget {
  final List<SavingsRecord> allRecords;
  final List<SavingsRecord> filteredRecords;
  final List<String> categories;
  final Map<String, Color> categoryColors;
  final String currentFilter;
  final String selectedCategory;
  final String searchQuery;
  final TextEditingController searchController;
  final Future<void> Function() onRefresh;
  final Function(SavingsRecord) onEditRecord;
  final Function(String) onDeleteRecord;
  final Function(String) onFilterChanged;
  final Function(String) onCategoryChanged;
  final Function(List<SavingsRecord>) onSearchChanged;
  final VoidCallback onSearchCleared;
  final VoidCallback onAddRecordTap;

  const HistoryTab({
    super.key,
    required this.allRecords,
    required this.filteredRecords,
    required this.categories,
    required this.categoryColors,
    required this.currentFilter,
    required this.selectedCategory,
    required this.searchQuery,
    required this.searchController,
    required this.onRefresh,
    required this.onEditRecord,
    required this.onDeleteRecord,
    required this.onFilterChanged,
    required this.onCategoryChanged,
    required this.onSearchChanged,
    required this.onSearchCleared,
    required this.onAddRecordTap,
  });

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  String? _confirmingDeleteId;

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
    return Column(
      children: [
        _buildSearchBar(l10n),
        _buildFilters(context, l10n),
        const SizedBox(height: AppConstants.defaultPadding),
        Expanded(
          child: widget.filteredRecords.isEmpty
              ? _buildEmptyState(context, l10n)
              : RefreshIndicator(
                  onRefresh: widget.onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                    ),
                    itemCount: widget.filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = widget.filteredRecords[index];
                      return RecordItem(
                        record: record,
                        onEdit: () => widget.onEditRecord(record),
                        onDelete: () =>
                            _showDeleteConfirmation(context, record, l10n),
                        showCategory: true,
                        categoryColors: widget.categoryColors,
                        l10n: l10n,
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        if (_confirmingDeleteId != null) {
          setState(() {
            _confirmingDeleteId = null;
          });
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar / Control Panel
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Historial',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  _buildSearchBar(l10n),
                  const SizedBox(height: 16),
                  Text(
                    'Filtrar por',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _buildFilterChip(context, l10n.deposits, 'deposits'),
                        _buildFilterChip(
                          context,
                          l10n.withdrawals,
                          'withdrawals',
                        ),
                        Builder(
                          builder: (context) =>
                              _buildCategoryDropdown(context, l10n),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildFilteredTotalCard(context, l10n),
                ],
              ),
            ),
          ),
          VerticalDivider(width: 1, color: Colors.grey.withValues(alpha: 0.2)),
          // Content List
          Expanded(
            flex: 2,
            child: widget.filteredRecords.isEmpty
                ? _buildEmptyState(context, l10n)
                : RefreshIndicator(
                    onRefresh: widget.onRefresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppConstants.largePadding),
                      itemCount: widget.filteredRecords.length,
                      itemBuilder: (context, index) {
                        final record = widget.filteredRecords[index];
                        final isConfirming = _confirmingDeleteId == record.id;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            RecordItem(
                              record: record,
                              onEdit: () => widget.onEditRecord(record),
                              onDelete: () => _showDeleteConfirmation(
                                context,
                                record,
                                l10n,
                              ),
                              showCategory: true,
                              categoryColors: widget.categoryColors,
                              l10n: l10n,
                            ),
                            if (isConfirming)
                              _buildComicDeleteConfirmation(
                                context,
                                record,
                                l10n,
                              ),
                            if (!isConfirming) const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildComicDeleteConfirmation(
    BuildContext context,
    SavingsRecord record,
    AppLocalizations l10n,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    // Use theme colors: errorContainer (soft red) for background
    final backgroundColor = colorScheme.errorContainer;
    final onBackgroundColor = colorScheme.onErrorContainer;
    final borderColor = colorScheme.error.withValues(alpha: 0.5);

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 4, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Arrow pointing up
          Padding(
            padding: const EdgeInsets.only(right: 28),
            child: ClipPath(
              clipper: _TriangleClipper(),
              child: Container(width: 20, height: 10, color: backgroundColor),
            ),
          ),
          // Comic Bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.deleteConfirmation, // "Are you sure?"
                  style: TextStyle(
                    color: onBackgroundColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _confirmingDeleteId = null;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: onBackgroundColor,
                  ),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    widget.onDeleteRecord(record.id);
                    setState(() {
                      _confirmingDeleteId = null;
                    });
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(l10n.delete),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to format amount with thousands separator
  String _formatAmount(double amount) {
    // Round to integer since user requested no decimals by default
    final value = amount.round();
    // Format with dots for thousands (e.g., 10.000)
    return NumberFormat.currency(
      locale:
          'es_AR', // Or use 'es'/'en' depending on app config, but 'es_AR' typically uses dot for thousands
      symbol: '',
      decimalDigits: 0,
    ).format(value).trim();
  }

  Widget _buildFilteredTotalCard(BuildContext context, AppLocalizations l10n) {
    final total = widget.filteredRecords.fold<double>(0, (sum, record) {
      if (record.type == RecordType.withdrawal) {
        return sum - record.totalAmount;
      }
      return sum + record.totalAmount;
    });

    final isPositive = total >= 0;
    // Premium style matching SummaryTab
    final gradientColors = isPositive
        ? [Colors.green.shade400, Colors.green.shade600]
        : [Colors.red.shade400, Colors.red.shade600];
    final shadowColor = isPositive ? Colors.green : Colors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Filtrado',
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppConstants.largeFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${isPositive ? '' : '-'}${AppConstants.currencySymbol}${_formatAmount(total.abs())}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: TextField(
        controller: widget.searchController,
        decoration: InputDecoration(
          hintText: l10n.searchRecords,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: widget.searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: widget.onSearchCleared,
                )
              : null,
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) {
          final results = fuzzySearch(value, widget.allRecords);
          widget.onSearchChanged(results);
        },
      ),
    );
  }

  List<SavingsRecord> fuzzySearch(String query, List<SavingsRecord> records) {
    if (query.trim().isEmpty) {
      return records;
    }

    final normalizedQuery = query.toLowerCase().replaceAll(
      RegExp(r'[^\w\s]+'),
      '',
    );

    return records.where((record) {
      final desc = record.description.toLowerCase().replaceAll(
        RegExp(r'[^\w\s]+'),
        '',
      );
      final category = record.category.toLowerCase().replaceAll(
        RegExp(r'[^\w\s]+'),
        '',
      );
      final descRatio = ratio(normalizedQuery, desc);
      final catRatio = ratio(normalizedQuery, category);
      return descRatio >= 70 || catRatio >= 70;
    }).toList();
  }

  Widget _buildFilters(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: Row(
        children: [
          _buildFilterChip(context, l10n.deposits, 'deposits'),
          const SizedBox(width: AppConstants.smallPadding),
          _buildFilterChip(context, l10n.withdrawals, 'withdrawals'),
          const SizedBox(width: AppConstants.defaultPadding),
          Builder(builder: (context) => _buildCategoryDropdown(context, l10n)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String text, String value) {
    final isSelected = widget.currentFilter == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final borderColor = isSelected
        ? primaryColor
        : (isDark ? Colors.grey.shade600 : Colors.grey.shade400);
    final textColor = isSelected
        ? primaryColor
        : (isDark ? Colors.white : Colors.black87);
    final backgroundColor = isSelected
        ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
        : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isSelected) {
            widget.onFilterChanged('all');
          } else {
            widget.onFilterChanged(value);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final borderColor = widget.selectedCategory == 'all'
        ? (isDark ? Colors.grey.shade600 : Colors.grey.shade400)
        : primaryColor;
    final iconColor = widget.selectedCategory == 'all'
        ? (isDark ? Colors.grey.shade400 : Colors.grey.shade700)
        : primaryColor;
    final textColor = widget.selectedCategory == 'all'
        ? Theme.of(context).textTheme.bodyLarge?.color
        : primaryColor;

    return PopupMenuButton<String>(
      initialValue: widget.selectedCategory,
      offset: const Offset(0, 40),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            width: widget.selectedCategory == 'all' ? 1 : 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: widget.selectedCategory == 'all'
              ? Colors.transparent
              : Theme.of(context).primaryColor.withValues(alpha: 0.1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.category, size: 20, color: iconColor),
            const SizedBox(width: 8),
            Text(
              widget.selectedCategory == 'all'
                  ? l10n.category
                  : widget.selectedCategory,
              style: TextStyle(
                fontWeight: widget.selectedCategory == 'all'
                    ? FontWeight.normal
                    : FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 20, color: iconColor),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(value: 'all', child: Text(l10n.allCategories)),
        ...widget.categories.map(
          (category) => PopupMenuItem(
            value: category,
            child: Text(l10n.translateCategory(category)),
          ),
        ),
      ],
      onSelected: (value) {
        widget.onCategoryChanged(value);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    String title = l10n.noRecords;
    String subtitle = l10n.noRecordsSubtitle;

    if (widget.searchQuery.isNotEmpty) {
      title = l10n.noSearchResults;
      subtitle = l10n.noSearchResultsSubtitle;
    } else if (widget.selectedCategory != 'all') {
      title = l10n.noCategoryRecords;
      subtitle = l10n.noCategoryRecordsSubtitle;
    }

    return SingleChildScrollView(
      child: EmptyRecordsWidget(
        title: title,
        subtitle: subtitle,
        onActionPressed: widget.searchQuery.isEmpty
            ? widget.onAddRecordTap
            : null,
        actionText: widget.searchQuery.isEmpty ? l10n.addRecord : null,
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    SavingsRecord record,
    AppLocalizations l10n,
  ) {
    // If desktop (width > 900), use comic bubble confirmation
    if (MediaQuery.of(context).size.width > 900) {
      setState(() {
        _confirmingDeleteId = record.id;
      });
      return;
    }

    // Default Mobile Dialog logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRecord),
        content: Text(
          '${l10n.deleteConfirmation} "${record.description.isEmpty ? record.category : record.description}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDeleteRecord(record.id);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class EmptyRecordsWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onActionPressed;
  final String? actionText;

  const EmptyRecordsWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.onActionPressed,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (onActionPressed != null && actionText != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
