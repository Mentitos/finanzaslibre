import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/savings_record.dart';

class RecordsManager {
  final SharedPreferences _prefs;
  List<SavingsRecord>? _cachedRecords;
  dynamic _userManager;

  static const String _recordsKey = 'savings_records';

  RecordsManager(this._prefs);

  void setUserManager(dynamic userManager) {
    _userManager = userManager;
    clearCache();
  }

  void clearCache() {
    _cachedRecords = null;
    debugPrint('Cache de registros limpiado');
  }

  String _getUserDataKey(String key) {
    final currentUser = _userManager?.getCurrentUserSync();
    if (currentUser == null) {
      debugPrint('⚠️ WARNING: No user selected');
      return key;
    }
    return '${currentUser.id}_$key';
  }

  Future<List<SavingsRecord>> loadRecords({bool forceReload = false}) async {
    if (_cachedRecords != null && !forceReload) {
      return List.from(_cachedRecords!);
    }

    try {
      final key = _getUserDataKey(_recordsKey);
      final String? recordsJson = _prefs.getString(key);

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

  Future<bool> saveRecords(List<SavingsRecord> records) async {
    try {
      final key = _getUserDataKey(_recordsKey);
      final String recordsJson = json.encode(
        records.map((record) => record.toJson()).toList(),
      );

      final success = await _prefs.setString(key, recordsJson);

      if (success) {
        _cachedRecords = List.from(records);
        debugPrint('✅ ${records.length} registros guardados');
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

    return false;
  }

  Future<bool> deleteRecord(String id) async {
    final records = await loadRecords();
    final initialLength = records.length;
    records.removeWhere((record) => record.id == id);

    if (records.length < initialLength) {
      return await saveRecords(records);
    }

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

      bool matchesCategory =
          category == null || category == 'all' || record.category == category;

      bool matchesDateRange = true;
      if (fromDate != null) {
        matchesDateRange = record.createdAt.isAfter(fromDate) ||
            record.createdAt.isAtSameMomentAs(fromDate);
      }
      if (toDate != null && matchesDateRange) {
        matchesDateRange = record.createdAt
            .isBefore(toDate.add(const Duration(days: 1)));
      }

      return matchesQuery && matchesType && matchesCategory && matchesDateRange;
    }).toList();
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

    final deposits =
        records.where((r) => r.type == RecordType.deposit).toList();
    final withdrawals =
        records.where((r) => r.type == RecordType.withdrawal).toList();

    double totalPhysical = 0;
    double totalDigital = 0;
    Map<String, double> categoryTotals = {};

    for (final record in records) {
      final multiplier =
          record.type == RecordType.deposit ? 1.0 : -1.0;

      totalPhysical += record.physicalAmount * multiplier;
      totalDigital += record.digitalAmount * multiplier;

      categoryTotals[record.category] =
          (categoryTotals[record.category] ?? 0) +
              (record.totalAmount * multiplier);
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
}