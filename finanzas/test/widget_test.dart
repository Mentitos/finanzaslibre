import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finanzas/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:finanzas/services/user_manager.dart';
import 'package:finanzas/services/savings_data_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterLocalNotificationsPlatform
    extends FlutterLocalNotificationsPlatform
    with MockPlatformInterfaceMixin {
  Future<bool?> initialize(
    InitializationSettings? initializationSettings, {
    void Function(NotificationResponse)? onDidReceiveNotificationResponse,
    void Function(NotificationResponse)?
    onDidReceiveBackgroundNotificationResponse,
  }) async {
    return true;
  }
}

void main() {
  testWidgets('App loads without errors', (WidgetTester tester) async {
    // Mock Local Notifications
    FlutterLocalNotificationsPlatform.instance =
        MockFlutterLocalNotificationsPlatform();

    // Mock Shared Preferences
    SharedPreferences.setMockInitialValues({});

    // Initialize DataManager and UserManager
    SavingsDataManager.init();
    final dataManager = SavingsDataManager();
    await dataManager.initialize();
    await UserManager.initialize();

    // Proveer el parámetro requerido
    await tester.pumpWidget(MyApp(isDarkMode: false, dataManager: dataManager));

    // Allow initial build
    await tester.pump();

    // Wait for async operations (loading data, update check delay)
    // UpdateService waits 2 seconds, lets wait 3 to be safe
    await tester.pump(const Duration(seconds: 3));

    // Verificar que la app cargó correctamente
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
