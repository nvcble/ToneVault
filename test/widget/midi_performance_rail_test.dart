import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/midi_parameter_names.dart';
import 'package:tone_vault/features/midi/widgets/midi_performance_rail.dart';
import 'package:tone_vault/features/midi/widgets/midi_trigger_controls.dart';

/// The column of controls beside the patch grid: scenes, tap tempo and the two
/// assignable footswitches.
void main() {
  Future<void> pump(
    WidgetTester tester, {
    bool connected = true,
    Set<String> switchesOn = const {},
    void Function(String name, bool on)? onToggleSwitch,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MidiPerformanceRail(
            onSelectPatch: () {},
            selectedScene: 1,
            onSelectScene: connected ? (_) {} : null,
            onTapTempo: connected ? () {} : null,
            switchesOn: switchesOn,
            onToggleSwitch: connected
                ? (onToggleSwitch ?? (_, _) {})
                : null,
          ),
        ),
      ),
    );
  }

  MidiTriggerButton buttonLabelled(WidgetTester tester, String label) =>
      tester.widget(find.widgetWithText(MidiTriggerButton, label));

  testWidgets('offers every performance control in one column', (tester) async {
    await pump(tester);

    expect(find.text('Select Patch'), findsOneWidget);
    expect(find.text('Scene 1'), findsOneWidget);
    expect(find.text('Tap tempo'), findsOneWidget);
    expect(find.text(MidiParameterNames.switchA), findsOneWidget);
    expect(find.text(MidiParameterNames.switchB), findsOneWidget);
  });

  testWidgets('a disconnected device disables everything that sends', (
    tester,
  ) async {
    await pump(tester, connected: false);

    expect(buttonLabelled(tester, 'Scene 1').onPressed, isNull);
    expect(buttonLabelled(tester, 'Tap tempo').onPressed, isNull);
    expect(buttonLabelled(tester, MidiParameterNames.switchA).onPressed, isNull);
    // Going off to find a patch sends nothing, so it works either way.
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Select Patch'),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('a latched switch shows filled, and the other outlined', (
    tester,
  ) async {
    await pump(tester, switchesOn: {MidiParameterNames.switchA});

    expect(buttonLabelled(tester, MidiParameterNames.switchA).selected, isTrue);
    expect(
      buttonLabelled(tester, MidiParameterNames.switchB).selected,
      isFalse,
    );
  });

  testWidgets('tapping a switch asks for the state it is not already in', (
    tester,
  ) async {
    final toggles = <(String, bool)>[];
    await pump(
      tester,
      switchesOn: {MidiParameterNames.switchA},
      onToggleSwitch: (name, on) => toggles.add((name, on)),
    );

    await tester.tap(find.text(MidiParameterNames.switchA));
    await tester.tap(find.text(MidiParameterNames.switchB));

    expect(toggles, [
      (MidiParameterNames.switchA, false),
      (MidiParameterNames.switchB, true),
    ]);
  });
}
