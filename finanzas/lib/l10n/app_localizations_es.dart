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

  @override
  String get newRecord => 'Nuevo Registro';

  @override
  String get operationType => 'Tipo de operación';

  @override
  String get amounts => 'Montos';

  @override
  String get enterAtLeastOneAmount => 'Ingresa al menos un monto';

  @override
  String get descriptionHintRecord => 'Ej: Ahorro mensual, gastos varios...';

  @override
  String get additionalNotes => 'Notas adicionales(opcional)';

  @override
  String get additionalNotesHint => 'Informacion extra...';

  @override
  String get update => 'Actualizar';

  @override
  String get mustEnterAtLeastOneAmount => 'Al menos ingresa un monto';

  @override
  String get depositUpper => 'DEPÓSITO';

  @override
  String get withdrawalUpper => 'RETIRO';

  @override
  String get systemLanguage => 'Idioma del sistema';

  @override
  String get system => 'sistema';

  @override
  String get systemDefault => 'predeterminado del sistema';

  @override
  String get users => 'Usuarios';

  @override
  String get addUser => 'Agregar usuario';

  @override
  String get enterUserName => 'Ingresa el nombre del usuario';

  @override
  String get create => 'Crear';

  @override
  String get deleteUser => 'Eliminar usuario';

  @override
  String get deleteUserConfirmation => '¿Seguro que deseas eliminar al usuario';

  @override
  String get userCreated => 'Usuario creado';

  @override
  String get userDeleted => 'Usuario eliminado';

  @override
  String get currentUser => 'Usuario actual';

  @override
  String get switchedTo => 'Cambiado a';

  @override
  String get takePhoto => 'Tomar foto';

  @override
  String get selectFromGallery => 'Seleccionar de la galería';

  @override
  String get removePhoto => 'Eliminar foto';

  @override
  String get profilePhotoUpdated => 'Foto de perfil actualizada';

  @override
  String get photoRemoved => 'Foto eliminada';

  @override
  String get error => 'Error';

  @override
  String get principal => 'Principal';

  @override
  String get selectExportFormat => 'Seleccionar formato de exportacion:';

  @override
  String get standardDataFormat => 'Formato de datos estandar';

  @override
  String get simpleSpreadsheetFormat => 'Formato de hoja de calculo simple';

  @override
  String get excelFormatWithMultipleSheets =>
      'Formato Excel con multiples hojas';

  @override
  String get exportJson => 'Exportar JSON';

  @override
  String get jsonFormat => 'Formato JSON:';

  @override
  String get jsonCopiedToClipboard => 'JSON copiado al portapapeles';

  @override
  String fileSaved(String filename) {
    return 'Archivo guardado: $filename';
  }

  @override
  String get pathCopied => 'Ruta copiada';

  @override
  String get onlyJsonCanBeImported =>
      'Solo se pueden importar datos JSON en esta aplicacion';

  @override
  String get onlyJsonFilesAccepted =>
      'Solo se aceptan archivos JSON exportados desde esta aplicacion';

  @override
  String get jsonPastedFromClipboard => 'JSON pegado desde el portapapeles';

  @override
  String get noTextInClipboard => 'No hay texto en el portapapeles';

  @override
  String get jsonFileLoaded => 'Archivo JSON cargado';

  @override
  String get errorOpeningFile => 'Error al abrir el archivo';

  @override
  String get paste => 'Pegar';

  @override
  String get file => 'Archivo';

  @override
  String get download => 'Descargar';

  @override
  String get copy => 'Copiar';

  @override
  String get manageUsersWallets => 'Administrar billeteras de usuarios';

  @override
  String get preferences => 'Preferencias';

  @override
  String get appearanceNotificationsSecurity =>
      'Apariencia, notificaciones y seguridad';

  @override
  String get data => 'Datos';

  @override
  String get exportImportManageData =>
      'Exportar, importar y administrar tus datos';

  @override
  String get dataManagementTitle => 'Administracion de datos';

  @override
  String get dangerZoneTitle => 'Zona de peligro';

  @override
  String get copyPath => 'Copiar ruta';

  @override
  String get share => 'Compartir';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get dailyReminder => 'Recordatorio diario';

  @override
  String get reminderEnabled => 'Recibirás un recordatorio cada día';

  @override
  String get reminderDisabled => 'Los recordatorios están desactivados';

  @override
  String get reminderTime => 'Hora del recordatorio';

  @override
  String get notificationPermissionRequired =>
      'Se necesitan permisos para mostrar notificaciones';

  @override
  String reminderActivatedAt(Object time) {
    return 'Recordatorio activado para las $time';
  }

  @override
  String timeUpdated(Object time) {
    return 'Hora actualizada: $time';
  }

  @override
  String get reminderDeactivated => 'Recordatorio desactivado';

  @override
  String get savingsReminderTitle => '💰 Recordatorio de Ahorros';

  @override
  String get savingsReminderBody => '¿Ya registraste tus movimientos de hoy?';

  @override
  String get holdToDelete => 'Presiona y mantén para eliminar';

  @override
  String get editUserName => 'Editar nombre';

  @override
  String get useThisWallet => 'Usar esta billetera';

  @override
  String alreadyUsingUser(String name) {
    return 'Ya estabas usando $name';
  }

  @override
  String get enterNewUserName => 'Ingresa el nuevo nombre';

  @override
  String nameUpdatedTo(String newName) {
    return 'Nombre actualizado a: $newName';
  }

  @override
  String get accounts => 'Cuentas';

  @override
  String get userManagement => 'Gestión de Usuarios';

  @override
  String get manageUsersAndWallets =>
      'Gestiona usuarios y cambia entre diferentes carteras.';
}
