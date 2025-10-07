// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Finanzas Libre';

  @override
  String get appName => 'Finanzas Libre';

  @override
  String get appDescription => 'Tu compañero para gestionar ahorros';

  @override
  String get summary => 'Resumen';

  @override
  String get history => 'Historial';

  @override
  String get categories => 'Categorías';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get settings => 'Configuración';

  @override
  String get totalSavings => 'Total Ahorrado';

  @override
  String get physicalMoney => 'Dinero Físico';

  @override
  String get digitalMoney => 'Dinero Digital';

  @override
  String get deposit => 'Depósito';

  @override
  String get withdrawal => 'Retiro';

  @override
  String get balance => 'Balance';

  @override
  String get income => 'Ingresos';

  @override
  String get expenses => 'Gastos';

  @override
  String get addRecord => 'Agregar Registro';

  @override
  String get editRecord => 'Editar Registro';

  @override
  String get deleteRecord => 'Eliminar Registro';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get add => 'Agregar';

  @override
  String get search => 'Buscar';

  @override
  String get filter => 'Filtrar';

  @override
  String get export => 'Exportar';

  @override
  String get import => 'Importar';

  @override
  String get category => 'Categoría';

  @override
  String get description => 'Descripción';

  @override
  String get notes => 'Notas';

  @override
  String get date => 'Fecha';

  @override
  String get amount => 'Monto';

  @override
  String get emptyRecords => 'No hay registros aún';

  @override
  String get emptyRecordsSubtitle => '¡Agrega tu primer registro de ahorro!';

  @override
  String get emptySearch => 'No se encontraron resultados';

  @override
  String get emptySearchSubtitle => 'Intenta con otros términos de búsqueda';

  @override
  String get emptyCategory => 'Sin registros en esta categoría';

  @override
  String get emptyCategorySubtitle => 'Agrega registros a esta categoría';

  @override
  String get deleteRecordConfirm => '¿Estás seguro de eliminar este registro?';

  @override
  String get deleteCategoryConfirm => 'Eliminar categoría';

  @override
  String get clearAllData => 'Limpiar todos los datos';

  @override
  String get clearAllDataConfirm =>
      '¿Estás seguro? Esta acción no se puede deshacer';

  @override
  String get recordSaved => 'Registro guardado exitosamente';

  @override
  String get recordUpdated => 'Registro actualizado exitosamente';

  @override
  String get recordDeleted => 'Registro eliminado';

  @override
  String get categorySaved => 'Categoría guardada';

  @override
  String get categoryDeleted => 'Categoría eliminada';

  @override
  String get genericError => 'Ocurrió un error inesperado';

  @override
  String get saveError => 'Error al guardar los datos';

  @override
  String get loadError => 'Error al cargar los datos';

  @override
  String get validationError => 'Por favor verifica los datos ingresados';

  @override
  String get categoryInUse => 'Categoría en uso';

  @override
  String get categoryExists => 'La categoría ya existe';

  @override
  String get emptyAmount => 'Debe ingresar al menos una cantidad';

  @override
  String get allFilter => 'Todos';

  @override
  String get deposits => 'Depósitos';

  @override
  String get withdrawals => 'Retiros';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get thisYear => 'Este año';

  @override
  String daysAgo(Object count) {
    return 'Hace $count días';
  }

  @override
  String get justNow => 'Ahora mismo';

  @override
  String minutesAgo(Object count) {
    return 'Hace $count minutos';
  }

  @override
  String hoursAgo(Object count) {
    return 'Hace $count horas';
  }

  @override
  String weeksAgo(Object count) {
    return 'Hace $count semanas';
  }

  @override
  String monthsAgo(Object count) {
    return 'Hace $count meses';
  }

  @override
  String yearsAgo(Object count) {
    return 'Hace $count años';
  }

  @override
  String get lastMovement => 'Último movimiento';

  @override
  String get totalRecords => 'Total Registros';

  @override
  String get recentMovements => 'Últimos Movimientos';

  @override
  String get viewAll => 'Ver todos';

  @override
  String get searchRecords => 'Buscar registros...';

  @override
  String get allCategories => 'Todas las categorías';

  @override
  String get noRecords => 'No hay registros';

  @override
  String get noRecordsSubtitle => 'Comienza agregando tu primer movimiento';

  @override
  String get noSearchResults => 'Sin resultados';

  @override
  String get noSearchResultsSubtitle => 'No se encontraron coincidencias';

  @override
  String get noCategoryRecords => 'Categoría vacía';

  @override
  String get noCategoryRecordsSubtitle => 'No hay registros en esta categoría';

  @override
  String get deleteConfirmation => '¿Eliminar?';

  @override
  String get savingsByCategory => 'Ahorros por Categoría';

  @override
  String get noDataAvailable => 'No hay datos disponibles';

  @override
  String get manageCategories => 'Administrar Categorías';

  @override
  String get recordsWillBeMoved => 'registro(s) serán movidos a General';

  @override
  String get currentAmount => 'Monto actual';

  @override
  String get moveAndDelete => 'Mover y Eliminar';

  @override
  String get newCategory => 'Nueva Categoría';

  @override
  String get categoryName => 'Nombre de la categoría';

  @override
  String get chooseColor => 'Elige un color';

  @override
  String get categoryPreview => 'Vista previa de tu categoría';

  @override
  String get invalidCategoryName => 'Nombre de categoría inválido';

  @override
  String get showAmounts => 'Mostrar montos';

  @override
  String get hideAmounts => 'Ocultar montos';

  @override
  String get new_ => 'Nuevo';

  @override
  String get appearance => 'Apariencia';

  @override
  String get language => 'Idioma';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get darkModeOn => 'Tema oscuro activado';

  @override
  String get lightModeOn => 'Tema claro activado';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get dataManagement => 'Gestión de Datos';

  @override
  String get exportData => 'Exportar datos';

  @override
  String get exportDataSubtitle => 'Guardar respaldo de tus registros';

  @override
  String get importData => 'Importar datos';

  @override
  String get importDataSubtitle => 'Restaurar desde un respaldo';

  @override
  String get dataExportSuccess => 'Datos exportados exitosamente';

  @override
  String get dataExportError => 'Error al exportar datos';

  @override
  String get dataExported => 'Datos exportados';

  @override
  String get exportInstructions =>
      'Copia estos datos y guárdalos en un lugar seguro:';

  @override
  String get pasteExportedData => 'Pega aquí los datos exportados:';

  @override
  String get dataImportedSuccessfully => 'Datos importados exitosamente';

  @override
  String get errorImportingData => 'Error al importar datos';

  @override
  String get invalidDataFormat => 'Formato de datos inválido';

  @override
  String get dangerZone => 'Zona de Peligro';

  @override
  String get deleteAllRecords => 'Eliminar todos los registros';

  @override
  String get deleteAllRecordsSubtitle =>
      'Borrar historial manteniendo categorías';

  @override
  String get resetApp => 'Restablecer aplicación';

  @override
  String get resetAppSubtitle => 'Borrar todo y volver al inicio';

  @override
  String get deleteRecordsTitle => 'Eliminar registros';

  @override
  String get deleteRecordsSubtitle =>
      '¿Estás seguro de que quieres eliminar todos los registros?\n\nEsta acción no se puede deshacer. Las categorías se mantendrán.';

  @override
  String get allRecordsDeleted => 'Todos los registros eliminados';

  @override
  String get deleteAll => 'Eliminar todo';

  @override
  String get resetAppTitle => 'Restablecer app';

  @override
  String get resetAppSubtext =>
      '¿Estás seguro de que quieres restablecer la aplicación?\n\nEsto eliminará:\n• Todos los registros\n• Todas las categorías personalizadas\n• Toda la configuración\n\nEsta acción NO se puede deshacer.';

  @override
  String get appReset => 'Aplicación restablecida';

  @override
  String get reset => 'Restablecer';

  @override
  String get security => 'Seguridad';

  @override
  String get pinSecurityTitle => 'PIN de seguridad';

  @override
  String get pinActiveSubtitle => 'Protección activa con PIN de 4 dígitos';

  @override
  String get pinInactiveSubtitle => 'Protege tu app con un PIN';

  @override
  String get changePinTitle => 'Cambiar PIN';

  @override
  String get changePinSubtitle => 'Modificar tu PIN actual';

  @override
  String get pinSetupSuccess => 'PIN configurado correctamente';

  @override
  String get noPinConfigured => 'No hay PIN configurado';

  @override
  String get pinUpdated => 'PIN actualizado correctamente';

  @override
  String get pinDisabled => 'PIN deshabilitado';

  @override
  String get disablePinTitle => 'Desactivar PIN';

  @override
  String get disablePinSubtitle =>
      '¿Estás seguro de que quieres desactivar la protección por PIN?\n\nTus datos quedarán sin protección.';

  @override
  String get disable => 'Desactivar';

  @override
  String get day => 'Día';

  @override
  String get week => 'Semana';

  @override
  String get month => 'Mes';

  @override
  String get specificMonth => 'Mes específico';

  @override
  String get specificDay => 'Día específico';

  @override
  String get distributionByCategory => 'Distribución por categoría';

  @override
  String get categoryDetails => 'Detalle por categoría';

  @override
  String get ofTotal => 'del total';

  @override
  String get selectMonth => 'Seleccionar mes';

  @override
  String get year => 'Año';

  @override
  String get noDataForPeriod => 'No hay datos para este período';

  @override
  String get january => 'Enero';

  @override
  String get february => 'Febrero';

  @override
  String get march => 'Marzo';

  @override
  String get april => 'Abril';

  @override
  String get may => 'Mayo';

  @override
  String get june => 'Junio';

  @override
  String get july => 'Julio';

  @override
  String get august => 'Agosto';

  @override
  String get september => 'Septiembre';

  @override
  String get october => 'Octubre';

  @override
  String get november => 'Noviembre';

  @override
  String get december => 'Diciembre';

  @override
  String get monday => 'Lunes';

  @override
  String get tuesday => 'Martes';

  @override
  String get wednesday => 'Miércoles';

  @override
  String get thursday => 'Jueves';

  @override
  String get friday => 'Viernes';

  @override
  String get saturday => 'Sábado';

  @override
  String get sunday => 'Domingo';

  @override
  String get about => 'Acerca de';

  @override
  String get version => 'Version';

  @override
  String get openSourceProject => 'Proyecto Open Source';

  @override
  String get openSourceDescription =>
      'Este proyecto es de codigo abierto. Podes ver el repositorio en';

  @override
  String get suggestions => 'Sugerencias';

  @override
  String get creator => 'Creador';

  @override
  String get supportProject => 'Apoya el proyecto';

  @override
  String get donateUala => 'Si quierés apoyar podés donar por Ualá y Paypal';

  @override
  String get aliasCopied => 'Alias copiada';

  @override
  String get features => 'Características';

  @override
  String get feature1 => 'Gestión de dinero fisico y digital';

  @override
  String get feature2 => 'Categorias personalizables';

  @override
  String get feature3 => 'Historial completo de movimientos';

  @override
  String get feature4 => 'Estadisticas detalladas';

  @override
  String get feature5 => 'Exportación e importación de datos';

  @override
  String get feature6 => 'Retroalimentación y soporte';

  @override
  String get dataStoredLocally =>
      'Tus datos se guardan localmente en tu dispositivo';

  @override
  String get close => 'Cerrar';

  @override
  String get deleteCategory => 'Eliminar categoría';

  @override
  String get currentPin => 'PIN actual';

  @override
  String get confirmPin => 'Confirmar PIN';

  @override
  String get changePin => 'Cambiar PIN';

  @override
  String get createPin => 'Crear PIN';

  @override
  String get enterCurrentPin => 'Ingresa tu PIN actual';

  @override
  String get confirmNewPin => 'Confirma tu nuevo PIN';

  @override
  String get createPinDigits => 'Crea un PIN de 4 dígitos';

  @override
  String get biometricUnlock => 'Desbloqueo biométrico';

  @override
  String get useFingerprintOrFace => 'Usa huella o Face ID';

  @override
  String get incorrectPin => 'PIN incorrecto';

  @override
  String get pinsDoNotMatch => 'Los PINs no coinciden';

  @override
  String get biometricAuthReason => 'Usa tu huella o Face ID para ingresar';

  @override
  String get enterPinToContinue => 'Ingresa tu PIN para continuar';

  @override
  String failedAttempts(Object count) {
    return 'Intentos fallidos: $count';
  }

  @override
  String get tooManyAttempts => 'Demasiados intentos';

  @override
  String get tooManyAttemptsMessage =>
      'Has fallado 5 intentos. La app se cerrará.';

  @override
  String get understood => 'Entendido';

  @override
  String get quickDepositWithdrawal => 'Ingreso/Retiro Rápido';

  @override
  String get currentBalance => 'Saldo actual';

  @override
  String get quickAmounts => 'Cantidades rápidas';

  @override
  String get customAmount => 'Monto personalizado';

  @override
  String get enterAmountOrSelectQuick =>
      'Ingresa el monto o selecciona uno rápido arriba';

  @override
  String get enterAmount => 'Ingresa un monto';

  @override
  String get enterValidAmount => 'Ingresa un monto válido';

  @override
  String get selectCategory => 'Selecciona una categoría';

  @override
  String get descriptionOptional => 'Descripción (opcional)';

  @override
  String get descriptionHint => 'Ej: Compras del súper, pago de servicios...';

  @override
  String get makeDeposit => 'Depositar';

  @override
  String get makeWithdrawal => 'Retirar';

  @override
  String transactionCompleted(String type, String amount) {
    return '$type de \$$amount realizado';
  }

  @override
  String get saving => 'Pensando...';

  @override
  String get quick => 'rapido de';
}
