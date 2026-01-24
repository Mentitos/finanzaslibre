import 'package:flutter/material.dart';
import '../models/savings_record.dart';
import '../models/color_palette.dart';
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
import 'goals_screen.dart';
import 'package:finanzas/services/data_change_notifier.dart';
import 'package:finanzas/services/update_service.dart';

class SavingsScreen extends StatefulWidget {
  final UserManager userManager;
  final SavingsDataManager dataManager;
  final ColorPalette palette;

  const SavingsScreen({
    super.key,
    required this.dataManager,
    required this.userManager,
    required this.palette,
  });

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen>
    with TickerProviderStateMixin {
  int _userRefreshKey = 0;
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
  final DataChangeNotifier _dataNotifier = DataChangeNotifier();

  @override
  void initState() {
    super.initState();
    _userManager = widget.userManager;
    _dataManager.setUserManager(_userManager);
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _dataNotifier.addListener(_onDataChanged);
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService().checkForUpdatesOnStartup(context);
    });
  }

  @override
  void dispose() {
    _dataNotifier.removeListener(_onDataChanged);
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
      final hideOnStartup = await _dataManager.loadHideBalancesOnStartup();
      final privacyModeSaved = await _dataManager.loadPrivacyMode();

      // Si la opción de ocultar al inicio está activa, forzamos privacyMode a true.
      // Si no, respetamos el último estado guardado.
      final privacyMode = hideOnStartup ? true : privacyModeSaved;

      final categoryColors = await _dataManager.loadAllCategoryColors();

      setState(() {
        _allRecords = records;
        _categories = categories;
        _statistics = stats;
        _privacyMode = privacyMode;
        _categoryColors = categoryColors;
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

  void _onDataChanged() {
    debugPrint('📢 Cambio en datos detectado, recargando Summary...');
    _loadData();
  }

  void _applyFilters() {
    setState(() {
      _filteredRecords = _allRecords.where((record) {
        bool matchesType = switch (_currentFilter) {
          'deposits' => record.type == RecordType.deposit,
          'withdrawals' => record.type == RecordType.withdrawal,
          _ => true,
        };

        bool matchesCategory =
            _selectedCategory == 'all' || record.category == _selectedCategory;

        bool matchesSearch =
            _searchQuery.isEmpty ||
            record.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            record.category.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            (record.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false);

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
        currentPhysicalBalance: _statistics['totalPhysical'] ?? 0.0,
        currentDigitalBalance: _statistics['totalDigital'] ?? 0.0,
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
        currentPhysicalBalance: _statistics['totalPhysical'] ?? 0.0,
        currentDigitalBalance: _statistics['totalDigital'] ?? 0.0,
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

  void _showSettingsMenu() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          dataManager: _dataManager,
          userManager: _userManager,
          onDataChanged: () async {
            _dataManager.setUserManager(_userManager);
            await _loadData();

            setState(() {
              _userRefreshKey++;
            });
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

    setState(() {
      _userRefreshKey++;
    });
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 700) {
          return _buildDesktopLayout(context);
        }
        return _buildMobileLayout(context);
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.appName),
            UserSelectorMenu(
              key: ValueKey(_userRefreshKey),
              userManager: _userManager,
              refreshKey: ValueKey(_userRefreshKey),
              onUserChanged: () async {
                _dataManager.setUserManager(_userManager);
                await _loadData();
                setState(() {
                  _userRefreshKey++;
                });
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
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _tabController.index,
            onDestinationSelected: (int index) {
              setState(() {
                _tabController.animateTo(index);
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard),
                label: Text(l10n.summary),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.history_outlined),
                selectedIcon: const Icon(Icons.history),
                label: Text(l10n.history),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.category_outlined),
                selectedIcon: const Icon(Icons.category),
                label: Text(l10n.categories),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.flag_outlined),
                selectedIcon: const Icon(Icons.flag),
                label: Text('Metas'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: _buildTabViews(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRecordDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.appName),
            UserSelectorMenu(
              key: ValueKey(_userRefreshKey),
              userManager: _userManager,
              refreshKey: ValueKey(_userRefreshKey),
              onUserChanged: () async {
                _dataManager.setUserManager(_userManager);
                await _loadData();
                setState(() {
                  _userRefreshKey++;
                });
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
          labelColor: Theme.of(context).appBarTheme.foregroundColor,
          unselectedLabelColor: Theme.of(
            context,
          ).appBarTheme.foregroundColor?.withOpacity(0.7),
          indicatorColor: Theme.of(context).appBarTheme.foregroundColor,
          tabs: [
            Tab(text: l10n.summary, icon: const Icon(Icons.dashboard)),
            Tab(text: l10n.history, icon: const Icon(Icons.history)),
            Tab(text: l10n.categories, icon: const Icon(Icons.category)),
            Tab(text: 'Metas', icon: const Icon(Icons.flag)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(controller: _tabController, children: _buildTabViews()),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRecordDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Widget> _buildTabViews() {
    return [
      SummaryTab(
        statistics: _statistics,
        allRecords: _allRecords,
        categoryColors: _categoryColors,
        privacyMode: _privacyMode,
        onRefresh: _loadData,
        onEditRecord: _showEditRecordDialog,
        onQuickMoneyTap: _showQuickMoneyDialog,
        onViewAllTap: () => _tabController.animateTo(1),
        palette: widget.palette,
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
      GoalsScreen(
        dataManager: _dataManager,
        palette: widget.palette,
        onGoalUpdated: _loadData,
      ),
    ];
  }
}
