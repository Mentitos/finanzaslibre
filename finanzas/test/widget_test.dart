import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finanzas/main.dart';

void main() {
  testWidgets('App loads without errors', (WidgetTester tester) async {
    // Proveer el parámetro requerido
    await tester.pumpWidget(const MyApp(isDarkMode: false));
    await tester.pumpAndSettle();

    // Verificar que la app cargó correctamente
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}