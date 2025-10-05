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
  /// **'Eliminar Registro'**
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
  /// **'Último Movimiento'**
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
