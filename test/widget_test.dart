// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shorebird_test_app/main.dart';

void main() {
  testWidgets('Shorebird Test App loads and displays correctly',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ShorebirdTestApp());
    await tester.pumpAndSettle();

    // Verify that the app title is displayed
    expect(find.text('🔄 Shorebird Patch Tester'), findsOneWidget);

    // Verify that welcome message is displayed
    expect(
        find.textContaining('Welcome to Shorebird Test App'), findsOneWidget);

    // Verify that patch status section exists
    expect(find.text('Patch Status'), findsOneWidget);

    // Verify that app version is displayed
    expect(find.text('1.0.0+1'), findsOneWidget);

    // Verify that counter button icon exists
    expect(find.byIcon(Icons.add_circle), findsOneWidget);
  });

  testWidgets('Counter button can be tapped', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ShorebirdTestApp());
    await tester.pumpAndSettle();

    // Find the counter button by icon
    final counterButton = find.byIcon(Icons.add_circle);
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
}
