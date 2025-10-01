import 'package:flutter/material.dart';

class AppConstants {
  // Información de la aplicación
  static const String appName = 'Mis Ahorros';
  static const String appVersion = '1.1.0';
  static const String appDescription = 'Tu compañero para gestionar ahorros';
  
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
    'Freelance',
    'Bonificación',
    'Venta',
    'Ahorro',
    'Extra',
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
  
  // Mensajes de la aplicación
  static const String emptyRecordsTitle = 'No hay registros aún';
  static const String emptyRecordsSubtitle = '¡Agrega tu primer registro de ahorro!';
  static const String emptySearchTitle = 'No se encontraron resultados';
  static const String emptySearchSubtitle = 'Intenta con otros términos de búsqueda';
  static const String emptyCategoryTitle = 'Sin registros en esta categoría';
  static const String emptyCategorySubtitle = 'Agrega registros a esta categoría';
  
  // Mensajes de confirmación
  static const String deleteRecordTitle = 'Eliminar registro';
  static const String deleteRecordMessage = '¿Estás seguro de eliminar este registro?';
  static const String deleteCategoryTitle = 'Eliminar categoría';
  static const String deleteCategoryMessage = '¿Estás seguro de eliminar esta categoría?';
  static const String clearAllDataTitle = 'Limpiar todos los datos';
  static const String clearAllDataMessage = '¿Estás seguro? Esta acción no se puede deshacer.';
  
  // Mensajes de éxito
  static const String recordSavedSuccess = 'Registro guardado exitosamente';
  static const String recordUpdatedSuccess = 'Registro actualizado exitosamente';
  static const String recordDeletedSuccess = 'Registro eliminado';
  static const String categorySavedSuccess = 'Categoría guardada';
  static const String categoryDeletedSuccess = 'Categoría eliminada';
  
  // Mensajes de error
  static const String genericError = 'Ocurrió un error inesperado';
  static const String saveError = 'Error al guardar los datos';
  static const String loadError = 'Error al cargar los datos';
  static const String networkError = 'Error de conexión';
  static const String validationError = 'Por favor verifica los datos ingresados';
  static const String categoryInUseError = 'No se puede eliminar: categoría en uso';
  static const String categoryExistsError = 'La categoría ya existe';
  static const String emptyAmountError = 'Debe ingresar al menos una cantidad';
  
  // Etiquetas de interfaz
  static const String physicalMoneyLabel = 'Dinero Físico';
  static const String digitalMoneyLabel = 'Dinero Digital';
  static const String totalSavingsLabel = 'Total Ahorrado';
  static const String depositLabel = 'Depósito';
  static const String withdrawalLabel = 'Retiro';
  static const String categoryLabel = 'Categoría';
  static const String descriptionLabel = 'Descripción';
  static const String notesLabel = 'Notas';
  static const String dateLabel = 'Fecha';
  static const String amountLabel = 'Monto';
  
  // Botones y acciones
  static const String saveButtonLabel = 'Guardar';
  static const String cancelButtonLabel = 'Cancelar';
  static const String editButtonLabel = 'Editar';
  static const String deleteButtonLabel = 'Eliminar';
  static const String addButtonLabel = 'Agregar';
  static const String searchButtonLabel = 'Buscar';
  static const String filterButtonLabel = 'Filtrar';
  static const String exportButtonLabel = 'Exportar';
  static const String importButtonLabel = 'Importar';
  
  // Títulos de secciones
  static const String summaryTabTitle = 'Resumen';
  static const String historyTabTitle = 'Historial';
  static const String categoriesTabTitle = 'Categorías';
  static const String settingsTabTitle = 'Configuración';
  static const String statsTabTitle = 'Estadísticas';
  
  // Filtros
  static const String allFilter = 'Todos';
  static const String depositsFilter = 'Depósitos';
  static const String withdrawalsFilter = 'Retiros';
  static const String todayFilter = 'Hoy';
  static const String thisWeekFilter = 'Esta semana';
  static const String thisMonthFilter = 'Este mes';
  static const String thisYearFilter = 'Este año';
  
  // Configuración de formato
  static const String currencySymbol = '\$';
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Configuración de exportación
  static const String exportFilePrefix = 'mis_ahorros_';
  static const String exportDateFormat = 'yyyy_MM_dd';
  static const String backupFileExtension = '.json';
  
  // URLs y enlaces (si fuera necesario en el futuro)
  static const String supportEmail = 'support@misahorros.app';
  static const String privacyPolicyUrl = 'https://misahorros.app/privacy';
  static const String termsOfServiceUrl = 'https://misahorros.app/terms';
  
  // Configuración de notificaciones (para futuras implementaciones)
  static const String defaultNotificationTitle = 'Mis Ahorros';
  static const String reminderNotificationBody = '¡No olvides registrar tus ahorros de hoy!';
  
  // Métodos utilitarios para colores
  static Color getCategoryColor(String category) {
    final hash = category.hashCode;
    return categoryColors[hash.abs() % categoryColors.length];
  }
  
  static Color getTypeColor(bool isDeposit) {
    return isDeposit ? depositColor : withdrawalColor;
  }
  
  static IconData getTypeIcon(bool isDeposit) {
    return isDeposit ? Icons.add_circle : Icons.remove_circle;
  }
  
  static String getTypeLabel(bool isDeposit) {
    return isDeposit ? depositLabel : withdrawalLabel;
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
           !value.trim().contains(RegExp(r'[<>:"/\\|?*]')); // Caracteres no permitidos
  }
}