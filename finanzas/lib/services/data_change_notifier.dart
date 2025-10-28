import 'package:flutter/foundation.dart';

/// Notificador global para cambios en los datos
/// Permite que diferentes partes de la app reaccionen a cambios en tiempo real
class DataChangeNotifier extends ChangeNotifier {
  static final DataChangeNotifier _instance = DataChangeNotifier._internal();
  factory DataChangeNotifier() => _instance;
  DataChangeNotifier._internal();

  int _changeCounter = 0;
  int get changeCounter => _changeCounter;

  /// Notifica que los datos han cambiado (registros, metas, etc.)
  void notifyDataChanged() {
    _changeCounter++;
    notifyListeners();
    debugPrint('🔄 Datos actualizados (evento #$_changeCounter)');
  }

  /// Resetear el contador (opcional, para debug)
  void reset() {
    _changeCounter = 0;
    notifyListeners();
  }
}