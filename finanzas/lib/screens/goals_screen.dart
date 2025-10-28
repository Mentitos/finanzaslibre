import 'package:flutter/material.dart';
import '../../models/savings_goal_model.dart';
import '../../services/savings_data_manager.dart';
import '../../utils/formatters.dart';
import '../../constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import 'dialogs/goal_dialog.dart';
import '../../widgets/goal_card.dart';
import '../../models/savings_record.dart';


class GoalsScreen extends StatefulWidget {
  final SavingsDataManager dataManager;

  const GoalsScreen({
    super.key,
    required this.dataManager,
  });

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SavingsGoal> _activeGoals = [];
  List<SavingsGoal> _completedGoals = [];
  Map<String, dynamic> _statistics = {};
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

      setState(() {
        _activeGoals = activeGoals;
        _completedGoals = completedGoals;
        _statistics = stats;
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
        onSave: (goal) async {
          final success = await widget.dataManager.addGoal(goal);
          if (success) {
            await _loadGoals();
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
        onSave: (updatedGoal) async {
          final success = await widget.dataManager.updateGoal(updatedGoal);
          if (success) {
            await _loadGoals();
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
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Meta'),
        content: Text('¿Eliminar la meta "${goal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await widget.dataManager.deleteGoal(goal.id);
              if (success) {
                await _loadGoals();
                _showSuccessSnackBar('Meta eliminada');
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
    bool isPhysical = true; // Nueva variable para tipo de dinero

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('${goal.emoji} ${goal.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selector Agregar/Retirar
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Agregar'), icon: Icon(Icons.add)),
                  ButtonSegment(value: false, label: Text('Retirar'), icon: Icon(Icons.remove)),
                ],
                selected: {isAdding},
                onSelectionChanged: (Set<bool> newSelection) {
                  setDialogState(() {
                    isAdding = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Selector Físico/Digital
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850]
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 20),
                    const SizedBox(width: 8),
                    const Text('Tipo de dinero:', style: TextStyle(fontSize: 14)),
                    const Spacer(),
                    SegmentedButton<bool>(
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: Colors.blue,
                        selectedForegroundColor: Colors.white,
                      ),
                      segments: const [
                        ButtonSegment(
                          value: true,
                          icon: Icon(Icons.account_balance_wallet, size: 16),
                          label: Text('Físico', style: TextStyle(fontSize: 12)),
                        ),
                        ButtonSegment(
                          value: false,
                          icon: Icon(Icons.credit_card, size: 16),
                          label: Text('Digital', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                      selected: {isPhysical},
                      onSelectionChanged: (Set<bool> newSelection) {
                        setDialogState(() {
                          isPhysical = newSelection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Campo de monto
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Monto',
                  prefixText: '\$',
                  border: const OutlineInputBorder(),
                  helperText: isPhysical ? 'Dinero físico' : 'Dinero digital',
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final amount = double.tryParse(controller.text.replaceAll('.', ''));
                if (amount != null && amount > 0) {
                  Navigator.pop(context);
                  
                  // Actualizar la meta
                  final success = isAdding
                      ? await widget.dataManager.addMoneyToGoal(goal.id, amount)
                      : await widget.dataManager.removeMoneyFromGoal(goal.id, amount);
                  
                  if (success) {
                    // Crear registro vinculado
                    final record = SavingsRecord(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      physicalAmount: isPhysical ? amount : 0,
                      digitalAmount: isPhysical ? 0 : amount,
                      description: '${isAdding ? "Aporte a" : "Retiro de"} meta: ${goal.name}',
                      createdAt: DateTime.now(),
                      type: isAdding ? RecordType.deposit : RecordType.withdrawal,
                      category: 'Meta de Ahorro',
                      notes: 'Vinculado a meta ${goal.emoji} ${goal.name}',
                    );
                    
                    await widget.dataManager.addRecord(record);
                    await _loadGoals();
                    
                    // Verificar si se completó
                    final updatedGoal = _activeGoals.firstWhere(
                      (g) => g.id == goal.id,
                      orElse: () => _completedGoals.firstWhere((g) => g.id == goal.id),
                    );
                    
                    if (updatedGoal.isCompleted && isAdding) {
                      _showGoalCompletedDialog(updatedGoal);
                    } else {
                      final moneyType = isPhysical ? 'físico' : 'digital';
                      _showSuccessSnackBar(
                        isAdding 
                          ? 'Dinero $moneyType agregado a la meta' 
                          : 'Dinero $moneyType retirado de la meta'
                      );
                    }
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
          backgroundColor: Colors.green,
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
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Header personalizado (sin AppBar)
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 8),
                  Text(
                    'Metas',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Botón para agregar meta
              FilledButton.icon(
                onPressed: _showAddGoalDialog,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Nueva'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ),

        // Estadísticas
        if (_statistics.isNotEmpty && !_isLoading) _buildStatisticsCard(),

        // TabBar para Activas/Completadas
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
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
            tabs: [
              Tab(text: 'Activas (${_activeGoals.length})'),
              Tab(text: 'Completadas (${_completedGoals.length})'),
            ],
          ),
        ),

        // Contenido
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
    );
  }

  Widget _buildStatisticsCard() {
    final totalProgress = _statistics['totalProgress'] ?? 0.0;
    final totalCurrentAmount = _statistics['totalCurrentAmount'] ?? 0.0;
    final totalTargetAmount = _statistics['totalTargetAmount'] ?? 0.0;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progreso Total',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${(totalProgress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: totalProgress,
                minHeight: 12,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${Formatters.formatCurrency(totalCurrentAmount)}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  '\$${Formatters.formatCurrency(totalTargetAmount)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
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
              isActive ? 'No tienes metas activas' : 'Aún no has completado ninguna meta',
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

    return RefreshIndicator(
      onRefresh: _loadGoals,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
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