import 'package:flutter/material.dart';
import '../../models/color_palette.dart';
import 'package:flutter/services.dart';
import '../../models/savings_goal_model.dart';
import '../../services/savings_data_manager.dart';
import '../../utils/formatters.dart';

import '../../l10n/app_localizations.dart';
import 'dialogs/goal_dialog.dart';
import '../../widgets/goal_card.dart';
import '../../models/savings_record.dart';
import '../services/data_change_notifier.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String text = newValue.text.replaceAll('.', '');

    if (!RegExp(r'^\d+$').hasMatch(text)) {
      return oldValue;
    }

    String formatted = _formatWithThousands(text);

    int selectionIndex = newValue.selection.end;
    int oldDots =
        oldValue.text.substring(0, oldValue.selection.end).split('.').length -
        1;
    int newDots =
        formatted
            .substring(
              0,
              selectionIndex + (formatted.split('.').length - 1 - oldDots),
            )
            .split('.')
            .length -
        1;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: selectionIndex + newDots - oldDots,
      ),
    );
  }

  String _formatWithThousands(String text) {
    if (text.isEmpty) return text;

    String reversed = text.split('').reversed.join();
    String formatted = '';

    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formatted += '.';
      }
      formatted += reversed[i];
    }

    return formatted.split('').reversed.join();
  }
}

class GoalsScreen extends StatefulWidget {
  final SavingsDataManager dataManager;
  final ColorPalette palette;
  final VoidCallback? onGoalUpdated;

  const GoalsScreen({
    super.key,
    required this.dataManager,
    required this.palette,
    this.onGoalUpdated,
  });

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SavingsGoal> _activeGoals = [];
  List<SavingsGoal> _completedGoals = [];
  Map<String, dynamic> _statistics = {};
  Map<String, dynamic> _walletStatistics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGoals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGoals() async {
    setState(() => _isLoading = true);

    try {
      final activeGoals = await widget.dataManager.getActiveGoals();
      final completedGoals = await widget.dataManager.getCompletedGoals();
      final stats = await widget.dataManager.getGoalsStatistics();
      final walletStats = await widget.dataManager.getStatistics();

      setState(() {
        _activeGoals = activeGoals;
        _completedGoals = completedGoals;
        _statistics = stats;
        _walletStatistics = walletStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorSnackBar('Error al cargar metas');
      }
    }
  }

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => GoalDialog(
        palette: widget.palette,
        onSave: (goal) async {
          final success = await widget.dataManager.addGoal(goal);
          if (success) {
            await _loadGoals();
            DataChangeNotifier().notifyDataChanged();
            _showSuccessSnackBar('Meta creada exitosamente');
          } else {
            _showErrorSnackBar('Error al crear meta');
          }
        },
      ),
    );
  }

  void _showEditGoalDialog(SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (context) => GoalDialog(
        goal: goal,
        palette: widget.palette,
        onSave: (updatedGoal) async {
          final success = await widget.dataManager.updateGoal(updatedGoal);
          if (success) {
            await _loadGoals();
            DataChangeNotifier().notifyDataChanged();
            _showSuccessSnackBar('Meta actualizada');
          } else {
            _showErrorSnackBar('Error al actualizar meta');
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(SavingsGoal goal) {
    final l10n = AppLocalizations.of(context)!;
    final hasProgress = goal.currentAmount > 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(goal.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            const Expanded(child: Text('Eliminar Meta')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Eliminar la meta "${goal.name}"?'),

            if (hasProgress) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.green[700],
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Devolución de dinero',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Se devolverán \$${Formatters.formatCurrency(goal.currentAmount)} a tu billetera',
                      style: TextStyle(fontSize: 12, color: Colors.green[700]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);

              if (hasProgress) {
                final record = SavingsRecord(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  physicalAmount: 0,
                  digitalAmount: goal.currentAmount,
                  description: 'Devolución de meta eliminada: ${goal.name}',
                  createdAt: DateTime.now(),
                  type: RecordType.deposit,
                  category: 'Meta de Ahorro',
                  notes:
                      '${goal.emoji} Meta eliminada - Dinero devuelto automáticamente',
                );

                await widget.dataManager.addRecord(record);
                debugPrint('💰 Dinero devuelto: \$${goal.currentAmount}');
              }

              final success = await widget.dataManager.deleteGoal(goal.id);

              if (success) {
                await _loadGoals();
                DataChangeNotifier().notifyDataChanged();

                if (hasProgress) {
                  _showSuccessSnackBar(
                    '✅ Meta eliminada\n💰 \$${Formatters.formatCurrency(goal.currentAmount)} devuelto a tu billetera',
                  );
                } else {
                  _showSuccessSnackBar('Meta eliminada');
                }
              } else {
                _showErrorSnackBar('Error al eliminar meta');
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showMoneyDialog(SavingsGoal goal) {
    final controller = TextEditingController();
    bool isAdding = true;
    bool isPhysical = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('${goal.emoji} ${goal.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.account_balance_wallet,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Balance Disponible',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text(
                                '💵 Físico',
                                style: TextStyle(fontSize: 10),
                              ),
                              Text(
                                '\$${Formatters.formatCurrency(_walletStatistics['totalPhysical']?.toDouble() ?? 0.0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text(
                                '💳 Digital',
                                style: TextStyle(fontSize: 10),
                              ),
                              Text(
                                '\$${Formatters.formatCurrency(_walletStatistics['totalDigital']?.toDouble() ?? 0.0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      label: Text('Agregar'),
                      icon: Icon(Icons.add),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text('Retirar'),
                      icon: Icon(Icons.remove),
                    ),
                  ],
                  selected: {isAdding},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setDialogState(() {
                      isAdding = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[850]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isPhysical
                                ? Icons.account_balance_wallet
                                : Icons.credit_card,
                            size: 16,
                            color: isPhysical ? Colors.blue : Colors.purple,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Tipo de dinero:',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<bool>(
                          style: SegmentedButton.styleFrom(
                            selectedBackgroundColor: isPhysical
                                ? Colors.blue
                                : Colors.purple,
                            selectedForegroundColor: Colors.white,
                          ),
                          segments: const [
                            ButtonSegment(
                              value: true,
                              icon: Icon(
                                Icons.account_balance_wallet,
                                size: 16,
                              ),
                              label: Text(
                                'Físico',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            ButtonSegment(
                              value: false,
                              icon: Icon(Icons.credit_card, size: 16),
                              label: Text(
                                'Digital',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                          selected: {isPhysical},
                          onSelectionChanged: (Set<bool> newSelection) {
                            setDialogState(() {
                              isPhysical = newSelection.first;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Monto',
                    prefixText: '\$',
                    border: const OutlineInputBorder(),
                    helperText: isPhysical
                        ? '💵 Dinero físico'
                        : '💳 Dinero digital',
                    helperStyle: TextStyle(
                      color: isPhysical ? Colors.blue : Colors.purple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ThousandsSeparatorInputFormatter(),
                    LengthLimitingTextInputFormatter(15),
                  ],
                  autofocus: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final cleanAmount = controller.text
                    .replaceAll('.', '')
                    .replaceAll(',', '');
                final amount = double.tryParse(cleanAmount);

                if (amount != null && amount > 0) {
                  Navigator.pop(context);

                  final record = SavingsRecord(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    physicalAmount: isPhysical ? amount : 0,
                    digitalAmount: isPhysical ? 0 : amount,
                    description: isAdding
                        ? 'Aporte a meta: ${goal.name}'
                        : 'Retiro de meta: ${goal.name}',
                    createdAt: DateTime.now(),
                    type: isAdding ? RecordType.withdrawal : RecordType.deposit,
                    category: 'Meta de Ahorro',
                    notes:
                        '${goal.emoji} ${goal.name} | ${isPhysical ? "💵 Dinero físico" : "💳 Dinero digital"}',
                  );

                  final recordSuccess = await widget.dataManager.addRecord(
                    record,
                  );
                  debugPrint(
                    '📝 Registro creado: ${recordSuccess ? "✅" : "❌"}',
                  );
                  debugPrint(
                    '💰 Tipo: ${isAdding ? "RETIRO (para meta)" : "DEPÓSITO (desde meta)"}',
                  );
                  debugPrint(
                    '💵 Físico: \$${record.physicalAmount}, Digital: \$${record.digitalAmount}',
                  );

                  final goalSuccess = isAdding
                      ? await widget.dataManager.addMoneyToGoal(goal.id, amount)
                      : await widget.dataManager.removeMoneyFromGoal(
                          goal.id,
                          amount,
                        );

                  if (recordSuccess && goalSuccess) {
                    await _loadGoals();
                    DataChangeNotifier().notifyDataChanged();

                    final updatedGoal = _activeGoals.firstWhere(
                      (g) => g.id == goal.id,
                      orElse: () =>
                          _completedGoals.firstWhere((g) => g.id == goal.id),
                    );

                    if (updatedGoal.isCompleted && isAdding) {
                      _showGoalCompletedDialog(updatedGoal);
                    } else {
                      final moneyType = isPhysical ? 'físico' : 'digital';
                      final moneyIcon = isPhysical ? '💵' : '💳';
                      _showSuccessSnackBar(
                        isAdding
                            ? '$moneyIcon \$${Formatters.formatCurrency(amount)} $moneyType agregado a la meta'
                            : '$moneyIcon \$${Formatters.formatCurrency(amount)} $moneyType retirado de la meta',
                      );
                    }
                  } else {
                    _showErrorSnackBar('Error al procesar la transacción');
                  }
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: isAdding ? Colors.green : Colors.orange,
              ),
              child: Text(isAdding ? 'Agregar' : 'Retirar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalCompletedDialog(SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 ¡Meta Completada!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${goal.emoji} ${goal.name}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '\$${Formatters.formatCurrency(goal.targetAmount)}',
              style: TextStyle(fontSize: 32, color: Colors.green[700]),
            ),
            const SizedBox(height: 8),
            const Text(
              '¡Felicitaciones por alcanzar tu meta!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('¡Genial!'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check for desktop width
    final isDesktop = MediaQuery.of(context).size.width > 900;

    if (isDesktop) {
      return _buildDesktopLayout();
    }

    // Mobile Layout
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          if (_statistics.isNotEmpty && !_isLoading) _buildStatisticsCard(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Theme.of(context).textTheme.bodyLarge?.color,
                      labelPadding: EdgeInsets.zero,
                      tabs: [
                        Tab(text: 'Activas (${_activeGoals.length})'),
                        Tab(text: 'Completadas (${_completedGoals.length})'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: widget.palette.seedColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _showAddGoalDialog,
                    icon: Icon(
                      Icons.add,
                      color: widget.palette.seedColor.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildGoalsList(_activeGoals, isActive: true),
                      _buildGoalsList(_completedGoals, isActive: false),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mis Metas',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gestiona y visualiza tu progreso financiero',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: _showAddGoalDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva Meta'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Statistics Grid (3 Cards)
            if (_statistics.isNotEmpty && !_isLoading) _buildDesktopStats(),
            const SizedBox(height: 32),

            // Tabs and Content
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      indicatorColor: Theme.of(context).primaryColor,
                      labelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: const TextStyle(fontSize: 16),
                      tabs: [
                        Tab(text: 'Activas (${_activeGoals.length})'),
                        Tab(text: 'Completadas (${_completedGoals.length})'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildDesktopGoalsGrid(
                                _activeGoals,
                                isActive: true,
                              ),
                              _buildDesktopGoalsGrid(
                                _completedGoals,
                                isActive: false,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopStats() {
    final totalProgress = _statistics['totalProgress'] ?? 0.0;
    final totalCurrentAmount = _statistics['totalCurrentAmount'] ?? 0.0;
    final totalTargetAmount = _statistics['totalTargetAmount'] ?? 0.0;
    final progressPercent = (totalProgress * 100).clamp(0, 100).toInt();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Ahorro Total',
            value: '\$${Formatters.formatCurrency(totalCurrentAmount)}',
            icon: Icons.savings,
            color: Colors.blue,
            subtitle: 'En todas tus metas activas',
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildStatCard(
            title: 'Meta Global',
            value: '\$${Formatters.formatCurrency(totalTargetAmount)}',
            icon: Icons.flag,
            color: Colors.orange,
            subtitle: 'Objetivo total a alcanzar',
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildStatCard(
            title: 'Progreso General',
            value: '$progressPercent%',
            icon: Icons.trending_up,
            color: Colors.green,
            subtitle: 'Estás cada vez más cerca',
            isProgress: true,
            progressValue: totalProgress,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
    bool isProgress = false,
    double progressValue = 0.0,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                if (isProgress) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 6,
                      backgroundColor: color.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopGoalsGrid(
    List<SavingsGoal> goals, {
    required bool isActive,
  }) {
    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.flag_outlined : Icons.emoji_events_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isActive
                  ? 'No tienes metas activas actualmente'
                  : 'Aún no has completado ninguna meta',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              isActive
                  ? '¡Es un buen momento para empezar a ahorrar!'
                  : 'Sigue ahorrando para alcanzar tus objetivos',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            if (isActive) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _showAddGoalDialog,
                icon: const Icon(Icons.add),
                label: const Text('Crear Primera Meta'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 1.4,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return GoalCard(
          goal: goal,
          onTap: () => _showMoneyDialog(goal),
          onEdit: () => _showEditGoalDialog(goal),
          onDelete: () => _showDeleteConfirmation(goal),
        );
      },
    );
  }

  Widget _buildStatisticsCard() {
    final totalProgress = _statistics['totalProgress'] ?? 0.0;
    final totalCurrentAmount = _statistics['totalCurrentAmount'] ?? 0.0;
    final totalTargetAmount = _statistics['totalTargetAmount'] ?? 0.0;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern or decoration (optional)
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.trending_up,
              size: 100,
              color: Colors.white.withValues(alpha: 0.03),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progreso Total',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(totalProgress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        color: Colors.green[400],
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: totalProgress,
                    minHeight: 12,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green[400]!,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey[200]!,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStat(
                        'Ahorrado',
                        '\$${Formatters.formatCurrency(totalCurrentAmount)}',
                        Colors.blue[400]!,
                        isDark,
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.grey[300],
                      ),
                      _buildMiniStat(
                        'Meta Global',
                        '\$${Formatters.formatCurrency(totalTargetAmount)}',
                        Colors.orange[400]!,
                        isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsList(List<SavingsGoal> goals, {required bool isActive}) {
    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.flag_outlined : Icons.emoji_events_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isActive
                  ? 'No tienes metas activas'
                  : 'Aún no has completado ninguna meta',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (isActive) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _showAddGoalDialog,
                icon: const Icon(Icons.add),
                label: const Text('Crear primera meta'),
              ),
            ],
          ],
        ),
      );
    }

    final isDesktop = MediaQuery.of(context).size.width > 900;
    return RefreshIndicator(
      onRefresh: _loadGoals,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16, 16, 16, isDesktop ? 16 : 80),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          return GoalCard(
            goal: goal,
            onTap: () => _showMoneyDialog(goal),
            onEdit: () => _showEditGoalDialog(goal),
            onDelete: () => _showDeleteConfirmation(goal),
          );
        },
      ),
    );
  }
}
