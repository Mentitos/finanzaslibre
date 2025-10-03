import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Necesario para Color
import 'package:shared_preferences/shared_preferences.dart';
import '../models/savings_record.dart';
import 'dart:ui'; // Para Color

class SavingsDataManager {
  // --- CLAVES DE PREFERENCIAS ---
  static const String _recordsKey = 'savings_records';
  static const String _categoriesKey = 'savings_categories';
  static const String _privacyModeKey = 'privacy_mode_enabled';

  // Claves de Seguridad
  static const String _pinKey = 'security_pin';
  static const String _pinEnabledKey = 'pin_enabled';
  static const String _biometricEnabledKey = 'biometric_enabled';

  // Nueva clave para colores de categorías
  static const String _categoryColorsKey = 'category_colors';

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

  // Cache
  List<SavingsRecord>? _cachedRecords;
  List<String>? _cachedCategories;

  // ====================================================================
  // ----------------------- METODOS DE CATEGORIAS ----------------------
  // ====================================================================

  /// Agrega una nueva categoría (con color)
  Future<bool> addCategoryWithColor(String category, Color color) async {
    if (category.trim().isEmpty) return false;

    final categories = await loadCategories();
    final trimmedCategory = category.trim();

    if (!categories.contains(trimmedCategory)) {
      categories.add(trimmedCategory);
      await saveCategories(categories);

      // Guardar color asociado
      await saveCategoryColor(trimmedCategory, color);
      return true;
    }

    return false;
  }

  /// Agrega una nueva categoría sin color (compatibilidad con código existente)
  Future<bool> addCategory(String category) async {
    if (category.trim().isEmpty) return false;

    final categories = await loadCategories();
    final trimmedCategory = category.trim();

    if (!categories.contains(trimmedCategory)) {
      categories.add(trimmedCategory);
      return await saveCategories(categories);
    }

    return false; // Ya existe
  }

  /// Guarda el color de una categoría
  Future<bool> saveCategoryColor(String category, Color color) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final colorsJson = prefs.getString(_categoryColorsKey);
    Map<String, int> colorMap = {};
    
    if (colorsJson != null) {
      final decoded = json.decode(colorsJson);
      colorMap = Map<String, int>.from(decoded);
    }
    
    colorMap[category] = color.value;
    await prefs.setString(_categoryColorsKey, json.encode(colorMap));
    return true;
  } catch (e) {
    debugPrint('Error guardando color: $e');
    return false;
  }
}

  /// Carga el color de una categoría
  Future<Color?> loadCategoryColor(String category) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final colorsJson = prefs.getString(_categoryColorsKey);
    
    if (colorsJson != null) {
      final colorMap = Map<String, int>.from(json.decode(colorsJson));
      if (colorMap.containsKey(category)) {
        return Color(colorMap[category]!);
      }
    }
  } catch (e) {
    debugPrint('Error cargando color: $e');
  }
  return null;
}

  /// Carga todos los colores de categorías
  Future<Map<String, Color>> loadAllCategoryColors() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final colorsJson = prefs.getString(_categoryColorsKey);
    
    if (colorsJson != null) {
      final colorMap = Map<String, int>.from(json.decode(colorsJson));
      return colorMap.map((key, value) => MapEntry(key, Color(value)));
    }
  } catch (e) {
    debugPrint('Error cargando colores: $e');
  }
  return {};
}
  // ====================================================================
  // ------------------------- MÉTODOS DE SEGURIDAD ---------------------
  // ====================================================================

  /// Guarda el PIN, habilita la protección por PIN y guarda el estado biométrico.
  /// **Esta es la función a usar después de la PinSetupScreen.**
  Future<bool> savePinData(String pin, bool biometricEnabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pinSuccess = await prefs.setString(_pinKey, pin);
      final enabledSuccess = await prefs.setBool(_pinEnabledKey, true);
      final biometricSuccess = await prefs.setBool(_biometricEnabledKey, biometricEnabled);
      return pinSuccess && enabledSuccess && biometricSuccess;
    } catch (e) {
      debugPrint('Error guardando datos de seguridad: $e');
      return false;
    }
  }

  /// Guarda el PIN de seguridad (Reintroducido para compatibilidad)
  /// Esto también habilita la protección por PIN.
  Future<bool> savePin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pinSuccess = await prefs.setString(_pinKey, pin);
      final enabledSuccess = await setPinEnabled(true); // Asegura que esté habilitado
      return pinSuccess && enabledSuccess;
    } catch (e) {
      debugPrint('Error guardando PIN: $e');
      return false;
    }
  }

  /// Guarda solo el estado de autenticación biométrica (útil si el PIN ya existe)
  Future<bool> setBiometricEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_biometricEnabledKey, enabled);
    } catch (e) {
      debugPrint('Error guardando estado biométrico: $e');
      return false;
    }
  }

  /// Carga el PIN guardado
  Future<String?> loadPin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_pinKey);
    } catch (e) {
      debugPrint('Error cargando PIN: $e');
      return null;
    }
  }
  
  /// Verifica si el PIN está habilitado
  Future<bool> isPinEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_pinEnabledKey) ?? false;
    } catch (e) {
      debugPrint('Error verificando PIN habilitado: $e');
      return false;
    }
  }

  /// Verifica si la autenticación biométrica está habilitada
  /// **Renombrado de isBiometricEnabled para compatibilidad con main.dart**
  Future<bool> loadBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? false;
    } catch (e) {
      debugPrint('Error verificando biométrica: $e');
      return false;
    }
  }

  /// Habilita o deshabilita la protección por PIN (sin cambiar el PIN)
  Future<bool> setPinEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_pinEnabledKey, enabled);
    } catch (e) {
      debugPrint('Error guardando estado del PIN: $e');
      return false;
    }
  }

  /// Elimina el PIN de seguridad y deshabilita la protección
  Future<bool> removePin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pinKey);
      await prefs.remove(_pinEnabledKey);
      await prefs.remove(_biometricEnabledKey); // También quitamos biometría
      return true;
    } catch (e) {
      debugPrint('Error eliminando PIN: $e');
      return false;
    }
  }

  // ====================================================================
  // ------------------------- MÉTODOS DE DATOS -------------------------
  // ====================================================================

  /// Carga todos los registros de ahorros
  Future<List<SavingsRecord>> loadRecords({bool forceReload = false}) async {
    if (_cachedRecords != null && !forceReload) {
      return List.from(_cachedRecords!);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? recordsJson = prefs.getString(_recordsKey);
      
      if (recordsJson != null) {
        final List<dynamic> recordsList = json.decode(recordsJson);
        _cachedRecords = recordsList
            .map((json) => SavingsRecord.fromJson(json))
            .toList();
        
        // Ordenar por fecha de creación (más reciente primero)
        _cachedRecords!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        return List.from(_cachedRecords!);
      }
    } catch (e) {
      debugPrint('Error cargando registros: $e');
    }
    
    _cachedRecords = [];
    return [];
  }

  /// Guarda la lista completa de registros
  Future<bool> saveRecords(List<SavingsRecord> records) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String recordsJson = json.encode(
        records.map((record) => record.toJson()).toList()
      );
      
      final success = await prefs.setString(_recordsKey, recordsJson);
      
      if (success) {
        _cachedRecords = List.from(records);
        debugPrint('${records.length} registros guardados exitosamente');
      }
      
      return success;
    } catch (e) {
      debugPrint('Error guardando registros: $e');
      return false;
    }
  }

  /// Agrega un nuevo registro
  Future<bool> addRecord(SavingsRecord record) async {
    final records = await loadRecords();
    records.insert(0, record);
    return await saveRecords(records);
  }

  /// Actualiza un registro existente
  Future<bool> updateRecord(SavingsRecord updatedRecord) async {
    final records = await loadRecords();
    final index = records.indexWhere((r) => r.id == updatedRecord.id);
    
    if (index != -1) {
      records[index] = updatedRecord;
      return await saveRecords(records);
    }
    
    debugPrint('Registro con id ${updatedRecord.id} no encontrado');
    return false;
  }

  /// Elimina un registro por ID
  Future<bool> deleteRecord(String id) async {
    final records = await loadRecords();
    final initialLength = records.length;
    records.removeWhere((record) => record.id == id);
    
    if (records.length < initialLength) {
      return await saveRecords(records);
    }
    
    debugPrint('Registro con id $id no encontrado');
    return false;
  }

  /// Busca registros por criterios
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

  /// Carga las categorías disponibles
  Future<List<String>> loadCategories({bool forceReload = false}) async {
    if (_cachedCategories != null && !forceReload) {
      return List.from(_cachedCategories!);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final categories = prefs.getStringList(_categoriesKey);
      
      _cachedCategories = categories ?? List.from(_defaultCategories);
      return List.from(_cachedCategories!);
    } catch (e) {
      debugPrint('Error cargando categorías: $e');
      _cachedCategories = List.from(_defaultCategories);
      return List.from(_cachedCategories!);
    }
  }

  /// Guarda las categorías
  Future<bool> saveCategories(List<String> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setStringList(_categoriesKey, categories);
      
      if (success) {
        _cachedCategories = List.from(categories);
        debugPrint('${categories.length} categorías guardadas exitosamente');
      }
      
      return success;
    } catch (e) {
      debugPrint('Error guardando categorías: $e');
      return false;
    }
  }

  /// Agrega una nueva categoría
  

  /// Elimina una categoría y mueve sus registros a "General"
  Future<bool> deleteCategory(String category) async {
    try {
      // Cargar registros actuales
      final records = await loadRecords();
      
      // Mover todos los registros a "General"
      final updatedRecords = records.map((record) {
        if (record.category == category) {
          return record.copyWith(category: 'General');
        }
        return record;
      }).toList();
      
      await saveRecords(updatedRecords);
      
      // Eliminar la categoría de la lista
      final categories = await loadCategories();
      if (categories.contains(category) && category != 'General') {
        categories.remove(category);
        await saveCategories(categories);
        return true;
      }
      
      return false; // No se eliminó (era General o no existía)
    } catch (e) {
      debugPrint('Error eliminando categoría: $e');
      return false;
    }
  }

  /// Obtiene estadísticas básicas
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

  /// Exporta los datos a JSON (para backup)
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

  /// Importa datos desde JSON
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
      
      debugPrint('Datos importados exitosamente');
      return true;
    } catch (e) {
      debugPrint('Error importando datos: $e');
      return false;
    }
  }

  /// Limpia todos los datos (para testing o reset)
  Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recordsKey);
      await prefs.remove(_categoriesKey);
      // Limpiar también las claves de seguridad
      await prefs.remove(_pinKey);
      await prefs.remove(_pinEnabledKey);
      await prefs.remove(_biometricEnabledKey);
      
      _cachedRecords = null;
      _cachedCategories = null;
      
      debugPrint('Todos los datos eliminados');
      return true;
    } catch (e) {
      debugPrint('Error eliminando datos: $e');
      return false;
    }
  }

  /// Guarda el estado del modo privacidad
  Future<bool> savePrivacyMode(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_privacyModeKey, enabled);
    } catch (e) {
      debugPrint('Error guardando modo privacidad: $e');
      return false;
    }
  }

  /// Carga el estado del modo privacidad
  Future<bool> loadPrivacyMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_privacyModeKey) ?? false;
    } catch (e) {
      debugPrint('Error cargando modo privacidad: $e');
      return false;
    }
  }
}
