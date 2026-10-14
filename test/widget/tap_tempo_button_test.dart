import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/features/midi/widgets/tap_tempo_button.dart';

/// Tap tempo on the control page: every tap goes out, and the tempo the taps
/// imply reads back on the button.
void main() {
  final start = DateTime(2026, 1, 1, 12);

  testWidgets('sends on every tap and shows the tempo they imply', (
    tester,
  ) async {
    var taps = 0;
    var now = start;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TapTempoButton(onTap: () => taps++, now: () => now),
        ),
      ),
    );

    await tester.tap(find.text('Tap tempo'));
    await tester.pump();
    // One tap is no interval, so there is still nothing to show.
    expect(find.text('Tap tempo'), findsOneWidget);

    now = start.add(const Duration(milliseconds: 500));
    await tester.tap(find.text('Tap tempo'));
    await tester.pump();

    expect(taps, 2);
    expect(find.text('Tap · 120 BPM'), findsOneWidget);
  });

  testWidgets('a null callback disables it, so nothing is counted', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TapTempoButton(onTap: null)),
      ),
    );

    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Tap tempo'),
          )
          .onPressed,
      isNull,
    );
  });
}
