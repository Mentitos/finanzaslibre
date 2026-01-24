import 'package:flutter/material.dart';

class AppConstants {
  // Información técnica de la aplicación
  static const String appVersion = '1.2.4';

  // Colores de la aplicación
  static const Color primaryColor = Colors.green;
  static const Color secondaryColor = Colors.lightGreen;
  static const Color accentColor = Colors.greenAccent;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;
  static const Color successColor = Colors.green;
  static const Color infoColor = Colors.blue;

  // Colores para tipos de transacciones
  static const Color depositColor = Colors.green;
  static const Color withdrawalColor = Colors.red;
  static const Color physicalMoneyColor = Colors.blue;
  static const Color digitalMoneyColor = Colors.purple;

  // Colores para categorías
  static const List<Color> categoryColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
    Colors.deepOrange,
    Colors.lime,
  ];

  // Configuración de UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  static const double defaultElevation = 2.0;
  static const double smallElevation = 1.0;
  static const double largeElevation = 4.0;

  // Tamaños de iconos
  static const double smallIconSize = 16.0;
  static const double defaultIconSize = 24.0;
  static const double largeIconSize = 32.0;
  static const double extraLargeIconSize = 48.0;

  // Tamaños de fuente
  static const double smallFontSize = 12.0;
  static const double defaultFontSize = 14.0;
  static const double mediumFontSize = 16.0;
  static const double largeFontSize = 18.0;
  static const double titleFontSize = 20.0;
  static const double headlineFontSize = 24.0;

  // Límites y validaciones
  static const int maxDescriptionLength = 100;
  static const int maxNotesLength = 200;
  static const int maxCategoryNameLength = 30;
  static const double maxAmount = 999999999.0;
  static const double minAmount = 0.01;

  // Configuración de animaciones
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Configuración de datos
  static const int maxRecordsToShow = 100;
  static const int recentRecordsCount = 5;
  static const int searchHistoryLimit = 10;

  // Claves de almacenamiento
  static const String recordsStorageKey = 'savings_records';
  static const String categoriesStorageKey = 'savings_categories';
  static const String settingsStorageKey = 'app_settings';
  static const String userPreferencesKey = 'user_preferences';

  // Categorías por defecto
  static const List<String> defaultCategories = [
    'General',
    'Trabajo',
    'Inversión',
    'Regalo',
    'Emergencia',
    'Bonificación',
  ];

  // Montos rápidos sugeridos
  static const List<double> quickAmounts = [
    1000,
    2000,
    5000,
    10000,
    20000,
    50000,
    100000,
  ];

  // Configuración de formato (técnico, no texto)
  static const String currencySymbol = '\$';
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Configuración de exportación (técnico)
  static const String exportFilePrefix = 'mis_ahorros_';
  static const String exportDateFormat = 'yyyy_MM_dd';
  static const String backupFileExtension = '.json';

  // URLs (técnico)
  static const String supportEmail = 'sugerenciasfinanzaslibre@gmail.com';

  // Métodos utilitarios
  static Color getCategoryColor(
    String category, [
    Map<String, Color>? customColors,
  ]) {
    if (customColors != null && customColors.containsKey(category)) {
      return customColors[category]!;
    }

    final defaultColors = {
      'General': Colors.blue,
      'Trabajo': Colors.green,
      'Inversión': Colors.orange,
      'Regalo': Colors.pink,
      'Emergencia': Colors.red,
      'Bonificación': Colors.amber,
    };

    return defaultColors[category] ?? Colors.grey;
  }

  static IconData getCategoryIcon(String category) {
    final defaultIcons = {
      'General': Icons.category,
      'Trabajo': Icons.work,
      'Inversión': Icons.trending_up,
      'Regalo': Icons.card_giftcard,
      'Emergencia': Icons.warning_amber,
      'Bonificación': Icons.star,
      // Legacy or other mappings if needed
    };

    return defaultIcons[category] ?? Icons.label_outline;
  }

  static Color getTypeColor(bool isDeposit) {
    return isDeposit ? depositColor : withdrawalColor;
  }

  static IconData getTypeIcon(bool isDeposit) {
    return isDeposit ? Icons.add_circle : Icons.remove_circle;
  }

  // Validadores
  static bool isValidAmount(String value) {
    final amount = double.tryParse(value);
    return amount != null && amount >= minAmount && amount <= maxAmount;
  }

  static bool isValidDescription(String value) {
    return value.length <= maxDescriptionLength;
  }

  static bool isValidNotes(String value) {
    return value.length <= maxNotesLength;
  }

  static bool isValidCategoryName(String value) {
    return value.trim().isNotEmpty &&
        value.length <= maxCategoryNameLength &&
        !value.trim().contains(RegExp(r'[<>:"/\\|?*]'));
  }
}
