import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/shared/widgets/knob_dial.dart';

/// Turning a knob: where a bearing on the face lands on the 7:00-5:00 sweep.
void main() {
  const size = 200.0;
  double? turnedTo;

  Future<void> pumpKnob(
    WidgetTester tester, {
    double value = 0.5,
    int? divisions,
    bool enabled = true,
  }) async {
    turnedTo = null;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: KnobDial(
              value: value,
              size: size,
              divisions: divisions,
              onChanged: enabled ? (changed) => turnedTo = changed : null,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Drags from the centre of the knob out towards [bearing], which is where a
  /// finger placing the pointer ends up.
  Future<void> turn(WidgetTester tester, Offset bearing) async {
    final centre = tester.getCenter(find.byType(KnobDial));
    await tester.dragFrom(centre, bearing * (size / 2 * 0.8));
    await tester.pumpAndSettle();
  }

  testWidgets('reads straight up as the middle of the sweep', (tester) async {
    await pumpKnob(tester);

    await turn(tester, const Offset(0, -1));

    expect(turnedTo, closeTo(0.5, 0.001));
  });

  testWidgets('reads the end stops at 7:00 and 5:00', (tester) async {
    await pumpKnob(tester);

    // 7:00 is 150 degrees back from straight up: down and to the left.
    await turn(tester, const Offset(-0.5, 0.866));
    expect(turnedTo, closeTo(0, 0.001));

    await turn(tester, const Offset(0.5, 0.866));
    expect(turnedTo, closeTo(1, 0.001));
  });

  testWidgets('holds a finger below the knob at the nearer end stop', (
    tester,
  ) async {
    await pumpKnob(tester);

    // Straight down is not a position the knob has.
    await turn(tester, const Offset(-0.1, 1));

    expect(turnedTo, 0);
  });

  testWidgets('snaps to its notches', (tester) async {
    // 20 notches across the sweep is one per half hour.
    await pumpKnob(tester, divisions: 20);

    // A little past straight up still reads as 12:00 rather than 12:07.
    await turn(tester, const Offset(0.06, -1));

    expect(turnedTo, 0.5);
  });

  testWidgets('turns nowhere while a save is in flight', (tester) async {
    await pumpKnob(tester, enabled: false);

    await turn(tester, const Offset(0, -1));

    expect(turnedTo, isNull);
  });
}
