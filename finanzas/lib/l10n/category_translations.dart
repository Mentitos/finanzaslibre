import 'app_localizations.dart';

extension CategoryTranslations on AppLocalizations {
  String translateCategory(String category) {
    // Extraer código de idioma de localeName (ej: "es_ES" -> "es")
    final languageCode = localeName.split('_')[0];
    
    final translations = {
      'es': {
        'General': 'General',
        'Trabajo': 'Trabajo',
        'Inversión': 'Inversión',
        'Regalo': 'Regalo',
        'Emergencia': 'Emergencia',
        'Freelance': 'Freelance',
        'Bonificación': 'Bonificación',
        'Venta': 'Venta',
        'Ahorro': 'Ahorro',
        'Extra': 'Extra',
      },
      'en': {
        'General': 'General',
        'Trabajo': 'Work',
        'Inversión': 'Investment',
        'Regalo': 'Gift',
        'Emergencia': 'Emergency',
        'Freelance': 'Freelance',
        'Bonificación': 'Bonus',
        'Venta': 'Sale',
        'Ahorro': 'Savings',
        'Extra': 'Extra',
      },
    };

    return translations[languageCode]?[category] ?? category;
  }
}