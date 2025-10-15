import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/savings_record.dart';
import 'data_managers/records_manager.dart';
import 'data_managers/categories_manager.dart';
import 'data_managers/security_manager.dart';
import 'data_managers/privacy_manager.dart';
import 'data_managers/import_export_manager.dart';
import 'data_managers/data_cleanup_manager.dart';

class SavingsDataManager {
  static final SavingsDataManager _instance = SavingsDataManager._internal();
  
  factory SavingsDataManager() => _instance;
  SavingsDataManager._internal();

  static void init() {}

  late SharedPreferences _prefs;

  
  late RecordsManager _recordsManager;
  late CategoriesManager _categoriesManager;
  late SecurityManager _securityManager;
  late PrivacyManager _privacyManager;
  late ImportExportManager _importExportManager;
  late DataCleanupManager _dataCleanupManager;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    
    _recordsManager = RecordsManager(_prefs);
    _categoriesManager = CategoriesManager(_prefs);
    _securityManager = SecurityManager(_prefs);
    _privacyManager = PrivacyManager(_prefs);
    _importExportManager = ImportExportManager();
    _dataCleanupManager = DataCleanupManager(_prefs);
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

  Future<bool> deleteRecord(String id) =>
      _recordsManager.deleteRecord(id);

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

  Future<bool> deleteCategory(String category) =>
      _categoriesManager.deleteCategory(category);

  Future<bool> saveCategoryColor(String category, Color color) =>
      _categoriesManager.saveCategoryColor(category, color);

  Future<Color?> loadCategoryColor(String category) =>
      _categoriesManager.loadCategoryColor(category);

  Future<Map<String, Color>> loadAllCategoryColors() =>
      _categoriesManager.loadAllCategoryColors();

  // --- DELEGACIÓN A SECURITY MANAGER ---
  Future<bool> savePinData(String pin, bool biometricEnabled) =>
      _securityManager.savePinData(pin, biometricEnabled);

  Future<bool> savePin(String pin) =>
      _securityManager.savePin(pin);

  Future<String?> loadPin() =>
      _securityManager.loadPin();

  Future<bool> isPinEnabled() =>
      _securityManager.isPinEnabled();

  Future<bool> setPinEnabled(bool enabled) =>
      _securityManager.setPinEnabled(enabled);

  Future<bool> removePin() =>
      _securityManager.removePin();

  Future<bool> setBiometricEnabled(bool enabled) =>
      _securityManager.setBiometricEnabled(enabled);

  Future<bool> loadBiometricEnabled() =>
      _securityManager.loadBiometricEnabled();

  // --- DELEGACIÓN A PRIVACY MANAGER ---
  Future<bool> savePrivacyMode(bool enabled) =>
      _privacyManager.savePrivacyMode(enabled);

  Future<bool> loadPrivacyMode() =>
      _privacyManager.loadPrivacyMode();

 // --- DELEGACIÓN A IMPORT/EXPORT MANAGER ---
Future<Map<String, dynamic>> exportData() =>
    _importExportManager.exportData(_recordsManager, _categoriesManager);

Future<String> exportToCSV() =>
    _importExportManager.exportToCSV(_recordsManager, _categoriesManager);

Future<List<int>> exportToExcel() =>
    _importExportManager.exportToExcel(_recordsManager, _categoriesManager);

Future<bool> importData(Map<String, dynamic> data) =>
    _importExportManager.importData(data, _recordsManager, _categoriesManager);

  // --- DELEGACIÓN A DATA CLEANUP MANAGER ---
  Future<bool> clearAllDataExceptDefaultUser() =>
      _dataCleanupManager.clearAllDataExceptDefaultUser();

  Future<bool> clearUserData() =>
      _dataCleanupManager.clearUserData(_recordsManager, _categoriesManager);

  Future<bool> clearAllData() =>
      _dataCleanupManager.clearAllData();

  // Para compatibilidad con otros servicios
  void setUserManager(dynamic userManager) {
    _recordsManager.setUserManager(userManager);
    _categoriesManager.setUserManager(userManager);
    _privacyManager.setUserManager(userManager);
    _dataCleanupManager.setUserManager(userManager);
  }

  void clearCache() {
    _recordsManager.clearCache();
    _categoriesManager.clearCache();
  }
}