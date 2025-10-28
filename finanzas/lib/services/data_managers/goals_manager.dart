import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/savings_goal_model.dart';

class GoalsManager {
  final SharedPreferences _prefs;
  List<SavingsGoal>? _cachedGoals;
  dynamic _userManager;

  static const String _goalsKey = 'savings_goals';

  GoalsManager(this._prefs);

  void setUserManager(dynamic userManager) {
    _userManager = userManager;
    clearCache();
  }

  void clearCache() {
    _cachedGoals = null;
    debugPrint('Cache de metas limpiado');
  }

  String _getUserDataKey(String key) {
    final currentUser = _userManager?.getCurrentUserSync();
    if (currentUser == null) {
      return key;
    }
    return '${currentUser.id}_$key';
  }

  /// Cargar todas las metas
  Future<List<SavingsGoal>> loadGoals({bool forceReload = false}) async {
    if (_cachedGoals != null && !forceReload) {
      return List.from(_cachedGoals!);
    }

    try {
      final key = _getUserDataKey(_goalsKey);
      final String? goalsJson = _prefs.getString(key);

      if (goalsJson != null) {
        final List<dynamic> goalsList = json.decode(goalsJson);
        _cachedGoals = goalsList
            .map((json) => SavingsGoal.fromJson(json))
            .toList();

        // Ordenar por fecha de creación (más recientes primero)
        _cachedGoals!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        debugPrint('✅ Se cargaron ${_cachedGoals!.length} metas');
        return List.from(_cachedGoals!);
      }
    } catch (e) {
      debugPrint('❌ Error cargando metas: $e');
    }

    _cachedGoals = [];
    return [];
  }

  /// Guardar todas las metas
  Future<bool> saveGoals(List<SavingsGoal> goals) async {
    try {
      final key = _getUserDataKey(_goalsKey);
      final String goalsJson = json.encode(
        goals.map((goal) => goal.toJson()).toList(),
      );

      final success = await _prefs.setString(key, goalsJson);

      if (success) {
        _cachedGoals = List.from(goals);
        debugPrint('✅ ${goals.length} metas guardadas');
      }

      return success;
    } catch (e) {
      debugPrint('❌ Error guardando metas: $e');
      return false;
    }
  }

  /// Agregar una nueva meta
  Future<bool> addGoal(SavingsGoal goal) async {
    final goals = await loadGoals();
    goals.insert(0, goal);
    return await saveGoals(goals);
  }

  /// Actualizar una meta existente
  Future<bool> updateGoal(SavingsGoal updatedGoal) async {
    final goals = await loadGoals();
    final index = goals.indexWhere((g) => g.id == updatedGoal.id);

    if (index != -1) {
      goals[index] = updatedGoal;
      return await saveGoals(goals);
    }

    return false;
  }

  /// Eliminar una meta
  Future<bool> deleteGoal(String id) async {
    final goals = await loadGoals();
    final initialLength = goals.length;
    goals.removeWhere((goal) => goal.id == id);

    if (goals.length < initialLength) {
      return await saveGoals(goals);
    }

    return false;
  }

  /// Agregar dinero a una meta
  Future<bool> addMoneyToGoal(String goalId, double amount) async {
    final goals = await loadGoals();
    final index = goals.indexWhere((g) => g.id == goalId);

    if (index != -1) {
      final goal = goals[index];
      final newAmount = goal.currentAmount + amount;
      
      // Si alcanza la meta, cambiar status a completada
      final newStatus = newAmount >= goal.targetAmount 
          ? GoalStatus.completed 
          : goal.status;
      
      goals[index] = goal.copyWith(
        currentAmount: newAmount,
        status: newStatus,
      );
      
      return await saveGoals(goals);
    }

    return false;
  }

  /// Retirar dinero de una meta
  Future<bool> removeMoneyFromGoal(String goalId, double amount) async {
    final goals = await loadGoals();
    final index = goals.indexWhere((g) => g.id == goalId);

    if (index != -1) {
      final goal = goals[index];
      final newAmount = (goal.currentAmount - amount).clamp(0.0, double.infinity);
      
      goals[index] = goal.copyWith(currentAmount: newAmount);
      return await saveGoals(goals);
    }

    return false;
  }

  /// Marcar meta como completada
  Future<bool> completeGoal(String goalId) async {
    final goals = await loadGoals();
    final index = goals.indexWhere((g) => g.id == goalId);

    if (index != -1) {
      goals[index] = goals[index].copyWith(status: GoalStatus.completed);
      return await saveGoals(goals);
    }

    return false;
  }

  /// Obtener solo metas activas
  Future<List<SavingsGoal>> getActiveGoals() async {
    final goals = await loadGoals();
    return goals.where((g) => g.status == GoalStatus.active).toList();
  }

  /// Obtener solo metas completadas
  Future<List<SavingsGoal>> getCompletedGoals() async {
    final goals = await loadGoals();
    return goals.where((g) => g.status == GoalStatus.completed).toList();
  }

  /// Obtener estadísticas de metas (SOLO ACTIVAS)
  Future<Map<String, dynamic>> getGoalsStatistics() async {
    final goals = await loadGoals();
    
    // ✨ SOLO CONTAR METAS ACTIVAS PARA ESTADÍSTICAS
    final activeGoals = goals.where((g) => g.status == GoalStatus.active).toList();
    final completedGoals = goals.where((g) => g.status == GoalStatus.completed).toList();
    
    // Calcular totales solo con metas activas
    final totalTargetAmount = activeGoals.fold<double>(0, (sum, g) => sum + g.targetAmount);
    final totalCurrentAmount = activeGoals.fold<double>(0, (sum, g) => sum + g.currentAmount);
    final totalProgress = totalTargetAmount > 0 
        ? totalCurrentAmount / totalTargetAmount 
        : 0.0;

    return {
      'totalGoals': goals.length,
      'activeGoals': activeGoals.length,
      'completedGoals': completedGoals.length,
      'totalTargetAmount': totalTargetAmount,
      'totalCurrentAmount': totalCurrentAmount,
      'totalProgress': totalProgress,
      'averageProgress': activeGoals.isNotEmpty
          ? activeGoals.fold<double>(0, (sum, g) => sum + g.progress) / activeGoals.length
          : 0.0,
    };
  }
}