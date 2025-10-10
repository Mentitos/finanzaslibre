import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/savings_record.dart';
import 'records_manager.dart';
import 'categories_manager.dart';

class ImportExportManager {
  final SharedPreferences _prefs;

  ImportExportManager(this._prefs);

  Future<Map<String, dynamic>> exportData(
    RecordsManager recordsManager,
    CategoriesManager categoriesManager,
  ) async {
    final records = await recordsManager.loadRecords();
    final categories = await categoriesManager.loadCategories();

    return {
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0',
      'records': records.map((r) => r.toJson()).toList(),
      'categories': categories,
    };
  }

  Future<bool> importData(
    Map<String, dynamic> data,
    RecordsManager recordsManager,
    CategoriesManager categoriesManager,
  ) async {
    try {
      if (data['records'] != null) {
        final List<SavingsRecord> importedRecords = (data['records'] as List)
            .map((json) => SavingsRecord.fromJson(json))
            .toList();

        await recordsManager.saveRecords(importedRecords);
      }

      if (data['categories'] != null) {
        final List<String> importedCategories =
            List<String>.from(data['categories']);
        await categoriesManager.saveCategories(importedCategories);
      }

      debugPrint('✅ Datos importados');
      return true;
    } catch (e) {
      debugPrint('❌ Error importando: $e');
      return false;
    }
  }
}