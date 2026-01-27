import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/recurring_transaction.dart';

class RecurringManager {
  final SharedPreferences _prefs;
  List<RecurringTransaction>? _cachedTemplates;
  dynamic _userManager;

  static const String _templatesKey = 'recurring_templates';

  RecurringManager(this._prefs);

  void setUserManager(dynamic userManager) {
    _userManager = userManager;
    clearCache();
  }

  void clearCache() {
    _cachedTemplates = null;
  }

  String _getUserDataKey(String key) {
    final currentUser = _userManager?.getCurrentUserSync();
    if (currentUser == null) {
      return key;
    }
    return '${currentUser.id}_$key';
  }

  Future<List<RecurringTransaction>> loadTemplates({
    bool forceReload = false,
  }) async {
    if (_cachedTemplates != null && !forceReload) {
      return List.from(_cachedTemplates!);
    }

    try {
      final key = _getUserDataKey(_templatesKey);
      final String? jsonString = _prefs.getString(key);

      if (jsonString != null) {
        final List<dynamic> list = json.decode(jsonString);
        _cachedTemplates = list
            .map((json) => RecurringTransaction.fromJson(json))
            .toList();
        return List.from(_cachedTemplates!);
      }
    } catch (e) {
      debugPrint('❌ Error loading recurring templates: $e');
    }

    _cachedTemplates = [];
    return [];
  }

  Future<bool> saveTemplates(List<RecurringTransaction> templates) async {
    try {
      final key = _getUserDataKey(_templatesKey);
      final String jsonString = json.encode(
        templates.map((t) => t.toJson()).toList(),
      );

      final success = await _prefs.setString(key, jsonString);
      if (success) {
        _cachedTemplates = List.from(templates);
      }
      return success;
    } catch (e) {
      debugPrint('❌ Error saving recurring templates: $e');
      return false;
    }
  }

  Future<bool> addTemplate(RecurringTransaction template) async {
    final templates = await loadTemplates();
    templates.add(template);
    return await saveTemplates(templates);
  }

  Future<bool> deleteTemplate(String id) async {
    final templates = await loadTemplates();
    final initialLength = templates.length;
    templates.removeWhere((t) => t.id == id);

    if (templates.length < initialLength) {
      return await saveTemplates(templates);
    }
    return false;
  }

  // New Methods for Automation
  Future<List<RecurringTransaction>> getDueTransactions() async {
    final templates = await loadTemplates(forceReload: true);
    return templates.where((t) => t.isDue()).toList();
  }

  Future<void> markAsProcessed(String id, DateTime date) async {
    final templates = await loadTemplates();
    final index = templates.indexWhere((t) => t.id == id);
    if (index != -1) {
      templates[index].lastProcessedDate = date;
      await saveTemplates(templates);
    }
  }
}
