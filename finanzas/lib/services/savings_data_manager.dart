import 'dart:convert';
import 'package:finanzas/services/user_manager.dart';
import 'package:flutter/material.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import '../models/savings_record.dart';

class SavingsDataManager {
  // --- CLAVES DE PREFERENCIAS ---
  static const String _recordsKey = 'savings_records';
  static const String _categoriesKey = 'savings_categories';
  static const String _privacyModeKey = 'privacy_mode_enabled';
  static const String _categoryColorsKey = 'category_colors';

  // Claves de Seguridad (GLOBALES)
  static const String _pinKey = 'security_pin';
  static const String _pinEnabledKey = 'pin_enabled';
  static const String _biometricEnabledKey = 'biometric_enabled';

  static const List<String> _defaultCategories = [
    'General',
    'Trabajo',
    'Inversión',
    'Regalo',
    'Emergencia',
    'Freelance',
    'Bonificación'
  ];

  // Singleton
  static final SavingsDataManager _instance = SavingsDataManager._internal();
  factory SavingsDataManager() => _instance;
  SavingsDataManager._internal();

  static void init() {}

  late SharedPreferences _prefs;
  UserManager? _userManager;
  
  // Cache
  List<SavingsRecord>? _cachedRecords;
  List<String>? _cachedCategories;


  void clearCache() {
    _cachedRecords = null;
    _cachedCategories = null;
    debugPrint('Cache limpiado');
  }
  void setUserManager(UserManager userManager) {
    _userManager = userManager;
    clearCache();
    debugPrint('UserManager conectado a SavingsDataManager');
  }
  

  /// ✅ CORREGIDO: Retorna el prefijo del usuario actual
  String _getUserDataKey(String key) {
    final currentUser = _userManager?.getCurrentUser();
    if (currentUser == null) {
      debugPrint('⚠️ WARNING: No user selected in _getUserDataKey');
      return key;
    }
    final result = '${currentUser.id}_$key';
    debugPrint('📌 Key generada: $result para usuario: ${currentUser.name}');
    return result;
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint('SavingsDataManager inicializado');
  }

  // ====================================================================
  // ----------------------- METODOS DE CATEGORIAS ----------------------
  // ====================================================================

  Future<bool> addCategoryWithColor(String category, Color color) async {
    if (category.trim().isEmpty) return false;

    final categories = await loadCategories();
    final trimmedCategory = category.trim();

    if (!categories.contains(trimmedCategory)) {
      categories.add(trimmedCategory);
      await saveCategories(categories);
      await saveCategoryColor(trimmedCategory, color);
      return true;
    }

    return false;
  }

  Future<bool> addCategory(String category) async {
    if (category.trim().isEmpty) return false;

    final categories = await loadCategories();
    final trimmedCategory = category.trim();

    if (!categories.contains(trimmedCategory)) {
      categories.add(trimmedCategory);
      return await saveCategories(categories);
    }

    return false;
  }

  Future<bool> saveCategoryColor(String category, Color color) async {
    try {
      final key = _getUserDataKey(_categoryColorsKey);
      final colorsJson = _prefs.getString(key);
      Map<String, int> colorMap = {};
      
      if (colorsJson != null) {
        final decoded = json.decode(colorsJson);
        colorMap = Map<String, int>.from(decoded);
      }
      
      colorMap[category] = color.value;
      await _prefs.setString(key, json.encode(colorMap));
      return true;
    } catch (e) {
      debugPrint('❌ Error guardando color: $e');
      return false;
    }
  }

  Future<Color?> loadCategoryColor(String category) async {
    try {
      final key = _getUserDataKey(_categoryColorsKey);
      final colorsJson = _prefs.getString(key);
      
      if (colorsJson != null) {
        final colorMap = Map<String, int>.from(json.decode(colorsJson));
        if (colorMap.containsKey(category)) {
          return Color(colorMap[category]!);
        }
      }
    } catch (e) {
      debugPrint('❌ Error cargando color: $e');
    }
    return null;
  }

  Future<Map<String, Color>> loadAllCategoryColors() async {
    try {
      final key = _getUserDataKey(_categoryColorsKey);
      final colorsJson = _prefs.getString(key);
      
      if (colorsJson != null) {
        final colorMap = Map<String, int>.from(json.decode(colorsJson));
        return colorMap.map((k, v) => MapEntry(k, Color(v)));
      }
    } catch (e) {
      debugPrint('❌ Error cargando colores: $e');
    }
    return {};
  }

  // ====================================================================
  // ----------------------- MÉTODOS DE SEGURIDAD (GLOBALES) -----------
  // ====================================================================

  Future<bool> savePinData(String pin, bool biometricEnabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pinSuccess = await prefs.setString(_pinKey, pin);
      final enabledSuccess = await prefs.setBool(_pinEnabledKey, true);
      final biometricSuccess = await prefs.setBool(_biometricEnabledKey, biometricEnabled);
      return pinSuccess && enabledSuccess && biometricSuccess;
    } catch (e) {
      debugPrint('❌ Error guardando datos de seguridad: $e');
      return false;
    }
  }

  Future<bool> savePin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pinSuccess = await prefs.setString(_pinKey, pin);
      final enabledSuccess = await setPinEnabled(true);
      return pinSuccess && enabledSuccess;
    } catch (e) {
      debugPrint('❌ Error guardando PIN: $e');
      return false;
    }
  }

  Future<bool> setBiometricEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_biometricEnabledKey, enabled);
    } catch (e) {
      debugPrint('❌ Error guardando estado biométrico: $e');
      return false;
    }
  }

  Future<String?> loadPin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_pinKey);
    } catch (e) {
      debugPrint('❌ Error cargando PIN: $e');
      return null;
    }
  }
  
  Future<bool> isPinEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_pinEnabledKey) ?? false;
    } catch (e) {
      debugPrint('❌ Error verificando PIN habilitado: $e');
      return false;
    }
  }

  Future<bool> loadBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? false;
    } catch (e) {
      debugPrint('❌ Error verificando biométrica: $e');
      return false;
    }
  }

  Future<bool> setPinEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_pinEnabledKey, enabled);
    } catch (e) {
      debugPrint('❌ Error guardando estado del PIN: $e');
      return false;
    }
  }

  Future<bool> removePin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pinKey);
      await prefs.remove(_pinEnabledKey);
      await prefs.remove(_biometricEnabledKey);
      return true;
    } catch (e) {
      debugPrint('❌ Error eliminando PIN: $e');
      return false;
    }
  }

  // ====================================================================
  // ----------------------- MÉTODOS DE DATOS ---------------------------
  // ====================================================================

  /// ✅ CORREGIDO: Usa 'key' en lugar de '_recordsKey'
  Future<List<SavingsRecord>> loadRecords({bool forceReload = false}) async {
    if (_cachedRecords != null && !forceReload) {
      return List.from(_cachedRecords!);
    }

    try {
      final key = _getUserDataKey(_recordsKey);
      final String? recordsJson = _prefs.getString(key); // ✅ CORREGIDO
      
      if (recordsJson != null) {
        final List<dynamic> recordsList = json.decode(recordsJson);
        _cachedRecords = recordsList
            .map((json) => SavingsRecord.fromJson(json))
            .toList();
        
        _cachedRecords!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        debugPrint('✅ Se cargaron ${_cachedRecords!.length} registros');
        
        return List.from(_cachedRecords!);
      }
    } catch (e) {
      debugPrint('❌ Error cargando registros: $e');
    }
    
    _cachedRecords = [];
    return [];
  }

  /// ✅ CORREGIDO: Usa 'key' en lugar de '_recordsKey'
  Future<bool> saveRecords(List<SavingsRecord> records) async {
    try {
      final key = _getUserDataKey(_recordsKey);
      final String recordsJson = json.encode(
        records.map((record) => record.toJson()).toList()
      );
      
      final success = await _prefs.setString(key, recordsJson); // ✅ CORREGIDO
      
      if (success) {
        _cachedRecords = List.from(records);
        debugPrint('✅ ${records.length} registros guardados exitosamente en $key');
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ Error guardando registros: $e');
      return false;
    }
  }

  Future<bool> addRecord(SavingsRecord record) async {
    final records = await loadRecords();
    records.insert(0, record);
    return await saveRecords(records);
  }

  Future<bool> updateRecord(SavingsRecord updatedRecord) async {
    final records = await loadRecords();
    final index = records.indexWhere((r) => r.id == updatedRecord.id);
    
    if (index != -1) {
      records[index] = updatedRecord;
      return await saveRecords(records);
    }
    
    debugPrint('❌ Registro con id ${updatedRecord.id} no encontrado');
    return false;
  }

  Future<bool> deleteRecord(String id) async {
    final records = await loadRecords();
    final initialLength = records.length;
    records.removeWhere((record) => record.id == id);
    
    if (records.length < initialLength) {
      return await saveRecords(records);
    }
    
    debugPrint('❌ Registro con id $id no encontrado');
    return false;
  }

  Future<List<SavingsRecord>> searchRecords({
    String? query,
    RecordType? type,
    String? category,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final allRecords = await loadRecords();
    
    return allRecords.where((record) {
      bool matchesQuery = query == null || 
          record.description.toLowerCase().contains(query.toLowerCase()) ||
          record.category.toLowerCase().contains(query.toLowerCase()) ||
          (record.notes?.toLowerCase().contains(query.toLowerCase()) ?? false);
      
      bool matchesType = type == null || record.type == type;
      
      bool matchesCategory = category == null || 
          category == 'all' || 
          record.category == category;
      
      bool matchesDateRange = true;
      if (fromDate != null) {
        matchesDateRange = record.createdAt.isAfter(fromDate) ||
            record.createdAt.isAtSameMomentAs(fromDate);
      }
      if (toDate != null && matchesDateRange) {
        matchesDateRange = record.createdAt.isBefore(toDate.add(const Duration(days: 1)));
      }
      
      return matchesQuery && matchesType && matchesCategory && matchesDateRange;
    }).toList();
  }

  /// ✅ CORREGIDO: Usa 'key' en lugar de '_categoriesKey'
  Future<List<String>> loadCategories({bool forceReload = false}) async {
    if (_cachedCategories != null && !forceReload) {
      return List.from(_cachedCategories!);
    }

    try {
      final key = _getUserDataKey(_categoriesKey);
      final categories = _prefs.getStringList(key); // ✅ CORREGIDO
      
      _cachedCategories = categories ?? List.from(_defaultCategories);
      return List.from(_cachedCategories!);
    } catch (e) {
      debugPrint('❌ Error cargando categorías: $e');
      _cachedCategories = List.from(_defaultCategories);
      return List.from(_cachedCategories!);
    }
  }

  /// ✅ CORREGIDO: Usa 'key' en lugar de '_categoriesKey'
  Future<bool> saveCategories(List<String> categories) async {
    try {
      final key = _getUserDataKey(_categoriesKey);
      final success = await _prefs.setStringList(key, categories); // ✅ CORREGIDO
      
      if (success) {
        _cachedCategories = List.from(categories);
        debugPrint('✅ ${categories.length} categorías guardadas exitosamente en $key');
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ Error guardando categorías: $e');
      return false;
    }
  }

  Future<bool> deleteCategory(String category) async {
    try {
      final records = await loadRecords();
      
      final updatedRecords = records.map((record) {
        if (record.category == category) {
          return record.copyWith(category: 'General');
        }
        return record;
      }).toList();
      
      await saveRecords(updatedRecords);
      
      final categories = await loadCategories();
      if (categories.contains(category) && category != 'General') {
        categories.remove(category);
        await saveCategories(categories);
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Error eliminando categoría: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final records = await loadRecords();
    
    if (records.isEmpty) {
      return {
        'totalRecords': 0,
        'totalDeposits': 0,
        'totalWithdrawals': 0,
        'totalPhysical': 0.0,
        'totalDigital': 0.0,
        'totalAmount': 0.0,
        'categoryTotals': <String, double>{},
      };
    }

    final deposits = records.where((r) => r.type == RecordType.deposit).toList();
    final withdrawals = records.where((r) => r.type == RecordType.withdrawal).toList();

    double totalPhysical = 0;
    double totalDigital = 0;
    Map<String, double> categoryTotals = {};

    for (final record in records) {
      final multiplier = record.type == RecordType.deposit ? 1.0 : -1.0;
      
      totalPhysical += record.physicalAmount * multiplier;
      totalDigital += record.digitalAmount * multiplier;
      
      categoryTotals[record.category] = 
          (categoryTotals[record.category] ?? 0) + (record.totalAmount * multiplier);
    }

    return {
      'totalRecords': records.length,
      'totalDeposits': deposits.length,
      'totalWithdrawals': withdrawals.length,
      'totalPhysical': totalPhysical,
      'totalDigital': totalDigital,
      'totalAmount': totalPhysical + totalDigital,
      'categoryTotals': categoryTotals,
    };
  }

  Future<Map<String, dynamic>> exportData() async {
    final records = await loadRecords();
    final categories = await loadCategories();
    
    return {
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0',
      'records': records.map((r) => r.toJson()).toList(),
      'categories': categories,
    };
  }

  Future<bool> importData(Map<String, dynamic> data) async {
    try {
      if (data['records'] != null) {
        final List<SavingsRecord> importedRecords = (data['records'] as List)
            .map((json) => SavingsRecord.fromJson(json))
            .toList();
        
        await saveRecords(importedRecords);
      }
      
      if (data['categories'] != null) {
        final List<String> importedCategories = 
            List<String>.from(data['categories']);
        await saveCategories(importedCategories);
      }
      
      debugPrint('✅ Datos importados exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ Error importando datos: $e');
      return false;
    }
  }

  Future<bool> clearUserData() async {
    try {
      final currentUser = _userManager?.getCurrentUser();
      if (currentUser == null) return false;

      final key1 = _getUserDataKey(_recordsKey);
      final key2 = _getUserDataKey(_categoriesKey);
      final key3 = _getUserDataKey(_categoryColorsKey);

      await _prefs.remove(key1);
      await _prefs.remove(key2);
      await _prefs.remove(key3);
      
      _cachedRecords = null;
      _cachedCategories = null;
      
      debugPrint('✅ Datos del usuario eliminados');
      return true;
    } catch (e) {
      debugPrint('❌ Error eliminando datos del usuario: $e');
      return false;
    }
  }

  Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      _cachedRecords = null;
      _cachedCategories = null;
      
      debugPrint('✅ Todos los datos eliminados');
      return true;
    } catch (e) {
      debugPrint('❌ Error eliminando datos: $e');
      return false;
    }
  }

  /// ✅ CORREGIDO: Usa 'key' en lugar de '_privacyModeKey'
  Future<bool> savePrivacyMode(bool enabled) async {
    try {
      final key = _getUserDataKey(_privacyModeKey);
      return await _prefs.setBool(key, enabled); // ✅ CORREGIDO
    } catch (e) {
      debugPrint('❌ Error guardando modo privacidad: $e');
      return false;
    }
  }

  /// ✅ CORREGIDO: Usa 'key' en lugar de '_privacyModeKey'
  Future<bool> loadPrivacyMode() async {
    try {
      final key = _getUserDataKey(_privacyModeKey);
      return _prefs.getBool(key) ?? false; // ✅ CORREGIDO
    } catch (e) {
      debugPrint('❌ Error cargando modo privacidad: $e');
      return false;
    }
  }
}