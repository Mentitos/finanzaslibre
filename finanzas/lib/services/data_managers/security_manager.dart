import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityManager {
  final SharedPreferences _prefs;

  static const String _pinKey = 'security_pin';
  static const String _pinEnabledKey = 'pin_enabled';
  static const String _biometricEnabledKey = 'biometric_enabled';

  SecurityManager(this._prefs);

  Future<bool> savePinData(String pin, bool biometricEnabled) async {
    try {
      final pinSuccess = await _prefs.setString(_pinKey, pin);
      final enabledSuccess = await _prefs.setBool(_pinEnabledKey, true);
      final biometricSuccess =
          await _prefs.setBool(_biometricEnabledKey, biometricEnabled);
      return pinSuccess && enabledSuccess && biometricSuccess;
    } catch (e) {
      debugPrint('❌ Error guardando seguridad: $e');
      return false;
    }
  }

  Future<bool> savePin(String pin) async {
    try {
      final pinSuccess = await _prefs.setString(_pinKey, pin);
      final enabledSuccess = await setPinEnabled(true);
      return pinSuccess && enabledSuccess;
    } catch (e) {
      debugPrint('❌ Error guardando PIN: $e');
      return false;
    }
  }

  Future<String?> loadPin() async {
    try {
      return _prefs.getString(_pinKey);
    } catch (e) {
      debugPrint('❌ Error cargando PIN: $e');
      return null;
    }
  }

  Future<bool> isPinEnabled() async {
    try {
      return _prefs.getBool(_pinEnabledKey) ?? false;
    } catch (e) {
      debugPrint('❌ Error verificando PIN: $e');
      return false;
    }
  }

  Future<bool> setPinEnabled(bool enabled) async {
    try {
      return await _prefs.setBool(_pinEnabledKey, enabled);
    } catch (e) {
      debugPrint('❌ Error: $e');
      return false;
    }
  }

  Future<bool> removePin() async {
    try {
      await _prefs.remove(_pinKey);
      await _prefs.remove(_pinEnabledKey);
      await _prefs.remove(_biometricEnabledKey);
      return true;
    } catch (e) {
      debugPrint('❌ Error removiendo PIN: $e');
      return false;
    }
  }

  Future<bool> setBiometricEnabled(bool enabled) async {
    try {
      return await _prefs.setBool(_biometricEnabledKey, enabled);
    } catch (e) {
      debugPrint('❌ Error: $e');
      return false;
    }
  }

  Future<bool> loadBiometricEnabled() async {
    try {
      return _prefs.getBool(_biometricEnabledKey) ?? false;
    } catch (e) {
      debugPrint('❌ Error: $e');
      return false;
    }
  }
}