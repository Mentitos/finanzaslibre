import 'app_localizations.dart';

extension CategoryTranslations on AppLocalizations {
  String translateCategory(String category) {
    final languageCode = localeName.split('_')[0];
   
    final translations = {
      'es': {
        'General': 'General',
        'Alimentación': 'Alimentación',
        'Transporte': 'Transporte',
        'Entretenimiento': 'Entretenimiento',
        'Salud': 'Salud',
        'Educación': 'Educación',
        'Hogar': 'Hogar',
        'Ropa': 'Ropa',
        'Tecnología': 'Tecnología',
        'Viajes': 'Viajes',
        'Regalos': 'Regalos',
        'Mascotas': 'Mascotas',
        'Servicios': 'Servicios',
        'Otros': 'Otros',
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
        'Alimentación': 'Food',
        'Transporte': 'Transport',
        'Entretenimiento': 'Entertainment',
        'Salud': 'Health',
        'Educación': 'Education',
        'Hogar': 'Home',
        'Ropa': 'Clothing',
        'Tecnología': 'Technology',
        'Viajes': 'Travel',
        'Regalos': 'Gifts',
        'Mascotas': 'Pets',
        'Servicios': 'Services',
        'Otros': 'Others',
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