import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/features/midi/widgets/midi_performance_rail.dart';
import 'package:tone_vault/features/midi/widgets/midi_trigger_controls.dart';

/// The column of controls beside the patch grid: the Pro Scenes, and nothing
/// else - tap tempo and the two footswitches came off, the MG-30 having no CC
/// that reaches them.
void main() {
  Future<void> pump(WidgetTester tester, {bool connected = true}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MidiPerformanceRail(
            selectedScene: 1,
            onSelectScene: connected ? (_) {} : null,
          ),
        ),
      ),
    );
  }

  MidiTriggerButton buttonLabelled(WidgetTester tester, String label) =>
      tester.widget(find.widgetWithText(MidiTriggerButton, label));

  testWidgets('offers the three scenes under one heading', (tester) async {
    await pump(tester);

    expect(find.text('Scenes'), findsOneWidget);
    expect(find.text('Scene 1'), findsOneWidget);
    expect(find.text('Scene 3'), findsOneWidget);
    expect(find.byType(MidiTriggerButton), findsNWidgets(3));
  });

  testWidgets('nothing else is on the rail any more', (tester) async {
    await pump(tester);

    expect(find.text('Select Patch'), findsNothing);
    expect(find.text('Tap tempo'), findsNothing);
    expect(find.text('Switch A'), findsNothing);
    expect(find.text('Switch B'), findsNothing);
  });

  testWidgets('a disconnected device disables every button', (tester) async {
    await pump(tester, connected: false);

    expect(buttonLabelled(tester, 'Scene 1').onPressed, isNull);
    expect(buttonLabelled(tester, 'Scene 2').onPressed, isNull);
    expect(buttonLabelled(tester, 'Scene 3').onPressed, isNull);
  });
}
