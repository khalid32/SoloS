// Basic smoke tests for the SoloS app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:solos/main.dart';

void main() {
  testWidgets('Login screen renders on launch', (WidgetTester tester) async {
    await tester.pumpWidget(const SolosApp());

    // The login screen shows the Community Solid Server branding and Log in.
    expect(find.text('Community Solid Server'), findsOneWidget);
    expect(find.text('Log in'), findsWidgets);
  });

  testWidgets('Logging in navigates to the workspace dashboard',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SolosApp());

    // Fill in email + password and submit.
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'alice@example.com');
    await tester.enterText(fields.at(1), 'secret');
    await tester.tap(find.text('Log in').last);
    await tester.pumpAndSettle();

    // The dashboard header and derived WebID should now be visible.
    expect(find.text('SoloS Workspace'), findsOneWidget);
    expect(find.text('Welcome to your Solid OS'), findsOneWidget);
    expect(
      find.textContaining('alice.solidcommunity.net'),
      findsOneWidget,
    );
  });
}
