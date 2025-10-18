import 'package:flutter/material.dart';
import '../models/savings_record.dart';
import '../models/user_model.dart';
import '../services/savings_data_manager.dart';
import '../services/user_manager.dart';
import '../widgets/record_dialog.dart';
import '../widgets/quick_money_dialog.dart';
import '../widgets/user_selector_menu.dart';
import '../constants/app_constants.dart';
import 'tabs/summary_tab.dart';
import 'tabs/history_tab.dart';
import 'tabs/categories_tab.dart';
import 'settings/settings_screen.dart';
import '../l10n/app_localizations.dart';

class SavingsScreen extends StatefulWidget {
  final UserManager userManager;

  const SavingsScreen({
    super.key,
    required this.userManager,
  });

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late UserManager _userManager;
  final SavingsDataManager _dataManager = SavingsDataManager();
  final TextEditingController _searchController = TextEditingController();

  List<SavingsRecord> _allRecords = [];
  List<SavingsRecord> _filteredRecords = [];
  List<String> _categories = [];
  Map<String, dynamic> _statistics = {};
  Map<String, Color> _categoryColors = {};

  String _currentFilter = 'all';
  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _isLoading = true;
  bool _privacyMode = false;
  User? _currentUser;
//ignorar eso de advertencia de indefinido y tal
  @override
  void initState() {
    super.initState();
    _userManager = widget.userManager;
    _dataManager.setUserManager(_userManager);
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final records = await _dataManager.loadRecords();
      final categories = await _dataManager.loadCategories();
      final stats = await _dataManager.getStatistics();
      final privacyMode = await _dataManager.loadPrivacyMode();
      final categoryColors = await _dataManager.loadAllCategoryColors();
      final currentUser = _userManager.getCurrentUserSync();

      setState(() {
        _allRecords = records;
        _categories = categories;
        _statistics = stats;
        _privacyMode = privacyMode;
        _categoryColors = categoryColors;
        _currentUser = currentUser;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showErrorSnackBar(l10n.loadError);
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredRecords = _allRecords.where((record) {
        bool matchesType = switch (_currentFilter) {
          'deposits' => record.type == RecordType.deposit,
          'withdrawals' => record.type == RecordType.withdrawal,
          _ => true,
        };

        bool matchesCategory = _selectedCategory == 'all' ||
            record.category == _selectedCategory;

        bool matchesSearch = _searchQuery.isEmpty ||
            record.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (record.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        return matchesType && matchesCategory && matchesSearch;
      }).toList();
    });
  }

  Future<void> _addRecord(SavingsRecord record) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final success = await _dataManager.addRecord(record);
      if (success) {
        await _loadData();
        _showSuccessSnackBar(l10n.recordSaved);
      } else {
        _showErrorSnackBar(l10n.saveError);
      }
    } catch (e) {
      _showErrorSnackBar(l10n.genericError);
    }
  }

  Future<void> _updateRecord(SavingsRecord record) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final success = await _dataManager.updateRecord(record);
      if (success) {
        await _loadData();
        _showSuccessSnackBar(l10n.recordUpdated);
      } else {
        _showErrorSnackBar(l10n.saveError);
      }
    } catch (e) {
      _showErrorSnackBar(l10n.genericError);
    }
  }

  Future<void> _deleteRecord(String id) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final success = await _dataManager.deleteRecord(id);
      if (success) {
        await _loadData();
        _showSuccessSnackBar(l10n.recordDeleted);
      } else {
        _showErrorSnackBar(l10n.genericError);
      }
    } catch (e) {
      _showErrorSnackBar(l10n.genericError);
    }
  }

  Future<void> _addCategory(String category, Color color) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final success = await _dataManager.addCategory(category);
      if (success) {
        await _dataManager.saveCategoryColor(category, color);
        await _loadData();
        _showSuccessSnackBar(l10n.categorySaved);
      } else {
        _showErrorSnackBar(l10n.categoryExists);
      }
    } catch (e) {
      _showErrorSnackBar(l10n.genericError);
    }
  }

  Future<void> _deleteCategory(String category) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final success = await _dataManager.deleteCategory(category);
      if (success) {
        await _loadData();
        _showSuccessSnackBar(l10n.categoryDeleted);
      } else {
        _showErrorSnackBar(l10n.categoryInUse);
      }
    } catch (e) {
      _showErrorSnackBar(l10n.genericError);
    }
  }

  Future<void> _togglePrivacyMode() async {
    setState(() => _privacyMode = !_privacyMode);
    await _dataManager.savePrivacyMode(_privacyMode);
  }

  void _showAddRecordDialog() {
    showDialog(
      context: context,
      builder: (context) => RecordDialog(
        onSave: _addRecord,
        categories: _categories,
        categoryColors: _categoryColors,
        initialCategory: _selectedCategory != 'all' ? _selectedCategory : null,
      ),
    );
  }

  void _showEditRecordDialog(SavingsRecord record) {
    showDialog(
      context: context,
      builder: (context) => RecordDialog(
        onSave: _updateRecord,
        categories: _categories,
        categoryColors: _categoryColors,
        record: record,
      ),
    );
  }

  void _showQuickMoneyDialog(MoneyType moneyType, double currentAmount) {
    showDialog(
      context: context,
      builder: (context) => QuickMoneyDialog(
        moneyType: moneyType,
        onSave: _addRecord,
        categories: _categories,
        categoryColors: _categoryColors,
        currentAmount: currentAmount,
        userManager: _userManager,
      ),
    );
  }

  void _showSettingsMenu() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          dataManager: _dataManager,
          userManager: _userManager,
          onDataChanged: () async {
            _dataManager.setUserManager(_userManager);
            await _loadData();
            setState(() {});
          },
          onShowSnackBar: (message, isError) {
            if (isError) {
              _showErrorSnackBar(message);
            } else {
              _showSuccessSnackBar(message);
            }
          },
          allRecordsCount: _allRecords.length,
          categoriesCount: _categories.length,
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppConstants.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.appName),
            UserSelectorMenu(
              userManager: _userManager,
              onUserChanged: () async {
                _dataManager.setUserManager(_userManager);
                await _loadData();
              },
              onShowSnackBar: (message, isError) {
                if (isError) {
                  _showErrorSnackBar(message);
                } else {
                  _showSuccessSnackBar(message);
                }
              },
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_privacyMode ? Icons.visibility_off : Icons.visibility),
            onPressed: _togglePrivacyMode,
            tooltip: _privacyMode ? l10n.showAmounts : l10n.hideAmounts,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsMenu,
            tooltip: l10n.settings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.summary, icon: const Icon(Icons.dashboard)),
            Tab(text: l10n.history, icon: const Icon(Icons.history)),
            Tab(text: l10n.categories, icon: const Icon(Icons.category)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                SummaryTab(
                  statistics: _statistics,
                  allRecords: _allRecords,
                  categoryColors: _categoryColors,
                  privacyMode: _privacyMode,
                  onRefresh: _loadData,
                  onEditRecord: _showEditRecordDialog,
                  onQuickMoneyTap: _showQuickMoneyDialog,
                  onViewAllTap: () => _tabController.animateTo(1),
                ),
                HistoryTab(
                  allRecords: _allRecords,
                  filteredRecords: _filteredRecords,
                  categories: _categories,
                  categoryColors: _categoryColors,
                  currentFilter: _currentFilter,
                  selectedCategory: _selectedCategory,
                  searchQuery: _searchQuery,
                  searchController: _searchController,
                  onRefresh: _loadData,
                  onEditRecord: _showEditRecordDialog,
                  onDeleteRecord: _deleteRecord,
                  onFilterChanged: (filter) {
                    setState(() {
                      _currentFilter = filter;
                      _applyFilters();
                    });
                  },
                  onCategoryChanged: (category) {
                    setState(() {
                      _selectedCategory = category;
                      _applyFilters();
                    });
                  },
                  onSearchChanged: (List<SavingsRecord> results) {
                    setState(() {
                      _filteredRecords = results;
                    });
                  },
                  onSearchCleared: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _applyFilters();
                    });
                  },
                  onAddRecordTap: _showAddRecordDialog,
                ),
                CategoriesTab(
                  statistics: _statistics,
                  categories: _categories,
                  categoryColors: _categoryColors,
                  onAddCategory: _addCategory,
                  onDeleteCategory: _deleteCategory,
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRecordDialog,
        icon: const Icon(Icons.add),
        label: Text(l10n.new_),
        backgroundColor: Colors.green,
        foregroundColor: Theme.of(context).cardColor,
      ),
    );
  }
}