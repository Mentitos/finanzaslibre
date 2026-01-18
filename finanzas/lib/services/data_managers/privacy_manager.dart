import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyManager {
  final SharedPreferences _prefs;
  dynamic _userManager;

  static const String _privacyModeKey = 'privacy_mode_enabled';

  PrivacyManager(this._prefs);

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

  Future<bool> savePrivacyMode(bool enabled) async {
    try {
      final key = _getUserDataKey(_privacyModeKey);
      return await _prefs.setBool(key, enabled);
    } catch (e) {
      debugPrint('❌ Error guardando privacidad: $e');
      return false;
    }
  }

  Future<bool> loadPrivacyMode() async {
    try {
      final key = _getUserDataKey(_privacyModeKey);
      return _prefs.getBool(key) ?? false;
    } catch (e) {
      debugPrint('❌ Error cargando privacidad: $e');
      return false;
    }
  }

  Future<bool> saveHideBalancesOnStartup(bool enabled) async {
    try {
      final key = _getUserDataKey('hide_balances_on_startup');
      return await _prefs.setBool(key, enabled);
    } catch (e) {
      debugPrint('❌ Error guardando configuración de inicio: $e');
      return false;
    }
  }

  Future<bool> loadHideBalancesOnStartup() async {
    try {
      final key = _getUserDataKey('hide_balances_on_startup');
      return _prefs.getBool(key) ?? false;
    } catch (e) {
      debugPrint('❌ Error cargando configuración de inicio: $e');
      return false;
    }
  }
}
