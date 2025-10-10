import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesManager {
  final SharedPreferences _prefs;
  List<String>? _cachedCategories;
  dynamic _userManager;

  static const String _categoriesKey = 'savings_categories';
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

  CategoriesManager(this._prefs);

  void setUserManager(dynamic userManager) {
    _userManager = userManager;
    clearCache();
  }

  void clearCache() {
    _cachedCategories = null;
    debugPrint('Cache de categorías limpiado');
  }

  String _getUserDataKey(String key) {
    final currentUser = _userManager?.getCurrentUserSync();
    if (currentUser == null) {
      return key;
    }
    return '${currentUser.id}_$key';
  }

  Future<List<String>> loadCategories({bool forceReload = false}) async {
    if (_cachedCategories != null && !forceReload) {
      return List.from(_cachedCategories!);
    }

    try {
      final key = _getUserDataKey(_categoriesKey);
      final categories = _prefs.getStringList(key);

      _cachedCategories = categories ?? List.from(_defaultCategories);
      return List.from(_cachedCategories!);
    } catch (e) {
      debugPrint('❌ Error cargando categorías: $e');
      _cachedCategories = List.from(_defaultCategories);
      return List.from(_cachedCategories!);
    }
  }

  Future<bool> saveCategories(List<String> categories) async {
    try {
      final key = _getUserDataKey(_categoriesKey);
      final success = await _prefs.setStringList(key, categories);

      if (success) {
        _cachedCategories = List.from(categories);
        debugPrint('✅ ${categories.length} categorías guardadas');
      }

      return success;
    } catch (e) {
      debugPrint('❌ Error guardando categorías: $e');
      return false;
    }
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

  Future<bool> deleteCategory(String category) async {
    try {
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
}