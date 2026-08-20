import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Taps a tab in the bottom bar and waits for it to settle.
///
/// Scoped to the [NavigationBar] on purpose: the home tab has cards named after
/// tabs, so a bare text finder matches the card as well as the destination.
Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}
