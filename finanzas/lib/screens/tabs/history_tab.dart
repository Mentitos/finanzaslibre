import 'package:flutter/material.dart';
import '../../models/savings_record.dart';
import '../../widgets/record_item.dart';
import '../../constants/app_constants.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';


class HistoryTab extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilters(),
        Expanded(
          child: filteredRecords.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                    ),
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = filteredRecords[index];
                      return RecordItem(
                        record: record,
                        onEdit: () => onEditRecord(record),
                        onDelete: () => _showDeleteConfirmation(context, record),
                        showCategory: true,
                        categoryColors: categoryColors,
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
  return Padding(
    padding: const EdgeInsets.all(AppConstants.defaultPadding),
    child: TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: 'Buscar registros...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onSearchCleared,
              )
            : null,
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        final results = fuzzySearch(value, allRecords);
        onSearchChanged(results);
      },

    ),
  );
}

List<SavingsRecord> fuzzySearch(String query, List<SavingsRecord> records) {
  // si query está vacía, devolvemos todo
  if (query.trim().isEmpty) {
    return records;
  }

  final normalizedQuery = query.toLowerCase().replaceAll(RegExp(r'[^\w\s]+'), '');

  return records.where((record) {
    final desc = record.description.toLowerCase().replaceAll(RegExp(r'[^\w\s]+'), '');
    final category = record.category.toLowerCase().replaceAll(RegExp(r'[^\w\s]+'), '');
    final descRatio = ratio(normalizedQuery, desc);
    final catRatio = ratio(normalizedQuery, category);
    return descRatio >= 70 || catRatio >= 70;
  }).toList();
}

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Row(
        children: [
          _buildFilterChip(AppConstants.depositsFilter, 'deposits'),
          const SizedBox(width: AppConstants.smallPadding),
          _buildFilterChip(AppConstants.withdrawalsFilter, 'withdrawals'),
          const SizedBox(width: AppConstants.defaultPadding),
          Builder(
            builder: (context) => _buildCategoryDropdown(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String text, String value) {
    final isSelected = currentFilter == value;
    return FilterChip(
      label: Text(text),
      selected: isSelected,
      onSelected: (selected) {
        if (isSelected) {
          onFilterChanged('all');
        } else {
          onFilterChanged(value);
        }
      },
    );
  }

  Widget _buildCategoryDropdown(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final primaryColor = Theme.of(context).colorScheme.primary; // USA colorScheme
  
  final borderColor = selectedCategory == 'all'
      ? (isDark ? Colors.grey.shade600 : Colors.grey.shade400)
      : primaryColor;
  final iconColor = selectedCategory == 'all'
      ? (isDark ? Colors.grey.shade400 : Colors.grey.shade700)
      : primaryColor;
  final textColor = selectedCategory == 'all'
      ? Theme.of(context).textTheme.bodyLarge?.color
      : primaryColor;

  return PopupMenuButton<String>(
    initialValue: selectedCategory,
    offset: const Offset(0, 40),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: selectedCategory == 'all' ? 1 : 2,
        ),
        borderRadius: BorderRadius.circular(8),
        color: selectedCategory == 'all'
            ? Colors.transparent
            : Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.category,
            size: 20,
            color: iconColor,
          ),
          const SizedBox(width: 8),
          Text(
            selectedCategory == 'all' 
                ? 'Categoría' 
                : selectedCategory,
            style: TextStyle(
              fontWeight: selectedCategory == 'all' 
                  ? FontWeight.normal 
                  : FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_drop_down,
            size: 20,
            color: iconColor,
          ),
        ],
      ),
    ),
    itemBuilder: (context) => [
      const PopupMenuItem(
        value: 'all',
        child: Text('Todas las categorías'),
      ),
      ...categories.map((category) => PopupMenuItem(
            value: category,
            child: Text(category),
          )),
    ],
    onSelected: (value) {
      onCategoryChanged(value);
    },
  );
}

  Widget _buildEmptyState(BuildContext context) {
  String title = AppConstants.emptyRecordsTitle;
  String subtitle = AppConstants.emptyRecordsSubtitle;

  if (searchQuery.isNotEmpty) {
    title = AppConstants.emptySearchTitle;
    subtitle = AppConstants.emptySearchSubtitle;
  } else if (selectedCategory != 'all') {
    title = AppConstants.emptyCategoryTitle;
    subtitle = AppConstants.emptyCategorySubtitle;
  }

  return SingleChildScrollView(
    child: EmptyRecordsWidget(
      title: title,
      subtitle: subtitle,
      onActionPressed: searchQuery.isEmpty ? onAddRecordTap : null,
      actionText: searchQuery.isEmpty ? 'Agregar Registro' : null,
    ),
  );
}


  void _showDeleteConfirmation(BuildContext context, SavingsRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppConstants.deleteRecordTitle),
        content: Text(
          '¿Eliminar "${record.description.isEmpty ? record.category : record.description}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppConstants.cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onDeleteRecord(record.id);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(AppConstants.deleteButtonLabel),
          ),
        ],
      ),
    );
  }
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
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[700],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
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