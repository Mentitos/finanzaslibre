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

  /// No description provided for @addRecord.
  ///
  /// In es, this message translates to:
  /// **'Agregar Registro'**
  String get addRecord;

  /// No description provided for @deleteRecord.
  ///
  /// In es, this message translates to:
  /// **'Eliminar registro'**
  String get deleteRecord;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

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

  /// No description provided for @searchRecords.
  ///
  /// In es, this message translates to:
  /// **'Buscar registros...'**
  String get searchRecords;

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

  /// No description provided for @category.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get category;

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
  /// **'¿Eliminar'**
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

  /// No description provided for @deleteCategory.
  ///
  /// In es, this message translates to:
  /// **'Eliminar categoría'**
  String get deleteCategory;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar la categoría'**
  String get deleteCategoryConfirm;

  /// No description provided for @categoryInUse.
  ///
  /// In es, this message translates to:
  /// **'Categoría en uso'**
  String get categoryInUse;

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

  /// No description provided for @add.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get add;

  /// No description provided for @invalidCategoryName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de categoría inválido'**
  String get invalidCategoryName;

  /// No description provided for @categoryExists.
  ///
  /// In es, this message translates to:
  /// **'La categoría ya existe'**
  String get categoryExists;

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

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settings;

  /// No description provided for @editRecord.
  ///
  /// In es, this message translates to:
  /// **'Editar Registro'**
  String get editRecord;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

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

  /// No description provided for @today.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get today;

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

  /// No description provided for @about.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get about;

  /// No description provided for @version.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get version;

  /// No description provided for @openSourceProject.
  ///
  /// In es, this message translates to:
  /// **'Proyecto Open Source'**
  String get openSourceProject;

  /// No description provided for @openSourceDescription.
  ///
  /// In es, this message translates to:
  /// **'Este proyecto es de código abierto. Podés ver el repositorio en:'**
  String get openSourceDescription;

  /// No description provided for @suggestions.
  ///
  /// In es, this message translates to:
  /// **'Sugerencias:'**
  String get suggestions;

  /// No description provided for @creator.
  ///
  /// In es, this message translates to:
  /// **'Creador:'**
  String get creator;

  /// No description provided for @supportProject.
  ///
  /// In es, this message translates to:
  /// **'Apoya el proyecto:'**
  String get supportProject;

  /// No description provided for @donateUala.
  ///
  /// In es, this message translates to:
  /// **'Si querés apoyar podés donar por Ualá:'**
  String get donateUala;

  /// No description provided for @aliasCopied.
  ///
  /// In es, this message translates to:
  /// **'Alias copiado'**
  String get aliasCopied;

  /// No description provided for @features.
  ///
  /// In es, this message translates to:
  /// **'Características:'**
  String get features;

  /// No description provided for @feature1.
  ///
  /// In es, this message translates to:
  /// **'Gestión de dinero físico y digital'**
  String get feature1;

  /// No description provided for @feature2.
  ///
  /// In es, this message translates to:
  /// **'Categorías personalizadas'**
  String get feature2;

  /// No description provided for @feature3.
  ///
  /// In es, this message translates to:
  /// **'Historial completo de movimientos'**
  String get feature3;

  /// No description provided for @feature4.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas detalladas'**
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
