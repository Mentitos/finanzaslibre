import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; // Added for Timer
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
import 'dialogs/recurring_expenses_dialog.dart';
import 'dialogs/due_recurring_dialog.dart'; // Startup check
import '../models/recurring_transaction.dart';
import 'package:finanzas/utils/snackbar_utils.dart';

import '../widgets/expandable_fab.dart';

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
  late PageController _pageController; // Added PageController
  late UserManager _userManager;
  final SavingsDataManager _dataManager = SavingsDataManager();
  final TextEditingController _searchController = TextEditingController();

  List<SavingsRecord> _allRecords = [];
  List<SavingsRecord> _filteredRecords = [];
  List<String> _categories = [];
  Map<String, dynamic> _statistics = {};
  Map<String, Color> _categoryColors = {};
  Map<String, IconData> _categoryIcons = {};

  String _currentFilter = 'all';
  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _isLoading = true;
  bool _privacyMode = false;
  final DataChangeNotifier _dataNotifier = DataChangeNotifier();
  bool _isQuickMoneyDialogOpen = false;
  MoneyType? _activeQuickMoneyType;

  // Recurring Check
  Timer? _recurringCheckTimer;
  final Set<String> _sessionSkippedRecurringIds = {};
  bool _isRecurringDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _userManager = widget.userManager;
    _dataManager.setUserManager(_userManager);
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _pageController = PageController(); // Initialize PageController
    _dataNotifier.addListener(_onDataChanged);
    _loadData();
    // Start periodic check
    _recurringCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkRecurringExpenses();
    });
    // Initial check
    Future.delayed(const Duration(seconds: 1), _checkRecurringExpenses);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService().checkForUpdatesOnStartup(context);
    });
  }

  @override
  void dispose() {
    _recurringCheckTimer?.cancel();
    _dataNotifier.removeListener(_onDataChanged);
    _tabController.dispose();
    _pageController.dispose(); // Dispose PageController
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    try {
      setState(() => _isLoading = true);
      final records = await _dataManager.loadRecords();
      final categories = await _dataManager.loadCategories();
      final stats = await _dataManager.getStatistics();
      final hideOnStartup = await _dataManager.loadHideBalancesOnStartup();
      final privacyModeSaved = await _dataManager.loadPrivacyMode();

      // Si la opción de ocultar al inicio está activa, forzamos privacyMode a true.
      // Si no, respetamos el último estado guardado.
      final privacyMode = hideOnStartup ? true : privacyModeSaved;
      final categoryColors = await _dataManager.loadAllCategoryColors();
      final categoryIcons = await _dataManager.loadAllCategoryIcons();

      setState(() {
        _allRecords = records;
        _categories = categories;
        _statistics = stats;
        _privacyMode = privacyMode;
        _categoryColors = categoryColors;
        _categoryIcons = categoryIcons;
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

  Future<void> _checkRecurringExpenses() async {
    if (_isRecurringDialogShowing) {
      // Check if dialog is ACTUALLY showing? No easy way.
      // We rely on the flag.
      return;
    }

    try {
      final due = await _dataManager.getDueRecurringTransactions();

      // Filter out skipped IDs
      final pending = due
          .where((t) => !_sessionSkippedRecurringIds.contains(t.id))
          .toList();

      if (pending.isEmpty) return;

      // Split into Auto vs Manual
      final autoProcess = pending.where((t) => t.autoPay).toList();
      final manualProcess = pending.where((t) => !t.autoPay).toList();

      // 1. Process Auto-Pay immediately
      if (autoProcess.isNotEmpty) {
        debugPrint(
          '⚡ Auto-Pay: Processing ${autoProcess.length} items automatically.',
        );
        int autoParamCount = 0;
        for (final t in autoProcess) {
          await _addRecord(
            SavingsRecord(
              id:
                  DateTime.now().millisecondsSinceEpoch.toString() +
                  t.id +
                  autoParamCount.toString(), // Unique ID
              physicalAmount: t.physicalAmount,
              digitalAmount: t.digitalAmount,
              description: t.name,
              createdAt: DateTime.now(),
              type: t.type,
              category: t.category,
            ),
          );
          await _dataManager.markRecurringTransactionAsProcessed(
            t.id,
            DateTime.now(),
          );
          autoParamCount++;
        }

        if (mounted) {
          SnackBarUtils.show(
            context,
            '⚡ ${autoProcess.length} pagos automáticos procesados (${autoProcess.map((e) => e.name).join(", ")})',
            color: Colors.amber[700],
          );
        }
      }

      // 2. Show Dialog for Manual items (if any)
      if (manualProcess.isNotEmpty && mounted) {
        // Double check context
        if (!context.mounted) return;

        debugPrint(
          '🔔 Manual Check: Showing dialog for ${manualProcess.length} items.',
        );
        _isRecurringDialogShowing = true;

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => DueRecurringDialog(
            dueTransactions: manualProcess,
            onSkip: () {
              // Mark as skipped for this session
              try {
                _sessionSkippedRecurringIds.addAll(
                  manualProcess.map((t) => t.id),
                );
              } catch (e) {
                debugPrint('Error skipping: $e');
              }
              Navigator.of(context).pop(); // Ensure close
            },
            onProcess: (selected) async {
              // Close dialog FIRST to unblock UI, then process
              Navigator.of(context).pop();

              if (selected.isEmpty) return;

              try {
                int processedCount = 0;
                for (final t in selected) {
                  await _addRecord(
                    SavingsRecord(
                      id:
                          DateTime.now().millisecondsSinceEpoch.toString() +
                          t.id,
                      physicalAmount: t.physicalAmount,
                      digitalAmount: t.digitalAmount,
                      description: t.name,
                      createdAt: DateTime.now(),
                      type: t.type,
                      category: t.category,
                    ),
                  );
                  await _dataManager.markRecurringTransactionAsProcessed(
                    t.id,
                    DateTime.now(),
                  );
                  processedCount++;
                }

                if (mounted) {
                  SnackBarUtils.show(
                    context,
                    '$processedCount gastos procesados',
                  );
                }
              } catch (e) {
                debugPrint('Error processing recurring: $e');
                if (mounted) {
                  SnackBarUtils.show(
                    context,
                    'Error al procesar algunos gastos',
                  );
                }
              }
            },
          ),
        );

        // Ensure flag is reset after dialog close (awaited)
        _isRecurringDialogShowing = false;
      }
    } catch (e) {
      debugPrint('Error in recurring check loop: $e');
      _isRecurringDialogShowing = false; // Reset on error
    }
  }

  void _changeTab(int index) {
    if (_tabController.index != index) {
      _tabController.animateTo(index);
    }
    if (_pageController.hasClients && _pageController.page?.round() != index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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

  Future<void> _addCategory(String category, Color color, IconData icon) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final success = await _dataManager.addCategory(category);
      if (success) {
        await _dataManager.saveCategoryColor(category, color);
        await _dataManager.saveCategoryIcon(category, icon);
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

  void _showAddRecordDialog({RecurringTransaction? template}) {
    showDialog(
      context: context,
      builder: (context) => RecordDialog(
        onSave: _addRecord,
        categories: _categories,
        categoryColors: _categoryColors,
        categoryIcons: _categoryIcons,
        initialCategory: _selectedCategory != 'all' ? _selectedCategory : null,
        template: template,
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
        categoryIcons: _categoryIcons,
        record: record,
        currentPhysicalBalance: _statistics['totalPhysical'] ?? 0.0,
        currentDigitalBalance: _statistics['totalDigital'] ?? 0.0,
      ),
    );
  }

  Future<void> _showQuickMoneyDialog(
    MoneyType moneyType,
    double currentAmount,
  ) async {
    setState(() {
      _isQuickMoneyDialogOpen = true;
      _activeQuickMoneyType = moneyType;
    });

    await showDialog(
      context: context,
      builder: (context) => QuickMoneyDialog(
        moneyType: moneyType,
        onSave: _addRecord,
        categories: _categories,
        categoryColors: _categoryColors,
        categoryIcons: _categoryIcons,
        currentAmount: currentAmount,
        userManager: _userManager,
      ),
    );

    if (mounted) {
      setState(() {
        _isQuickMoneyDialogOpen = false;
        _activeQuickMoneyType = null;
      });
    }
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
    // Define shortcuts for Desktop (Vertical Navigation)
    // Up/W -> Previous
    // Down/S -> Next
    final desktopShortcuts = <ShortcutActivator, Intent>{
      const SingleActivator(LogicalKeyboardKey.arrowRight):
          const NextTabIntent(),
      const SingleActivator(LogicalKeyboardKey.keyD): const NextTabIntent(),
      const SingleActivator(LogicalKeyboardKey.arrowDown):
          const NextTabIntent(),
      const SingleActivator(LogicalKeyboardKey.keyS): const NextTabIntent(),
      const SingleActivator(LogicalKeyboardKey.arrowLeft):
          const PreviousTabIntent(),
      const SingleActivator(LogicalKeyboardKey.keyA): const PreviousTabIntent(),
      const SingleActivator(LogicalKeyboardKey.arrowUp):
          const PreviousTabIntent(),
      const SingleActivator(LogicalKeyboardKey.keyW): const PreviousTabIntent(),
      const SingleActivator(LogicalKeyboardKey.keyQ):
          const QuickPhysicalIntent(),
      const SingleActivator(LogicalKeyboardKey.keyE):
          const QuickDigitalIntent(),
    };

    // Define shortcuts for Mobile (Horizontal Navigation at Top)
    // User requested swap:
    // W / Up -> Next (was Previous)
    // S / Down -> Previous (was Next)
    final mobileShortcuts = <ShortcutActivator, Intent>{
      const SingleActivator(LogicalKeyboardKey.arrowRight):
          const NextTabIntent(),
      const SingleActivator(LogicalKeyboardKey.keyD): const NextTabIntent(),
      // Swapped logic for Mobile:
      const SingleActivator(LogicalKeyboardKey.arrowDown):
          const PreviousTabIntent(),
      const SingleActivator(LogicalKeyboardKey.keyS): const PreviousTabIntent(),
      const SingleActivator(LogicalKeyboardKey.arrowLeft):
          const PreviousTabIntent(),
      const SingleActivator(LogicalKeyboardKey.keyA): const PreviousTabIntent(),
      const SingleActivator(LogicalKeyboardKey.arrowUp): const NextTabIntent(),
      const SingleActivator(LogicalKeyboardKey.keyW): const NextTabIntent(),
      const SingleActivator(LogicalKeyboardKey.keyQ):
          const QuickPhysicalIntent(),
      const SingleActivator(LogicalKeyboardKey.keyE):
          const QuickDigitalIntent(),
    };

    return Actions(
      actions: <Type, Action<Intent>>{
        NextTabIntent: CallbackAction<NextTabIntent>(
          onInvoke: (NextTabIntent intent) {
            final nextIndex =
                (_tabController.index + 1) % _tabController.length;
            _changeTab(nextIndex);
            return null;
          },
        ),
        PreviousTabIntent: CallbackAction<PreviousTabIntent>(
          onInvoke: (PreviousTabIntent intent) {
            final prevIndex =
                (_tabController.index - 1 + _tabController.length) %
                _tabController.length;
            _changeTab(prevIndex);
            return null;
          },
        ),
        QuickPhysicalIntent: CallbackAction<QuickPhysicalIntent>(
          onInvoke: (QuickPhysicalIntent intent) {
            if (_tabController.index == 0) {
              if (_isQuickMoneyDialogOpen) {
                Navigator.pop(context);
                if (_activeQuickMoneyType == MoneyType.digital) {
                  Future.delayed(const Duration(milliseconds: 150), () {
                    if (mounted) {
                      final amount = _statistics['totalPhysical'] ?? 0.0;
                      _showQuickMoneyDialog(MoneyType.physical, amount);
                    }
                  });
                }
              } else {
                final amount = _statistics['totalPhysical'] ?? 0.0;
                _showQuickMoneyDialog(MoneyType.physical, amount);
              }
            }
            return null;
          },
        ),
        QuickDigitalIntent: CallbackAction<QuickDigitalIntent>(
          onInvoke: (QuickDigitalIntent intent) {
            if (_tabController.index == 0) {
              if (_isQuickMoneyDialogOpen) {
                Navigator.pop(context);
                if (_activeQuickMoneyType == MoneyType.physical) {
                  Future.delayed(const Duration(milliseconds: 150), () {
                    if (mounted) {
                      final amount = _statistics['totalDigital'] ?? 0.0;
                      _showQuickMoneyDialog(MoneyType.digital, amount);
                    }
                  });
                }
              } else {
                final amount = _statistics['totalDigital'] ?? 0.0;
                _showQuickMoneyDialog(MoneyType.digital, amount);
              }
            }
            return null;
          },
        ),
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 700) {
            return Shortcuts(
              shortcuts: desktopShortcuts,
              child: Focus(
                autofocus: true,
                child: _buildDesktopLayout(context),
              ),
            );
          }
          return Shortcuts(
            shortcuts: mobileShortcuts,
            child: Focus(autofocus: true, child: _buildMobileLayout(context)),
          );
        },
      ),
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
            onDestinationSelected: _changeTab,
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
                : PageView(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable swipe to rely on rail
                    children: _buildTabViews(),
                  ),
          ),
        ],
      ),

      floatingActionButton: ExpandableFab(
        children: [
          FabAction(
            icon: Icons.camera_alt,
            label: 'Escanear', // Placeholder
            color: Colors.purple,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente: Escanear ticket')),
              );
            },
          ),
          FabAction(
            icon: Icons.repeat,
            label: 'Gastos Recurrentes',
            color: Colors.blue,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => RecurringExpensesDialog(
                  onSelectTemplate: (template) {
                    _showAddRecordDialog(template: template);
                  },
                ),
              );
            },
          ),
          FabAction(
            icon: Icons.edit_note,
            label: l10n.newRecord,
            color: Colors.orange,
            onTap: _showAddRecordDialog,
          ),
        ],
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
                if (mounted) {
                  setState(() {
                    _userRefreshKey++;
                  });
                }
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
          ).appBarTheme.foregroundColor?.withValues(alpha: 0.7),
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
      floatingActionButton: ExpandableFab(
        children: [
          FabAction(
            icon: Icons.camera_alt,
            label: 'Escanear',
            color: Colors.purple,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente: Escanear ticket')),
              );
            },
          ),
          FabAction(
            icon: Icons.repeat,
            label: 'Gastos Recurrentes',
            color: Colors.blue,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => RecurringExpensesDialog(
                  onSelectTemplate: (template) {
                    _showAddRecordDialog(template: template);
                  },
                ),
              );
            },
          ),
          FabAction(
            icon: Icons.edit_note,
            label: l10n.newRecord,
            color: Colors.orange,
            onTap: _showAddRecordDialog,
          ),
        ],
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
        onViewAllTap: () => _changeTab(1),
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
        categoryIcons: _categoryIcons,
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

class NextTabIntent extends Intent {
  const NextTabIntent();
}

class PreviousTabIntent extends Intent {
  const PreviousTabIntent();
}

class QuickPhysicalIntent extends Intent {
  const QuickPhysicalIntent();
}

class QuickDigitalIntent extends Intent {
  const QuickDigitalIntent();
}
