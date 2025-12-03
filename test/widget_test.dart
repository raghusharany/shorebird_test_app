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

  testWidgets('App loads and displays basic elements',
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

    // Verify that the app title is displayed
    expect(find.text('🔄 Shorebird Test Dev'), findsOneWidget);

    // Verify that environment badge is displayed
    expect(find.textContaining('Environment:'), findsOneWidget);
    expect(find.textContaining('DEV'), findsAtLeastNWidgets(1));

    // Verify that version & patch status section exists
    expect(find.text('Version & Patch Status'), findsOneWidget);

    // Verify that app version section exists
    expect(find.text('App Version'), findsOneWidget);

    // Verify Check for Updates button exists
    expect(find.text('Check for Updates'), findsOneWidget);
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

    // Verify staging app name
    expect(find.text('🔄 Shorebird Test Staging'), findsOneWidget);

    // Verify environment badge shows staging
    expect(find.textContaining('Environment:'), findsOneWidget);
    expect(find.textContaining('STAGING'), findsAtLeastNWidgets(1));
  });
}
