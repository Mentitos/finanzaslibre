import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
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

      
      final csvContent = StringBuffer();
      csvContent.writeln(
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

  /// Exportar a Excel (.xlsx)
  Future<List<int>> exportToExcel(
    RecordsManager recordsManager,
    CategoriesManager categoriesManager,
  ) async {
    try {
      final records = await recordsManager.loadRecords();
      final categories = await categoriesManager.loadCategories();
      final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

      // Crear workbook
      var excel = Excel.createExcel();

      // ========== HOJA 1: RESUMEN ==========
      Sheet sheetResumen = excel['RESUMEN'];
      sheetResumen.appendRow([
        TextCellValue('RESUMEN DE BILLETERA'),
      ]);
      sheetResumen.appendRow([]);
      sheetResumen.appendRow([
        TextCellValue('Fecha de Exportación'),
        TextCellValue(DateTime.now().toIso8601String()),
      ]);
      sheetResumen.appendRow([
        TextCellValue('Total de Registros'),
        IntCellValue(records.length),
      ]);
      sheetResumen.appendRow([]);

      // Estadísticas
      final stats = _calculateStats(records);
      sheetResumen.appendRow([TextCellValue('ESTADÍSTICAS')]);
      sheetResumen.appendRow([]);
      sheetResumen.appendRow([
        TextCellValue('Concepto'),
        TextCellValue('Cantidad'),
      ]);
      sheetResumen.appendRow([
        TextCellValue('Total Depósitos'),
        TextCellValue(stats['deposits'].toString()),
      ]);
      sheetResumen.appendRow([
        TextCellValue('Total Retiros'),
        TextCellValue(stats['withdrawals'].toString()),
      ]);
      sheetResumen.appendRow([
        TextCellValue('Dinero Físico'),
        DoubleCellValue(double.parse(stats['physical'])),
      ]);
      sheetResumen.appendRow([
        TextCellValue('Dinero Digital'),
        DoubleCellValue(double.parse(stats['digital'])),
      ]);
      sheetResumen.appendRow([
        TextCellValue('Saldo Total'),
        DoubleCellValue(double.parse(stats['total'])),
      ]);

      // Ajustar ancho de columnas en RESUMEN
      sheetResumen.setColumnWidth(0, 25);
      sheetResumen.setColumnWidth(1, 25);

      // ========== HOJA 2: REGISTROS DETALLADOS ==========
      Sheet sheetRegistros = excel['REGISTROS'];
      sheetRegistros.appendRow([
        TextCellValue('Fecha'),
        TextCellValue('Tipo'),
        TextCellValue('Cantidad Física'),
        TextCellValue('Cantidad Digital'),
        TextCellValue('Descripción'),
        TextCellValue('Categoría'),
        TextCellValue('Notas'),
      ]);

      for (final record in records) {
        final tipo = record.type == RecordType.deposit ? 'Depósito' : 'Retiro';
        final fecha = dateFormatter.format(record.createdAt);

        sheetRegistros.appendRow([
          TextCellValue(fecha),
          TextCellValue(tipo),
          DoubleCellValue(record.physicalAmount),
          DoubleCellValue(record.digitalAmount),
          TextCellValue(record.description),
          TextCellValue(record.category),
          TextCellValue(record.notes ?? ''),
        ]);
      }

      // Ajustar ancho de columnas en REGISTROS
      sheetRegistros.setColumnWidth(0, 18); // Fecha
      sheetRegistros.setColumnWidth(1, 12); // Tipo
      sheetRegistros.setColumnWidth(2, 18); // Cantidad Física
      sheetRegistros.setColumnWidth(3, 18); // Cantidad Digital
      sheetRegistros.setColumnWidth(4, 25); // Descripción
      sheetRegistros.setColumnWidth(5, 15); // Categoría
      sheetRegistros.setColumnWidth(6, 20); // Notas

      // ========== HOJA 3: CATEGORÍAS ==========
      Sheet sheetCategorias = excel['CATEGORÍAS'];
      sheetCategorias.appendRow([
        TextCellValue('Categoría'),
        TextCellValue('Total'),
      ]);

      for (final category in categories) {
        final total = records.where((r) => r.category == category).fold<double>(
          0,
          (sum, r) {
            final multiplier = r.type == RecordType.deposit ? 1.0 : -1.0;
            return sum + (r.totalAmount * multiplier);
          },
        );

        sheetCategorias.appendRow([
          TextCellValue(category),
          DoubleCellValue(total),
        ]);
      }

      // Ajustar ancho de columnas en CATEGORÍAS
      sheetCategorias.setColumnWidth(0, 20);
      sheetCategorias.setColumnWidth(1, 18);

      // Guardar y obtener bytes
      var bytes = excel.encode();
      debugPrint('✅ Excel exportado correctamente');
      return bytes ?? [];
    } catch (e) {
      debugPrint('❌ Error exportando a Excel: $e');
      return [];
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