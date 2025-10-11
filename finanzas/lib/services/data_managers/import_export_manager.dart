import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/savings_record.dart';
import 'records_manager.dart';
import 'categories_manager.dart';

class ImportExportManager {
  ImportExportManager();

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

  /// Exportar a CSV
  Future<String> exportToCSV(
    RecordsManager recordsManager,
    CategoriesManager categoriesManager,
  ) async {
    try {
      final records = await recordsManager.loadRecords();
      final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

      // Header
      final csvContent = StringBuffer();
      csvContent.writeln(
        'Fecha,Tipo,Cantidad Física,Cantidad Digital,Descripción,Categoría,Notas',
      );

      // Datos
      for (final record in records) {
        final tipo = record.type == RecordType.deposit ? 'Depósito' : 'Retiro';
        final fecha = dateFormatter.format(record.createdAt);
        final fisica = record.physicalAmount.toStringAsFixed(2);
        final digital = record.digitalAmount.toStringAsFixed(2);
        final descripcion = _escapeCsv(record.description);
        final categoria = record.category;
        final notas = _escapeCsv(record.notes ?? '');

        csvContent.writeln(
          '$fecha,$tipo,$fisica,$digital,"$descripcion",$categoria,"$notas"',
        );
      }

      debugPrint('✅ CSV exportado');
      return csvContent.toString();
    } catch (e) {
      debugPrint('❌ Error exportando a CSV: $e');
      return '';
    }
  }

  /// Exportar a formato Excel-compatible (CSV con formato especial)
  Future<String> exportToExcel(
    RecordsManager recordsManager,
    CategoriesManager categoriesManager,
  ) async {
    try {
      final records = await recordsManager.loadRecords();
      final categories = await categoriesManager.loadCategories();
      final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

      final excelContent = StringBuffer();

      // Hoja 1: Resumen
      excelContent.writeln('RESUMEN DE BILLETERA');
      excelContent.writeln('');
      excelContent.writeln('Fecha de Exportación,${DateTime.now().toIso8601String()}');
      excelContent.writeln('Total de Registros,${records.length}');
      excelContent.writeln('');

      // Estadísticas
      final stats = _calculateStats(records);
      excelContent.writeln('ESTADÍSTICAS');
      excelContent.writeln('');
      excelContent.writeln('Concepto,Cantidad');
      excelContent.writeln('Total Depósitos,${stats['deposits']}');
      excelContent.writeln('Total Retiros,${stats['withdrawals']}');
      excelContent.writeln('Dinero Físico,${stats['physical']}');
      excelContent.writeln('Dinero Digital,${stats['digital']}');
      excelContent.writeln('Saldo Total,${stats['total']}');
      excelContent.writeln('');
      excelContent.writeln('');

      // Hoja 2: Registros detallados
      excelContent.writeln('REGISTROS DETALLADOS');
      excelContent.writeln('');
      excelContent.writeln(
        'Fecha,Tipo,Cantidad Física,Cantidad Digital,Descripción,Categoría,Notas',
      );

      for (final record in records) {
        final tipo = record.type == RecordType.deposit ? 'Depósito' : 'Retiro';
        final fecha = dateFormatter.format(record.createdAt);
        final fisica = record.physicalAmount.toStringAsFixed(2);
        final digital = record.digitalAmount.toStringAsFixed(2);
        final descripcion = _escapeCsv(record.description);
        final categoria = record.category;
        final notas = _escapeCsv(record.notes ?? '');

        excelContent.writeln(
          '$fecha,$tipo,$fisica,$digital,"$descripcion",$categoria,"$notas"',
        );
      }

      excelContent.writeln('');
      excelContent.writeln('');

      // Hoja 3: Categorías
      excelContent.writeln('CATEGORÍAS');
      excelContent.writeln('');
      excelContent.writeln('Categoría,Total');

      for (final category in categories) {
        final total = records
            .where((r) => r.category == category)
            .fold<double>(0, (sum, r) {
          final multiplier = r.type == RecordType.deposit ? 1.0 : -1.0;
          return sum + (r.totalAmount * multiplier);
        });

        excelContent.writeln('$category,${total.toStringAsFixed(2)}');
      }

      debugPrint('✅ Excel exportado');
      return excelContent.toString();
    } catch (e) {
      debugPrint('❌ Error exportando a Excel: $e');
      return '';
    }
  }

  /// Escapar comillas en CSV
  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Calcular estadísticas
  Map<String, dynamic> _calculateStats(List<SavingsRecord> records) {
    double totalPhysical = 0;
    double totalDigital = 0;
    int deposits = 0;
    int withdrawals = 0;

    for (final record in records) {
      final multiplier = record.type == RecordType.deposit ? 1.0 : -1.0;

      totalPhysical += record.physicalAmount * multiplier;
      totalDigital += record.digitalAmount * multiplier;

      if (record.type == RecordType.deposit) {
        deposits++;
      } else {
        withdrawals++;
      }
    }

    return {
      'physical': totalPhysical.toStringAsFixed(2),
      'digital': totalDigital.toStringAsFixed(2),
      'total': (totalPhysical + totalDigital).toStringAsFixed(2),
      'deposits': deposits,
      'withdrawals': withdrawals,
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