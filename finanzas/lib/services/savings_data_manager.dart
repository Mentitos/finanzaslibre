import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/savings_record.dart';
import 'data_managers/records_manager.dart';
import 'data_managers/categories_manager.dart';
import 'data_managers/security_manager.dart';
import 'data_managers/privacy_manager.dart';
import 'data_managers/import_export_manager.dart';
import 'data_managers/data_cleanup_manager.dart';
import 'data_managers/goals_manager.dart';
import '../models/savings_goal_model.dart';
import 'data_managers/recurring_manager.dart';
import '../models/recurring_transaction.dart';

class SavingsDataManager {
  static final SavingsDataManager _instance = SavingsDataManager._internal();

  factory SavingsDataManager() => _instance;
  SavingsDataManager._internal();

  static void init() {}

  late SharedPreferences _prefs;

  late GoalsManager _goalsManager;
  late RecurringManager _recurringManager;
  late RecordsManager _recordsManager;
  late CategoriesManager _categoriesManager;
  late SecurityManager _securityManager;
  late PrivacyManager _privacyManager;
  late ImportExportManager _importExportManager;
  late DataCleanupManager _dataCleanupManager;

  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      _recordsManager = RecordsManager(_prefs);
      _categoriesManager = CategoriesManager(_prefs);
      _securityManager = SecurityManager(_prefs);
      _privacyManager = PrivacyManager(_prefs);
      _importExportManager = ImportExportManager();
      _dataCleanupManager = DataCleanupManager(_prefs);
      _goalsManager = GoalsManager(_prefs);
      _recurringManager = RecurringManager(_prefs);
    } catch (e) {
      debugPrint('❌ Error initializing SavingsDataManager: $e');
    }
  }

  // --- DELEGACIÓN A RECORDS MANAGER ---
  Future<List<SavingsRecord>> loadRecords({bool forceReload = false}) =>
      _recordsManager.loadRecords(forceReload: forceReload);

  Future<bool> saveRecords(List<SavingsRecord> records) =>
      _recordsManager.saveRecords(records);

  Future<bool> addRecord(SavingsRecord record) =>
      _recordsManager.addRecord(record);

  Future<bool> updateRecord(SavingsRecord updatedRecord) =>
      _recordsManager.updateRecord(updatedRecord);

  Future<bool> deleteRecord(String id) => _recordsManager.deleteRecord(id);

  Future<List<SavingsRecord>> searchRecords({
    String? query,
    RecordType? type,
    String? category,
    DateTime? fromDate,
    DateTime? toDate,
  }) => _recordsManager.searchRecords(
    query: query,
    type: type,
    category: category,
    fromDate: fromDate,
    toDate: toDate,
  );

  Future<Map<String, dynamic>> getStatistics() =>
      _recordsManager.getStatistics();

  // --- DELEGACIÓN A CATEGORIES MANAGER ---
  Future<List<String>> loadCategories({bool forceReload = false}) =>
      _categoriesManager.loadCategories(forceReload: forceReload);

  Future<bool> saveCategories(List<String> categories) =>
      _categoriesManager.saveCategories(categories);

  Future<bool> addCategory(String category) =>
      _categoriesManager.addCategory(category);

  Future<bool> addCategoryWithColor(String category, Color color) =>
      _categoriesManager.addCategoryWithColor(category, color);

  Future<bool> addCategoryWithColorAndIcon(
    String category,
    Color color,
    IconData icon,
  ) => _categoriesManager.addCategoryWithColorAndIcon(category, color, icon);

  Future<bool> deleteCategory(String category) =>
      _categoriesManager.deleteCategory(category);

  Future<bool> saveCategoryColor(String category, Color color) =>
      _categoriesManager.saveCategoryColor(category, color);

  Future<Color?> loadCategoryColor(String category) =>
      _categoriesManager.loadCategoryColor(category);

  Future<Map<String, Color>> loadAllCategoryColors() =>
      _categoriesManager.loadAllCategoryColors();

  Future<bool> saveCategoryIcon(String category, IconData icon) =>
      _categoriesManager.saveCategoryIcon(category, icon);

  Future<IconData> loadCategoryIcon(String category) =>
      _categoriesManager.loadCategoryIcon(category);

  Future<Map<String, IconData>> loadAllCategoryIcons() =>
      _categoriesManager.loadAllCategoryIcons();

  // --- DELEGACIÓN A SECURITY MANAGER ---
  Future<bool> savePinData(String pin, bool biometricEnabled) =>
      _securityManager.savePinData(pin, biometricEnabled);

  Future<bool> savePin(String pin) => _securityManager.savePin(pin);

  Future<String?> loadPin() => _securityManager.loadPin();

  Future<bool> isPinEnabled() => _securityManager.isPinEnabled();

  Future<bool> setPinEnabled(bool enabled) =>
      _securityManager.setPinEnabled(enabled);

  Future<bool> removePin() => _securityManager.removePin();

  Future<bool> setBiometricEnabled(bool enabled) =>
      _securityManager.setBiometricEnabled(enabled);

  Future<bool> loadBiometricEnabled() =>
      _securityManager.loadBiometricEnabled();

  // --- DELEGACIÓN A PRIVACY MANAGER ---
  Future<bool> savePrivacyMode(bool enabled) =>
      _privacyManager.savePrivacyMode(enabled);

  Future<bool> loadPrivacyMode() => _privacyManager.loadPrivacyMode();

  Future<bool> saveHideBalancesOnStartup(bool enabled) =>
      _privacyManager.saveHideBalancesOnStartup(enabled);

  Future<bool> loadHideBalancesOnStartup() =>
      _privacyManager.loadHideBalancesOnStartup();

  // --- DELEGACIÓN A IMPORT/EXPORT MANAGER ---
  Future<Map<String, dynamic>> exportData() => _importExportManager.exportData(
    _recordsManager,
    _categoriesManager,
    _goalsManager,
  );

  Future<String> exportToCSV() =>
      _importExportManager.exportToCSV(_recordsManager, _categoriesManager);

  Future<List<int>> exportToExcel() =>
      _importExportManager.exportToExcel(_recordsManager, _categoriesManager);

  Future<bool> importData(Map<String, dynamic> data) => _importExportManager
      .importData(data, _recordsManager, _categoriesManager, _goalsManager);

  // --- DELEGACIÓN A DATA CLEANUP MANAGER ---
  Future<bool> clearAllDataExceptDefaultUser() =>
      _dataCleanupManager.clearAllDataExceptDefaultUser();

  Future<bool> clearUserData() =>
      _dataCleanupManager.clearUserData(_recordsManager, _categoriesManager);

  Future<bool> clearAllData() => _dataCleanupManager.clearAllData();

  // --- DELEGACIÓN A GOALS MANAGER ---
  Future<List<SavingsGoal>> loadGoals({bool forceReload = false}) =>
      _goalsManager.loadGoals(forceReload: forceReload);

  Future<bool> saveGoals(List<SavingsGoal> goals) =>
      _goalsManager.saveGoals(goals);

  Future<bool> addGoal(SavingsGoal goal) => _goalsManager.addGoal(goal);

  Future<bool> updateGoal(SavingsGoal updatedGoal) =>
      _goalsManager.updateGoal(updatedGoal);

  Future<bool> deleteGoal(String id) => _goalsManager.deleteGoal(id);

  Future<bool> addMoneyToGoal(String goalId, double amount) =>
      _goalsManager.addMoneyToGoal(goalId, amount);

  Future<bool> removeMoneyFromGoal(String goalId, double amount) =>
      _goalsManager.removeMoneyFromGoal(goalId, amount);

  Future<bool> completeGoal(String goalId) =>
      _goalsManager.completeGoal(goalId);

  Future<List<SavingsGoal>> getActiveGoals() => _goalsManager.getActiveGoals();

  Future<List<SavingsGoal>> getCompletedGoals() =>
      _goalsManager.getCompletedGoals();

  Future<Map<String, dynamic>> getGoalsStatistics() =>
      _goalsManager.getGoalsStatistics();

  // --- DELEGACIÓN A RECURRING MANAGER ---
  Future<List<RecurringTransaction>> loadRecurringTemplates({
    bool forceReload = false,
  }) => _recurringManager.loadTemplates(forceReload: forceReload);

  Future<bool> saveRecurringTemplates(List<RecurringTransaction> templates) =>
      _recurringManager.saveTemplates(templates);

  Future<bool> addRecurringTemplate(RecurringTransaction template) =>
      _recurringManager.addTemplate(template);

  Future<bool> deleteRecurringTemplate(String id) =>
      _recurringManager.deleteTemplate(id);

  Future<List<RecurringTransaction>> getDueRecurringTransactions() =>
      _recurringManager.getDueTransactions();

  Future<void> markRecurringTransactionAsProcessed(String id, DateTime date) =>
      _recurringManager.markAsProcessed(id, date);

  // Para compatibilidad con otros servicios
  void setUserManager(dynamic userManager) {
    _recordsManager.setUserManager(userManager);
    _categoriesManager.setUserManager(userManager);
    _privacyManager.setUserManager(userManager);
    _dataCleanupManager.setUserManager(userManager);
    _goalsManager.setUserManager(userManager);
    _recurringManager.setUserManager(userManager);
  }

  void clearCache() {
    _recordsManager.clearCache();
    _categoriesManager.clearCache();
    _goalsManager.clearCache();
    _recurringManager.clearCache();
  }
}
