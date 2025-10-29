import 'package:flutter/foundation.dart';

/// Notificador global para cambios en los datos
class DataChangeNotifier extends ChangeNotifier {
  static final DataChangeNotifier _instance = DataChangeNotifier._internal();
  factory DataChangeNotifier() => _instance;
  DataChangeNotifier._internal();

  int _changeCounter = 0;
  int get changeCounter => _changeCounter;

  void notifyDataChanged() {
    _changeCounter++;
    notifyListeners();
    debugPrint('🔄 Datos actualizados (evento #$_changeCounter)');
  }
}