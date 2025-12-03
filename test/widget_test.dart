// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:shorebird_test_app/app.dart';
import 'package:shorebird_test_app/config/app_config.dart';
import 'package:shorebird_test_app/core/config/environment_config.dart';

void main() {
  // Setup: Initialize test environment before running tests
  setUpAll(() async {
    // Load test environment variables
    await dotenv.load(fileName: 'dev.env');
    await EnvironmentConfig.initialize(Environment.dev);
  });

  testWidgets('Shorebird Test App loads and displays correctly',
      (WidgetTester tester) async {
    // Create test config
    final testConfig = AppConfig(
      environment: Environment.dev,
      appName: 'Shorebird Test Dev',
      apiBaseUrl: 'https://api-dev.example.com',
      websocketUrl: 'wss://socket-dev.example.com',
      primaryColor: Colors.blue,
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(ShorebirdTestApp(config: testConfig));
    await tester.pumpAndSettle();

    // Verify that the app title is displayed (uses config.appName with emoji prefix)
    expect(find.text('🔄 Shorebird Test Dev'), findsOneWidget);

    // Verify that welcome message is displayed (updated for patch)
    expect(find.textContaining('Patch Update Applied'), findsOneWidget);

    // Verify that patch status section exists
    expect(find.text('Patch Status'), findsOneWidget);

    // Verify that environment badge is displayed (format: "Environment: dev")
    expect(find.textContaining('Environment:'), findsOneWidget);
    expect(find.textContaining('dev'), findsAtLeastNWidgets(1));

    // Verify that app version section exists (will show "Loading..." initially)
    expect(find.text('App Version'), findsOneWidget);
  });

  testWidgets('Counter button can be tapped', (WidgetTester tester) async {
    // Create test config
    final testConfig = AppConfig(
      environment: Environment.dev,
      appName: 'Shorebird Test Dev',
      apiBaseUrl: 'https://api-dev.example.com',
      websocketUrl: 'wss://socket-dev.example.com',
      primaryColor: Colors.blue,
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(ShorebirdTestApp(config: testConfig));
    await tester.pumpAndSettle();

    // Find the counter button by icon (updated to star icon)
    final counterButton = find.byIcon(Icons.star);
    expect(counterButton, findsOneWidget);

    // Scroll to ensure button is visible
    await tester.ensureVisible(counterButton);
    await tester.pumpAndSettle();

    // Tap the counter button
    await tester.tap(counterButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Verify button still exists after tap (state changed)
    expect(counterButton, findsOneWidget);
  });

  testWidgets('Test interactions section displays correctly',
      (WidgetTester tester) async {
    // Create test config
    final testConfig = AppConfig(
      environment: Environment.dev,
      appName: 'Shorebird Test Dev',
      apiBaseUrl: 'https://api-dev.example.com',
      websocketUrl: 'wss://socket-dev.example.com',
      primaryColor: Colors.blue,
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(ShorebirdTestApp(config: testConfig));
    await tester.pumpAndSettle();

    // Verify the updated section title
    expect(find.textContaining('PATCHED VERSION'), findsOneWidget);

    // Verify the updated description text
    expect(find.textContaining('updated via Shorebird patch'), findsOneWidget);
  });

  testWidgets('App displays environment-specific configuration',
      (WidgetTester tester) async {
    // Test with staging config
    final stagingConfig = AppConfig(
      environment: Environment.staging,
      appName: 'Shorebird Test Staging',
      apiBaseUrl: 'https://api-staging.example.com',
      websocketUrl: 'wss://socket-staging.example.com',
      primaryColor: Colors.orange,
    );

    await tester.pumpWidget(ShorebirdTestApp(config: stagingConfig));
    await tester.pumpAndSettle();

    // Verify staging app name (with emoji prefix)
    expect(find.text('🔄 Shorebird Test Staging'), findsOneWidget);

    // Verify environment badge shows staging
    expect(find.textContaining('Environment:'), findsOneWidget);
    expect(find.textContaining('staging'), findsAtLeastNWidgets(1));
  });
}
