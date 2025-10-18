import 'package:flutter/material.dart';
import '../../models/savings_record.dart';
import '../../widgets/record_item.dart';
import '../../constants/app_constants.dart';
import '../../l10n/app_localizations.dart';

class HistoryTab extends StatelessWidget {
  final List<SavingsRecord> filteredRecords;
  final List<String> categories;
  final Map<String, Color> categoryColors;
  final String currentFilter;
  final String selectedCategory;
  final String searchQuery; // Lo mantenemos para el mensaje de "sin resultados"
  final TextEditingController searchController;
  final Future<void> Function() onRefresh;
  final Function(SavingsRecord) onEditRecord;
  final Function(String) onDeleteRecord;
  final Function(String) onFilterChanged;
  final Function(String) onCategoryChanged;
  final Function(String) onSearchChanged; // CAMBIO 1: Ahora recibe un String
  final VoidCallback onAddRecordTap;

  const HistoryTab({
    super.key,
    required this.filteredRecords,
    required this.categories,
    required this.categoryColors,
    required this.currentFilter,
    required this.selectedCategory,
    required this.searchQuery, // El parámetro que faltaba en la llamada
    required this.searchController,
    required this.onRefresh,
    required this.onEditRecord,
    required this.onDeleteRecord,
    required this.onFilterChanged,
    required this.onCategoryChanged,
    required this.onSearchChanged, // Firma actualizada
    required this.onAddRecordTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
      return Column(
      children: [
        _buildSearchBar(l10n),
        _buildFilters(context, l10n), // Pasamos el context
        Expanded(
          child: filteredRecords.isEmpty
              ? _buildEmptyState(context, l10n)
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
                        onDelete: () => _showDeleteConfirmation(context, record, l10n),
                        showCategory: true,
                        categoryColors: categoryColors,
                        l10n: l10n, 
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: l10n.searchRecords, 
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    onSearchChanged(''); // Notifica que se limpió
                  },
                )
              : null,
          border: const OutlineInputBorder(),
        ),
        // CAMBIO 2: El onChanged ahora solo notifica el texto.
        onChanged: onSearchChanged,
      ),
    );
  }
  
  // CAMBIO 3: La función fuzzySearch se elimina de aquí.
  // La lógica ahora vive en _applyFilters() dentro de savings_screen.dart

  Widget _buildFilters(BuildContext context, AppLocalizations l10n) { // Recibe context
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(AppConstants.defaultPadding, 0, AppConstants.defaultPadding, AppConstants.defaultPadding),
      child: Row(
        children: [
          _buildFilterChip(l10n.deposits, 'deposits'), 
          const SizedBox(width: AppConstants.smallPadding),
          _buildFilterChip(l10n.withdrawals, 'withdraw