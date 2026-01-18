import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import '../../models/savings_record.dart';
import '../../models/user_model.dart';
import '../../services/user_manager.dart';
import 'records_manager.dart';
import 'categories_manager.dart';
import 'goals_manager.dart';
import '../../models/savings_goal_model.dart';

class ImportExportManager {
  ImportExportManager();

  /// Exportar TODOS los usuarios y sus datos
  Future<Map<String, dynamic>> exportData(
    RecordsManager recordsManager,
    CategoriesManager categoriesManager,
    GoalsManager goalsManager,
  ) async {
    final userManager = UserManager();
    final allUsers = await userManager.getAllUsers();
    final currentUser = await userManager.getCurrentUser();

    // Estructura para almacenar datos de todos los usuarios
    final List<Map<String, dynamic>> usersData = [];

    // Recorrer cada usuario y obtener sus datos
    for (final user in allUsers) {
      // Temporalmente cambiar al usuario para obtener sus datos
      await userManager.setCurrentUser(user);

      final records = await recordsManager.loadRecords(forceReload: true);
      final categories = await categoriesManager.loadCategories(
        forceReload: true,
      );
      final categoryColors = await categoriesManager.loadAllCategoryColors();
      final goals = await goalsManager.loadGoals(forceReload: true);

      usersData.add({
        'userId': user.id,
        'userName': user.name,
        'userCreatedAt': user.createdAt.toIso8601String(),
        'profileImagePath': user.profileImagePath,
        'records': records.map((r) => r.toJson()).toList(),
        'categories': categories,
        'categoryColors': categoryColors.map(
          (key, value) => MapEntry(key, value.value),
        ),
        'goals': goals.map((g) => g.toJson()).toList(),
      });
    }

    // Restaurar usuario original
    if (currentUser != null) {
      await userManager.setCurrentUser(currentUser);
    }

    return {
      'exportDate': DateTime.now().toIso8601String(),
      'version': '2.0', // Nueva versión para indicar formato multi-usuario
      'appVersion': '1.2.0',
      'currentUserId': currentUser?.id,
      'users': usersData,
    };
  }

  /// Exportar a CSV (todos los usuarios)
  Future<String> exportToCSV(
    RecordsManager recordsManager,
    CategoriesManager categoriesManager,
  ) async {
    try {
      final userManager = UserManager();
      final allUsers = await userManager.getAllUsers();
      final currentUser = await userManager.getCurrentUser();
      final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

      final csvContent = StringBuffer();
      csvContent.writeln(
        'Usuario,Fecha,Tipo,Cantidad Física,Cantidad Digital,Descripción,Categoría,Notas',
      );

      // Exportar registros de cada usuario
      for (final user in allUsers) {
        await userManager.setCurrentUser(user);
        final records = await recordsManager.loadRecords(forceReload: true);

        for (final record in records) {
          final tipo = record.type == RecordType.deposit
              ? 'Depósito'
              : 'Retiro';
          final fecha = dateFormatter.format(record.createdAt);
          final fisica = record.physicalAmount.toStringAsFixed(2);
          final digital = record.digitalAmount.toStringAsFixed(2);
          final descripcion = _escapeCsv(record.description);
          final categoria = record.category;
          final notas = _escapeCsv(record.notes ?? '');
          final usuario = _escapeCsv(user.name);

          csvContent.writeln(
            '"$usuario",$fecha,$tipo,$fisica,$digital,"$descripcion",$categoria,"$notas"',
          );
        }
      }

      // Restaurar usuario original
      if (currentUser != null) {
        await userManager.setCurrentUser(currentUser);
      }

      debugPrint('✅ CSV exportado con ${allUsers.length} usuarios');
      return csvContent.toString();
    } catch (e) {
      debugPrint('❌ Error exportando a CSV: $e');
      return '';
    }
  }

  /// Exportar a Excel (todos los usuarios)
  Future<List<int>> exportToExcel(
    RecordsManager recordsManager,
    CategoriesManager categoriesManager,
  ) async {
    try {
      final userManager = UserManager();
      final allUsers = await userManager.getAllUsers();
      final currentUser = await userManager.getCurrentUser();
      final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

      var excel = Excel.createExcel();

      // ========== HOJA 1: RESUMEN GENERAL ==========
      Sheet sheetResumen = excel['RESUMEN'];
      sheetResumen.appendRow([
        TextCellValue('RESUMEN DE TODAS LAS BILLETERAS'),
      ]);
      sheetResumen.appendRow([]);
      sheetResumen.appendRow([
        TextCellValue('Fecha de Exportación'),
        TextCellValue(DateTime.now().toIso8601String()),
      ]);
      sheetResumen.appendRow([
        TextCellValue('Total de Usuarios'),
        IntCellValue(allUsers.length),
      ]);
      sheetResumen.appendRow([]);

      // Estadísticas por usuario
      sheetResumen.appendRow([TextCellValue('ESTADÍSTICAS POR USUARIO')]);
      sheetResumen.appendRow([]);
      sheetResumen.appendRow([
        TextCellValue('Usuario'),
        TextCellValue('Registros'),
        TextCellValue('Físico'),
        TextCellValue('Digital'),
        TextCellValue('Total'),
      ]);

      int totalRecordsGlobal = 0;
      double totalPhysicalGlobal = 0;
      double totalDigitalGlobal = 0;

      for (final user in allUsers) {
        await userManager.setCurrentUser(user);
        final records = await recordsManager.loadRecords(forceReload: true);
        final stats = _calculateStats(records);

        sheetResumen.appendRow([
          TextCellValue(user.name),
          IntCellValue(records.length),
          DoubleCellValue(double.parse(stats['physical'])),
          DoubleCellValue(double.parse(stats['digital'])),
          DoubleCellValue(double.parse(stats['total'])),
        ]);

        totalRecordsGlobal += records.length;
        totalPhysicalGlobal += double.parse(stats['physical']);
        totalDigitalGlobal += double.parse(stats['digital']);
      }

      sheetResumen.appendRow([]);
      sheetResumen.appendRow([
        TextCellValue('TOTAL GLOBAL'),
        IntCellValue(totalRecordsGlobal),
        DoubleCellValue(totalPhysicalGlobal),
        DoubleCellValue(totalDigitalGlobal),
        DoubleCellValue(totalPhysicalGlobal + totalDigitalGlobal),
      ]);

      sheetResumen.setColumnWidth(0, 25);
      sheetResumen.setColumnWidth(1, 15);
      sheetResumen.setColumnWidth(2, 18);
      sheetResumen.setColumnWidth(3, 18);
      sheetResumen.setColumnWidth(4, 18);

      // ========== HOJA 2: TODOS LOS REGISTROS ==========
      Sheet sheetRegistros = excel['TODOS_LOS_REGISTROS'];
      sheetRegistros.appendRow([
        TextCellValue('Usuario'),
        TextCellValue('Fecha'),
        TextCellValue('Tipo'),
        TextCellValue('Cantidad Física'),
        TextCellValue('Cantidad Digital'),
        TextCellValue('Descripción'),
        TextCellValue('Categoría'),
        TextCellValue('Notas'),
      ]);

      for (final user in allUsers) {
        await userManager.setCurrentUser(user);
        final records = await recordsManager.loadRecords(forceReload: true);

        for (final record in records) {
          final tipo = record.type == RecordType.deposit
              ? 'Depósito'
              : 'Retiro';
          final fecha = dateFormatter.format(record.createdAt);

          sheetRegistros.appendRow([
            TextCellValue(user.name),
            TextCellValue(fecha),
            TextCellValue(tipo),
            DoubleCellValue(record.physicalAmount),
            DoubleCellValue(record.digitalAmount),
            TextCellValue(record.description),
            TextCellValue(record.category),
            TextCellValue(record.notes ?? ''),
          ]);
        }
      }

      sheetRegistros.setColumnWidth(0, 20); // Usuario
      sheetRegistros.setColumnWidth(1, 18); // Fecha
      sheetRegistros.setColumnWidth(2, 12); // Tipo
      sheetRegistros.setColumnWidth(3, 18); // Cantidad Física
      sheetRegistros.setColumnWidth(4, 18); // Cantidad Digital
      sheetRegistros.setColumnWidth(5, 25); // Descripción
      sheetRegistros.setColumnWidth(6, 15); // Categoría
      sheetRegistros.setColumnWidth(7, 20); // Notas

      // ========== HOJAS INDIVIDUALES POR USUARIO ==========
      for (final user in allUsers) {
        await userManager.setCurrentUser(user);
        final records = await recordsManager.loadRecords(forceReload: true);
        // Nota: categories cargadas pero no usadas actualmente en la hoja individual

        // Crear hoja para este usuario (nombre seguro para Excel)
        String safeName = user.name.replaceAll(RegExp(r'[:\\/\*\?\[\]]'), '_');
        if (safeName.length > 30) safeName = safeName.substring(0, 30);

        Sheet userSheet = excel[safeName];

        userSheet.appendRow([TextCellValue('BILLETERA: ${user.name}')]);
        userSheet.appendRow([]);
        userSheet.appendRow([
          TextCellValue('Total Registros'),
          IntCellValue(records.length),
        ]);

        final stats = _calculateStats(records);
        userSheet.appendRow([
          TextCellValue('Dinero Físico'),
          DoubleCellValue(double.parse(stats['physical'])),
        ]);
        userSheet.appendRow([
          TextCellValue('Dinero Digital'),
          DoubleCellValue(double.parse(stats['digital'])),
        ]);
        userSheet.appendRow([
          TextCellValue('Total'),
          DoubleCellValue(double.parse(stats['total'])),
        ]);
        userSheet.appendRow([]);

        // Encabezados
        userSheet.appendRow([
          TextCellValue('Fecha'),
          TextCellValue('Tipo'),
          TextCellValue('Física'),
          TextCellValue('Digital'),
          TextCellValue('Descripción'),
          TextCellValue('Categoría'),
          TextCellValue('Notas'),
        ]);

        // Registros del usuario
        for (final record in records) {
          final tipo = record.type == RecordType.deposit
              ? 'Depósito'
              : 'Retiro';
          final fecha = dateFormatter.format(record.createdAt);

          userSheet.appendRow([
            TextCellValue(fecha),
            TextCellValue(tipo),
            DoubleCellValue(record.physicalAmount),
            DoubleCellValue(record.digitalAmount),
            TextCellValue(record.description),
            TextCellValue(record.category),
            TextCellValue(record.notes ?? ''),
          ]);
        }

        userSheet.setColumnWidth(0, 18);
        userSheet.setColumnWidth(1, 12);
        userSheet.setColumnWidth(2, 15);
        userSheet.setColumnWidth(3, 15);
        userSheet.setColumnWidth(4, 25);
        userSheet.setColumnWidth(5, 15);
        userSheet.setColumnWidth(6, 20);
      }

      // Restaurar usuario original
      if (currentUser != null) {
        await userManager.setCurrentUser(currentUser);
      }

      var bytes = excel.encode();
      debugPrint('✅ Excel exportado con ${allUsers.length} usuarios');
      return bytes ?? [];
    } catch (e) {
      debugPrint('❌ Error exportando a Excel: $e');
      return [];
    }
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

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

  /// Importar datos (compatible con ambas versiones)
  Future<bool> importData(
    Map<String, dynamic> data,
    RecordsManager recordsManager,
    CategoriesManager categoriesManager,
    GoalsManager goalsManager,
  ) async {
    try {
      final version = data['version'] ?? '1.0';

      if (version == '2.0') {
        // Formato multi-usuario (nuevo)
        return await _importMultiUserData(
          data,
          recordsManager,
          categoriesManager,
          goalsManager,
        );
      } else {
        // Formato usuario único (compatibilidad retroactiva)
        return await _importSingleUserData(
          data,
          recordsManager,
          categoriesManager,
          goalsManager,
        );
      }
    } catch (e) {
      debugPrint('❌ Error importando: $e');
      return false;
    }
  }

  Future<bool> _importMultiUserData(
    Map<String, dynamic> data,
    RecordsManager recordsManager,
    CategoriesManager categoriesManager,
    GoalsManager goalsManager,
  ) async {
    try {
      final userManager = UserManager();
      final currentUser = await userManager.getCurrentUser();
      final List<dynamic> usersData = data['users'] ?? [];

      debugPrint('🔄 Importando ${usersData.length} usuarios...');

      for (final userData in usersData) {
        final userId = userData['userId'] as String;
        final userName = userData['userName'] as String;

        // Buscar si el usuario ya existe
        final existingUsers = await userManager.getAllUsers();
        User? targetUser = existingUsers.cast<User?>().firstWhere(
          (u) => u?.id == userId,
          orElse: () => null,
        );

        // Si no existe, crear nuevo usuario
        if (targetUser == null) {
          final newUserId = await userManager.createUser(userName);
          final allUsers = await userManager.getAllUsers();
          targetUser = allUsers.firstWhere((u) => u.id == newUserId);
          debugPrint('✅ Usuario creado: $userName');
        }

        // Cambiar temporalmente a este usuario
        await userManager.setCurrentUser(targetUser);

        // Importar registros
        if (userData['records'] != null) {
          final List<SavingsRecord> importedRecords =
              (userData['records'] as List)
                  .map((json) => SavingsRecord.fromJson(json))
                  .toList();
          await recordsManager.saveRecords(importedRecords);
          debugPrint('  📝 ${importedRecords.length} registros importados');
        }

        // Importar categorías
        if (userData['categories'] != null) {
          final List<String> importedCategories = List<String>.from(
            userData['categories'],
          );
          await categoriesManager.saveCategories(importedCategories);
          debugPrint(
            '  🏷️ ${importedCategories.length} categorías importadas',
          );
        }

        // Importar colores de categorías
        if (userData['categoryColors'] != null) {
          final Map<String, dynamic> colors = userData['categoryColors'];
          for (final entry in colors.entries) {
            await categoriesManager.saveCategoryColor(
              entry.key,
              Color(entry.value as int),
            );
          }
        }

        // Importar metas
        if (userData['goals'] != null) {
          final List<SavingsGoal> importedGoals = (userData['goals'] as List)
              .map((json) => SavingsGoal.fromJson(json))
              .toList();
          await goalsManager.saveGoals(importedGoals);
          debugPrint('  🎯 ${importedGoals.length} metas importadas');
        }
      }

      // Restaurar usuario original
      if (currentUser != null) {
        await userManager.setCurrentUser(currentUser);
      }

      debugPrint('✅ Importación multi-usuario completada');
      return true;
    } catch (e) {
      debugPrint('❌ Error en importación multi-usuario: $e');
      return false;
    }
  }

  Future<bool> _importSingleUserData(
    Map<String, dynamic> data,
    RecordsManager recordsManager,
    CategoriesManager categoriesManager,
    GoalsManager goalsManager,
  ) async {
    try {
      // Mantener compatibilidad con formato antiguo (solo usuario actual)
      if (data['records'] != null) {
        final List<SavingsRecord> importedRecords = (data['records'] as List)
            .map((json) => SavingsRecord.fromJson(json))
            .toList();
        await recordsManager.saveRecords(importedRecords);
      }

      if (data['categories'] != null) {
        final List<String> importedCategories = List<String>.from(
          data['categories'],
        );
        await categoriesManager.saveCategories(importedCategories);
      }

      if (data['goals'] != null) {
        final List<SavingsGoal> importedGoals = (data['goals'] as List)
            .map((json) => SavingsGoal.fromJson(json))
            .toList();
        await goalsManager.saveGoals(importedGoals);
      }

      debugPrint('✅ Datos importados (formato antiguo)');
      return true;
    } catch (e) {
      debugPrint('❌ Error: $e');
      return false;
    }
  }
}
