import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_manager.dart';
import 'records_manager.dart';
import 'categories_manager.dart';

class DataCleanupManager {
  final SharedPreferences _prefs;
  dynamic _userManager;

  static const String _pinKey = 'security_pin';
  static const String _pinEnabledKey = 'pin_enabled';
  static const String _biometricEnabledKey = 'biometric_enabled';

  DataCleanupManager(this._prefs);

  void setUserManager(dynamic userManager) {
    _userManager = userManager;
  }

  String _getUserDataKey(String key) {
    final currentUser = _userManager?.getCurrentUserSync();
    if (currentUser == null) {
      return key;
    }
    return '${currentUser.id}_$key';
  }

  Future<bool> clearAllDataExceptDefaultUser() async {
    try {
      final defaultUserId = UserManager.getDefaultUserId();
      final allKeys = _prefs.getKeys().toList();

      debugPrint('🔍 Manteniendo billetera principal...');

      for (final key in allKeys) {
        if (key == _pinKey ||
            key == _pinEnabledKey ||
            key == _biometricEnabledKey) {
          continue;
        }

        if (key == 'current_user_id' || key == 'users_list') {
          continue;
        }

        if (key.contains(defaultUserId)) {
          continue;
        }

        debugPrint('  ✗ Eliminando: $key');
        await _prefs.remove(key);
      }

      debugPrint('✅ Limpieza completada');
      return true;
    } catch (e) {
      debugPrint('❌ Error: $e');
      return false;
    }
  }

  Future<bool> clearUserData(
    RecordsManager recordsManager,
    CategoriesManager categoriesManager,
  ) async {
    try {
      final currentUser = _userManager?.getCurrentUserSync();
      if (currentUser == null) return false;

      final recordsKey = _getUserDataKey('savings_records');
      final categoriesKey = _getUserDataKey('savings_categories');
      final colorsKey = _getUserDataKey('category_colors');

      await _prefs.remove(recordsKey);
      await _prefs.remove(categoriesKey);
      await _prefs.remove(colorsKey);

      recordsManager.clearCache();
      categoriesManager.clearCache();

      debugPrint('✅ Datos del usuario eliminados');
      return true;
    } catch (e) {
      debugPrint('❌ Error: $e');
      return false;
    }
  }

  Future<bool> clearAllData() async {
    try {
      final allKeys = _prefs.getKeys().toList();

      debugPrint('🔍 Reset total...');

      for (final key in allKeys) {
        if (key == _pinKey ||
            key == _pinEnabledKey ||
            key == _biometricEnabledKey) {
          continue;
        }

        if (key == 'current_user_id' || key == 'users_list') {
          continue;
        }

        debugPrint('  ✗ Eliminando: $key');
        await _prefs.remove(key);
      }

      debugPrint('✅ Reset total completado');
      return true;
    } catch (e) {
      debugPrint('❌ Error: $e');
      return false;
    }
  }
}