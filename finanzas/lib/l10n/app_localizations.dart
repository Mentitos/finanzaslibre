import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Finanzas Libre'**
  String get appTitle;

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'Finanzas Libre'**
  String get appName;

  /// No description provided for @appDescription.
  ///
  /// In es, this message translates to:
  /// **'Tu compañero para gestionar ahorros'**
  String get appDescription;

  /// No description provided for @summary.
  ///
  /// In es, this message translates to:
  /// **'Resumen'**
  String get summary;

  /// No description provided for @history.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get history;

  /// No description provided for @categories.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get categories;

  /// No description provided for @statistics.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get statistics;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settings;

  /// No description provided for @totalSavings.
  ///
  /// In es, this message translates to:
  /// **'Total Ahorrado'**
  String get totalSavings;

  /// No description provided for @physicalMoney.
  ///
  /// In es, this message translates to:
  /// **'Dinero Físico'**
  String get physicalMoney;

  /// No description provided for @digitalMoney.
  ///
  /// In es, this message translates to:
  /// **'Dinero Digital'**
  String get digitalMoney;

  /// No description provided for @deposit.
  ///
  /// In es, this message translates to:
  /// **'Depósito'**
  String get deposit;

  /// No description provided for @withdrawal.
  ///
  /// In es, this message translates to:
  /// **'Retiro'**
  String get withdrawal;

  /// No description provided for @balance.
  ///
  /// In es, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @income.
  ///
  /// In es, this message translates to:
  /// **'Ingresos'**
  String get income;

  /// No description provided for @expenses.
  ///
  /// In es, this message translates to:
  /// **'Gastos'**
  String get expenses;

  /// No description provided for @addRecord.
  ///
  /// In es, this message translates to:
  /// **'Agregar Registro'**
  String get addRecord;

  /// No description provided for @editRecord.
  ///
  /// In es, this message translates to:
  /// **'Editar Registro'**
  String get editRecord;

  /// No description provided for @deleteRecord.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Registro'**
  String get deleteRecord;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @add.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get add;

  /// No description provided for @search.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In es, this message translates to:
  /// **'Filtrar'**
  String get filter;

  /// No description provided for @export.
  ///
  /// In es, this message translates to:
  /// **'Exportar'**
  String get export;

  /// No description provided for @import.
  ///
  /// In es, this message translates to:
  /// **'Importar'**
  String get import;

  /// No description provided for @category.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get category;

  /// No description provided for @description.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get description;

  /// No description provided for @notes.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get notes;

  /// No description provided for @date.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get date;

  /// No description provided for @amount.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get amount;

  /// No description provided for @emptyRecords.
  ///
  /// In es, this message translates to:
  /// **'No hay registros aún'**
  String get emptyRecords;

  /// No description provided for @emptyRecordsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'¡Agrega tu primer registro de ahorro!'**
  String get emptyRecordsSubtitle;

  /// No description provided for @emptySearch.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron resultados'**
  String get emptySearch;

  /// No description provided for @emptySearchSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Intenta con otros términos de búsqueda'**
  String get emptySearchSubtitle;

  /// No description provided for @emptyCategory.
  ///
  /// In es, this message translates to:
  /// **'Sin registros en esta categoría'**
  String get emptyCategory;

  /// No description provided for @emptyCategorySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Agrega registros a esta categoría'**
  String get emptyCategorySubtitle;

  /// No description provided for @deleteRecordConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de eliminar este registro?'**
  String get deleteRecordConfirm;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In es, this message translates to:
  /// **'Eliminar categoría'**
  String get deleteCategoryConfirm;

  /// No description provided for @clearAllData.
  ///
  /// In es, this message translates to:
  /// **'Limpiar todos los datos'**
  String get clearAllData;

  /// No description provided for @clearAllDataConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro? Esta acción no se puede deshacer'**
  String get clearAllDataConfirm;

  /// No description provided for @recordSaved.
  ///
  /// In es, this message translates to:
  /// **'Registro guardado exitosamente'**
  String get recordSaved;

  /// No description provided for @recordUpdated.
  ///
  /// In es, this message translates to:
  /// **'Registro actualizado exitosamente'**
  String get recordUpdated;

  /// No description provided for @recordDeleted.
  ///
  /// In es, this message translates to:
  /// **'Registro eliminado'**
  String get recordDeleted;

  /// No description provided for @categorySaved.
  ///
  /// In es, this message translates to:
  /// **'Categoría guardada'**
  String get categorySaved;

  /// No description provided for @categoryDeleted.
  ///
  /// In es, this message translates to:
  /// **'Categoría eliminada'**
  String get categoryDeleted;

  /// No description provided for @genericError.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error inesperado'**
  String get genericError;

  /// No description provided for @saveError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar los datos'**
  String get saveError;

  /// No description provided for @loadError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar los datos'**
  String get loadError;

  /// No description provided for @validationError.
  ///
  /// In es, this message translates to:
  /// **'Por favor verifica los datos ingresados'**
  String get validationError;

  /// No description provided for @categoryInUse.
  ///
  /// In es, this message translates to:
  /// **'Categoría en uso'**
  String get categoryInUse;

  /// No description provided for @categoryExists.
  ///
  /// In es, this message translates to:
  /// **'La categoría ya existe'**
  String get categoryExists;

  /// No description provided for @emptyAmount.
  ///
  /// In es, this message translates to:
  /// **'Debe ingresar al menos una cantidad'**
  String get emptyAmount;

  /// No description provided for @allFilter.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get allFilter;

  /// No description provided for @deposits.
  ///
  /// In es, this message translates to:
  /// **'Depósitos'**
  String get deposits;

  /// No description provided for @withdrawals.
  ///
  /// In es, this message translates to:
  /// **'Retiros'**
  String get withdrawals;

  /// No description provided for @today.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In es, this message translates to:
  /// **'Este mes'**
  String get thisMonth;

  /// No description provided for @thisYear.
  ///
  /// In es, this message translates to:
  /// **'Este año'**
  String get thisYear;

  /// No description provided for @daysAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {count} días'**
  String daysAgo(Object count);

  /// No description provided for @justNow.
  ///
  /// In es, this message translates to:
  /// **'Ahora mismo'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {count} minutos'**
  String minutesAgo(Object count);

  /// No description provided for @hoursAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {count} horas'**
  String hoursAgo(Object count);

  /// No description provided for @weeksAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {count} semanas'**
  String weeksAgo(Object count);

  /// No description provided for @monthsAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {count} meses'**
  String monthsAgo(Object count);

  /// No description provided for @yearsAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {count} años'**
  String yearsAgo(Object count);

  /// No description provided for @lastMovement.
  ///
  /// In es, this message translates to:
  /// **'Último movimiento'**
  String get lastMovement;

  /// No description provided for @totalRecords.
  ///
  /// In es, this message translates to:
  /// **'Total Registros'**
  String get totalRecords;

  /// No description provided for @recentMovements.
  ///
  /// In es, this message translates to:
  /// **'Últimos Movimientos'**
  String get recentMovements;

  /// No description provided for @viewAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todos'**
  String get viewAll;

  /// No description provided for @searchRecords.
  ///
  /// In es, this message translates to:
  /// **'Buscar registros...'**
  String get searchRecords;

  /// No description provided for @allCategories.
  ///
  /// In es, this message translates to:
  /// **'Todas las categorías'**
  String get allCategories;

  /// No description provided for @noRecords.
  ///
  /// In es, this message translates to:
  /// **'No hay registros'**
  String get noRecords;

  /// No description provided for @noRecordsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Comienza agregando tu primer movimiento'**
  String get noRecordsSubtitle;

  /// No description provided for @noSearchResults.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get noSearchResults;

  /// No description provided for @noSearchResultsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron coincidencias'**
  String get noSearchResultsSubtitle;

  /// No description provided for @noCategoryRecords.
  ///
  /// In es, this message translates to:
  /// **'Categoría vacía'**
  String get noCategoryRecords;

  /// No description provided for @noCategoryRecordsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'No hay registros en esta categoría'**
  String get noCategoryRecordsSubtitle;

  /// No description provided for @deleteConfirmation.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar?'**
  String get deleteConfirmation;

  /// No description provided for @savingsByCategory.
  ///
  /// In es, this message translates to:
  /// **'Ahorros por Categoría'**
  String get savingsByCategory;

  /// No description provided for @noDataAvailable.
  ///
  /// In es, this message translates to:
  /// **'No hay datos disponibles'**
  String get noDataAvailable;

  /// No description provided for @manageCategories.
  ///
  /// In es, this message translates to:
  /// **'Administrar Categorías'**
  String get manageCategories;

  /// No description provided for @recordsWillBeMoved.
  ///
  /// In es, this message translates to:
  /// **'registro(s) serán movidos a General'**
  String get recordsWillBeMoved;

  /// No description provided for @currentAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto actual'**
  String get currentAmount;

  /// No description provided for @moveAndDelete.
  ///
  /// In es, this message translates to:
  /// **'Mover y Eliminar'**
  String get moveAndDelete;

  /// No description provided for @newCategory.
  ///
  /// In es, this message translates to:
  /// **'Nueva Categoría'**
  String get newCategory;

  /// No description provided for @categoryName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la categoría'**
  String get categoryName;

  /// No description provided for @chooseColor.
  ///
  /// In es, this message translates to:
  /// **'Elige un color'**
  String get chooseColor;

  /// No description provided for @categoryPreview.
  ///
  /// In es, this message translates to:
  /// **'Vista previa de tu categoría'**
  String get categoryPreview;

  /// No description provided for @invalidCategoryName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de categoría inválido'**
  String get invalidCategoryName;

  /// No description provided for @showAmounts.
  ///
  /// In es, this message translates to:
  /// **'Mostrar montos'**
  String get showAmounts;

  /// No description provided for @hideAmounts.
  ///
  /// In es, this message translates to:
  /// **'Ocultar montos'**
  String get hideAmounts;

  /// No description provided for @new_.
  ///
  /// In es, this message translates to:
  /// **'Nuevo'**
  String get new_;

  /// No description provided for @appearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In es, this message translates to:
  /// **'Modo oscuro'**
  String get darkMode;

  /// No description provided for @darkModeOn.
  ///
  /// In es, this message translates to:
  /// **'Tema oscuro activado'**
  String get darkModeOn;

  /// No description provided for @lightModeOn.
  ///
  /// In es, this message translates to:
  /// **'Tema claro activado'**
  String get lightModeOn;

  /// No description provided for @selectLanguage.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar idioma'**
  String get selectLanguage;

  /// No description provided for @dataManagement.
  ///
  /// In es, this message translates to:
  /// **'Gestión de Datos'**
  String get dataManagement;

  /// No description provided for @exportData.
  ///
  /// In es, this message translates to:
  /// **'Exportar datos'**
  String get exportData;

  /// No description provided for @exportDataSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Guardar respaldo de tus registros'**
  String get exportDataSubtitle;

  /// No description provided for @importData.
  ///
  /// In es, this message translates to:
  /// **'Importar datos'**
  String get importData;

  /// No description provided for @importDataSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Restaurar desde un respaldo'**
  String get importDataSubtitle;

  /// No description provided for @dataExportSuccess.
  ///
  /// In es, this message translates to:
  /// **'Datos exportados exitosamente'**
  String get dataExportSuccess;

  /// No description provided for @dataExportError.
  ///
  /// In es, this message translates to:
  /// **'Error al exportar datos'**
  String get dataExportError;

  /// No description provided for @dataExported.
  ///
  /// In es, this message translates to:
  /// **'Datos exportados'**
  String get dataExported;

  /// No description provided for @exportInstructions.
  ///
  /// In es, this message translates to:
  /// **'Copia estos datos y guárdalos en un lugar seguro:'**
  String get exportInstructions;

  /// No description provided for @pasteExportedData.
  ///
  /// In es, this message translates to:
  /// **'Pega aquí los datos exportados:'**
  String get pasteExportedData;

  /// No description provided for @dataImportedSuccessfully.
  ///
  /// In es, this message translates to:
  /// **'Datos importados exitosamente'**
  String get dataImportedSuccessfully;

  /// No description provided for @errorImportingData.
  ///
  /// In es, this message translates to:
  /// **'Error al importar datos'**
  String get errorImportingData;

  /// No description provided for @invalidDataFormat.
  ///
  /// In es, this message translates to:
  /// **'Formato de datos inválido'**
  String get invalidDataFormat;

  /// No description provided for @dangerZone.
  ///
  /// In es, this message translates to:
  /// **'Zona de Peligro'**
  String get dangerZone;

  /// No description provided for @deleteAllRecords.
  ///
  /// In es, this message translates to:
  /// **'Eliminar todos los registros'**
  String get deleteAllRecords;

  /// No description provided for @deleteAllRecordsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Borrar historial manteniendo categorías'**
  String get deleteAllRecordsSubtitle;

  /// No description provided for @resetApp.
  ///
  /// In es, this message translates to:
  /// **'Restablecer aplicación'**
  String get resetApp;

  /// No description provided for @resetAppSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Borrar todo y volver al inicio'**
  String get resetAppSubtitle;

  /// No description provided for @deleteRecordsTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar registros'**
  String get deleteRecordsTitle;

  /// No description provided for @deleteRecordsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar todos los registros?\n\nEsta acción no se puede deshacer. Las categorías se mantendrán.'**
  String get deleteRecordsSubtitle;

  /// No description provided for @allRecordsDeleted.
  ///
  /// In es, this message translates to:
  /// **'Todos los registros eliminados'**
  String get allRecordsDeleted;

  /// No description provided for @deleteAll.
  ///
  /// In es, this message translates to:
  /// **'Eliminar todo'**
  String get deleteAll;

  /// No description provided for @resetAppTitle.
  ///
  /// In es, this message translates to:
  /// **'Restablecer app'**
  String get resetAppTitle;

  /// No description provided for @resetAppSubtext.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres restablecer la aplicación?\n\nEsto eliminará:\n• Todos los registros\n• Todas las categorías personalizadas\n• Toda la configuración\n\nEsta acción NO se puede deshacer.'**
  String get resetAppSubtext;

  /// No description provided for @appReset.
  ///
  /// In es, this message translates to:
  /// **'Aplicación restablecida'**
  String get appReset;

  /// No description provided for @reset.
  ///
  /// In es, this message translates to:
  /// **'Restablecer'**
  String get reset;

  /// No description provided for @security.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get security;

  /// No description provided for @pinSecurityTitle.
  ///
  /// In es, this message translates to:
  /// **'PIN de seguridad'**
  String get pinSecurityTitle;

  /// No description provided for @pinActiveSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Protección activa con PIN de 4 dígitos'**
  String get pinActiveSubtitle;

  /// No description provided for @pinInactiveSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Protege tu app con un PIN'**
  String get pinInactiveSubtitle;

  /// No description provided for @changePinTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar PIN'**
  String get changePinTitle;

  /// No description provided for @changePinSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Modificar tu PIN actual'**
  String get changePinSubtitle;

  /// No description provided for @pinSetupSuccess.
  ///
  /// In es, this message translates to:
  /// **'PIN configurado correctamente'**
  String get pinSetupSuccess;

  /// No description provided for @noPinConfigured.
  ///
  /// In es, this message translates to:
  /// **'No hay PIN configurado'**
  String get noPinConfigured;

  /// No description provided for @pinUpdated.
  ///
  /// In es, this message translates to:
  /// **'PIN actualizado correctamente'**
  String get pinUpdated;

  /// No description provided for @pinDisabled.
  ///
  /// In es, this message translates to:
  /// **'PIN deshabilitado'**
  String get pinDisabled;

  /// No description provided for @disablePinTitle.
  ///
  /// In es, this message translates to:
  /// **'Desactivar PIN'**
  String get disablePinTitle;

  /// No description provided for @disablePinSubtitle.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres desactivar la protección por PIN?\n\nTus datos quedarán sin protección.'**
  String get disablePinSubtitle;

  /// No description provided for @disable.
  ///
  /// In es, this message translates to:
  /// **'Desactivar'**
  String get disable;

  /// No description provided for @day.
  ///
  /// In es, this message translates to:
  /// **'Día'**
  String get day;

  /// No description provided for @week.
  ///
  /// In es, this message translates to:
  /// **'Semana'**
  String get week;

  /// No description provided for @month.
  ///
  /// In es, this message translates to:
  /// **'Mes'**
  String get month;

  /// No description provided for @specificMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes específico'**
  String get specificMonth;

  /// No description provided for @specificDay.
  ///
  /// In es, this message translates to:
  /// **'Día específico'**
  String get specificDay;

  /// No description provided for @distributionByCategory.
  ///
  /// In es, this message translates to:
  /// **'Distribución por categoría'**
  String get distributionByCategory;

  /// No description provided for @categoryDetails.
  ///
  /// In es, this message translates to:
  /// **'Detalle por categoría'**
  String get categoryDetails;

  /// No description provided for @ofTotal.
  ///
  /// In es, this message translates to:
  /// **'del total'**
  String get ofTotal;

  /// No description provided for @selectMonth.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar mes'**
  String get selectMonth;

  /// No description provided for @year.
  ///
  /// In es, this message translates to:
  /// **'Año'**
  String get year;

  /// No description provided for @noDataForPeriod.
  ///
  /// In es, this message translates to:
  /// **'No hay datos para este período'**
  String get noDataForPeriod;

  /// No description provided for @january.
  ///
  /// In es, this message translates to:
  /// **'Enero'**
  String get january;

  /// No description provided for @february.
  ///
  /// In es, this message translates to:
  /// **'Febrero'**
  String get february;

  /// No description provided for @march.
  ///
  /// In es, this message translates to:
  /// **'Marzo'**
  String get march;

  /// No description provided for @april.
  ///
  /// In es, this message translates to:
  /// **'Abril'**
  String get april;

  /// No description provided for @may.
  ///
  /// In es, this message translates to:
  /// **'Mayo'**
  String get may;

  /// No description provided for @june.
  ///
  /// In es, this message translates to:
  /// **'Junio'**
  String get june;

  /// No description provided for @july.
  ///
  /// In es, this message translates to:
  /// **'Julio'**
  String get july;

  /// No description provided for @august.
  ///
  /// In es, this message translates to:
  /// **'Agosto'**
  String get august;

  /// No description provided for @september.
  ///
  /// In es, this message translates to:
  /// **'Septiembre'**
  String get september;

  /// No description provided for @october.
  ///
  /// In es, this message translates to:
  /// **'Octubre'**
  String get october;

  /// No description provided for @november.
  ///
  /// In es, this message translates to:
  /// **'Noviembre'**
  String get november;

  /// No description provided for @december.
  ///
  /// In es, this message translates to:
  /// **'Diciembre'**
  String get december;

  /// No description provided for @monday.
  ///
  /// In es, this message translates to:
  /// **'Lunes'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In es, this message translates to:
  /// **'Martes'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In es, this message translates to:
  /// **'Miércoles'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In es, this message translates to:
  /// **'Jueves'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In es, this message translates to:
  /// **'Viernes'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In es, this message translates to:
  /// **'Sábado'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In es, this message translates to:
  /// **'Domingo'**
  String get sunday;

  /// No description provided for @about.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get about;

  /// No description provided for @version.
  ///
  /// In es, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @openSourceProject.
  ///
  /// In es, this message translates to:
  /// **'Proyecto Open Source'**
  String get openSourceProject;

  /// No description provided for @openSourceDescription.
  ///
  /// In es, this message translates to:
  /// **'Este proyecto es de codigo abierto. Podes ver el repositorio en'**
  String get openSourceDescription;

  /// No description provided for @suggestions.
  ///
  /// In es, this message translates to:
  /// **'Sugerencias'**
  String get suggestions;

  /// No description provided for @creator.
  ///
  /// In es, this message translates to:
  /// **'Creador'**
  String get creator;

  /// No description provided for @supportProject.
  ///
  /// In es, this message translates to:
  /// **'Apoya el proyecto'**
  String get supportProject;

  /// No description provided for @donateUala.
  ///
  /// In es, this message translates to:
  /// **'Si quierés apoyar podés donar por Ualá y Paypal'**
  String get donateUala;

  /// No description provided for @aliasCopied.
  ///
  /// In es, this message translates to:
  /// **'Alias copiada'**
  String get aliasCopied;

  /// No description provided for @features.
  ///
  /// In es, this message translates to:
  /// **'Características'**
  String get features;

  /// No description provided for @feature1.
  ///
  /// In es, this message translates to:
  /// **'Gestión de dinero fisico y digital'**
  String get feature1;

  /// No description provided for @feature2.
  ///
  /// In es, this message translates to:
  /// **'Categorias personalizables'**
  String get feature2;

  /// No description provided for @feature3.
  ///
  /// In es, this message translates to:
  /// **'Historial completo de movimientos'**
  String get feature3;

  /// No description provided for @feature4.
  ///
  /// In es, this message translates to:
  /// **'Estadisticas detalladas'**
  String get feature4;

  /// No description provided for @feature5.
  ///
  /// In es, this message translates to:
  /// **'Exportación e importación de datos'**
  String get feature5;

  /// No description provided for @feature6.
  ///
  /// In es, this message translates to:
  /// **'Retroalimentación y soporte'**
  String get feature6;

  /// No description provided for @dataStoredLocally.
  ///
  /// In es, this message translates to:
  /// **'Tus datos se guardan localmente en tu dispositivo'**
  String get dataStoredLocally;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @deleteCategory.
  ///
  /// In es, this message translates to:
  /// **'Eliminar categoría'**
  String get deleteCategory;

  /// No description provided for @currentPin.
  ///
  /// In es, this message translates to:
  /// **'PIN actual'**
  String get currentPin;

  /// No description provided for @confirmPin.
  ///
  /// In es, this message translates to:
  /// **'Confirmar PIN'**
  String get confirmPin;

  /// No description provided for @changePin.
  ///
  /// In es, this message translates to:
  /// **'Cambiar PIN'**
  String get changePin;

  /// No description provided for @createPin.
  ///
  /// In es, this message translates to:
  /// **'Crear PIN'**
  String get createPin;

  /// No description provided for @enterCurrentPin.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu PIN actual'**
  String get enterCurrentPin;

  /// No description provided for @confirmNewPin.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu nuevo PIN'**
  String get confirmNewPin;

  /// No description provided for @createPinDigits.
  ///
  /// In es, this message translates to:
  /// **'Crea un PIN de 4 dígitos'**
  String get createPinDigits;

  /// No description provided for @biometricUnlock.
  ///
  /// In es, this message translates to:
  /// **'Desbloqueo biométrico'**
  String get biometricUnlock;

  /// No description provided for @useFingerprintOrFace.
  ///
  /// In es, this message translates to:
  /// **'Usa huella o Face ID'**
  String get useFingerprintOrFace;

  /// No description provided for @incorrectPin.
  ///
  /// In es, this message translates to:
  /// **'PIN incorrecto'**
  String get incorrectPin;

  /// No description provided for @pinsDoNotMatch.
  ///
  /// In es, this message translates to:
  /// **'Los PINs no coinciden'**
  String get pinsDoNotMatch;

  /// No description provided for @biometricAuthReason.
  ///
  /// In es, this message translates to:
  /// **'Usa tu huella o Face ID para ingresar'**
  String get biometricAuthReason;

  /// No description provided for @enterPinToContinue.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu PIN para continuar'**
  String get enterPinToContinue;

  /// No description provided for @failedAttempts.
  ///
  /// In es, this message translates to:
  /// **'Intentos fallidos: {count}'**
  String failedAttempts(Object count);

  /// No description provided for @tooManyAttempts.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos'**
  String get tooManyAttempts;

  /// No description provided for @tooManyAttemptsMessage.
  ///
  /// In es, this message translates to:
  /// **'Has fallado 5 intentos. La app se cerrará.'**
  String get tooManyAttemptsMessage;

  /// No description provided for @understood.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get understood;

  /// No description provided for @quickDepositWithdrawal.
  ///
  /// In es, this message translates to:
  /// **'Ingreso/Retiro Rápido'**
  String get quickDepositWithdrawal;

  /// No description provided for @currentBalance.
  ///
  /// In es, this message translates to:
  /// **'Saldo actual'**
  String get currentBalance;

  /// No description provided for @quickAmounts.
  ///
  /// In es, this message translates to:
  /// **'Cantidades rápidas'**
  String get quickAmounts;

  /// No description provided for @customAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto personalizado'**
  String get customAmount;

  /// No description provided for @enterAmountOrSelectQuick.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el monto o selecciona uno rápido arriba'**
  String get enterAmountOrSelectQuick;

  /// No description provided for @enterAmount.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un monto'**
  String get enterAmount;

  /// No description provided for @enterValidAmount.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un monto válido'**
  String get enterValidAmount;

  /// No description provided for @selectCategory.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una categoría'**
  String get selectCategory;

  /// No description provided for @descriptionOptional.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get descriptionOptional;

  /// No description provided for @descriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Compras del súper, pago de servicios...'**
  String get descriptionHint;

  /// No description provided for @makeDeposit.
  ///
  /// In es, this message translates to:
  /// **'Depositar'**
  String get makeDeposit;

  /// No description provided for @makeWithdrawal.
  ///
  /// In es, this message translates to:
  /// **'Retirar'**
  String get makeWithdrawal;

  /// No description provided for @transactionCompleted.
  ///
  /// In es, this message translates to:
  /// **'{type} de \${amount} realizado'**
  String transactionCompleted(String type, String amount);

  /// No description provided for @saving.
  ///
  /// In es, this message translates to:
  /// **'Pensando...'**
  String get saving;

  /// No description provided for @quick.
  ///
  /// In es, this message translates to:
  /// **'rapido de'**
  String get quick;

  /// No description provided for @newRecord.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Registro'**
  String get newRecord;

  /// No description provided for @operationType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de operación'**
  String get operationType;

  /// No description provided for @amounts.
  ///
  /// In es, this message translates to:
  /// **'Montos'**
  String get amounts;

  /// No description provided for @enterAtLeastOneAmount.
  ///
  /// In es, this message translates to:
  /// **'Ingresa al menos un monto'**
  String get enterAtLeastOneAmount;

  /// No description provided for @descriptionHintRecord.
  ///
  /// In es, this message translates to:
  /// **'Ej: Ahorro mensual, gastos varios...'**
  String get descriptionHintRecord;

  /// No description provided for @additionalNotes.
  ///
  /// In es, this message translates to:
  /// **'Notas adicionales(opcional)'**
  String get additionalNotes;

  /// No description provided for @additionalNotesHint.
  ///
  /// In es, this message translates to:
  /// **'Informacion extra...'**
  String get additionalNotesHint;

  /// No description provided for @update.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get update;

  /// No description provided for @mustEnterAtLeastOneAmount.
  ///
  /// In es, this message translates to:
  /// **'Al menos ingresa un monto'**
  String get mustEnterAtLeastOneAmount;

  /// No description provided for @depositUpper.
  ///
  /// In es, this message translates to:
  /// **'DEPÓSITO'**
  String get depositUpper;

  /// No description provided for @withdrawalUpper.
  ///
  /// In es, this message translates to:
  /// **'RETIRO'**
  String get withdrawalUpper;

  /// No description provided for @systemLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma del sistema'**
  String get systemLanguage;

  /// No description provided for @system.
  ///
  /// In es, this message translates to:
  /// **'sistema'**
  String get system;

  /// No description provided for @systemDefault.
  ///
  /// In es, this message translates to:
  /// **'predeterminado del sistema'**
  String get systemDefault;

  /// No description provided for @users.
  ///
  /// In es, this message translates to:
  /// **'Usuarios'**
  String get users;

  /// No description provided for @addUser.
  ///
  /// In es, this message translates to:
  /// **'Agregar usuario'**
  String get addUser;

  /// No description provided for @enterUserName.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el nombre del usuario'**
  String get enterUserName;

  /// No description provided for @create.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get create;

  /// No description provided for @deleteUser.
  ///
  /// In es, this message translates to:
  /// **'Eliminar usuario'**
  String get deleteUser;

  /// No description provided for @deleteUserConfirmation.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que deseas eliminar al usuario'**
  String get deleteUserConfirmation;

  /// No description provided for @userCreated.
  ///
  /// In es, this message translates to:
  /// **'Usuario creado'**
  String get userCreated;

  /// No description provided for @userDeleted.
  ///
  /// In es, this message translates to:
  /// **'Usuario eliminado'**
  String get userDeleted;

  /// No description provided for @currentUser.
  ///
  /// In es, this message translates to:
  /// **'Usuario actual'**
  String get currentUser;

  /// No description provided for @switchedTo.
  ///
  /// In es, this message translates to:
  /// **'Cambiado a'**
  String get switchedTo;

  /// No description provided for @takePhoto.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto'**
  String get takePhoto;

  /// No description provided for @selectFromGallery.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar de la galería'**
  String get selectFromGallery;

  /// No description provided for @removePhoto.
  ///
  /// In es, this message translates to:
  /// **'Eliminar foto'**
  String get removePhoto;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In es, this message translates to:
  /// **'Foto de perfil actualizada'**
  String get profilePhotoUpdated;

  /// No description provided for @photoRemoved.
  ///
  /// In es, this message translates to:
  /// **'Foto eliminada'**
  String get photoRemoved;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @principal.
  ///
  /// In es, this message translates to:
  /// **'Principal'**
  String get principal;

  /// No description provided for @accounts.
  ///
  /// In es, this message translates to:
  /// **'Cuentas'**
  String get accounts;

  /// No description provided for @userManagement.
  ///
  /// In es, this message translates to:
  /// **'Gestión de Usuarios'**
  String get userManagement;

  /// No description provided for @manageUsersAndWallets.
  ///
  /// In es, this message translates to:
  /// **'Gestiona usuarios y cambia entre diferentes carteras.'**
  String get manageUsersAndWallets;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
