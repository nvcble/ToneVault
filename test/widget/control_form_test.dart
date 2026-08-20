import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/features/controls/data/control_draft.dart';

import 'control_form_harness.dart';

/// Which fields the form puts on screen, decided by the control type alone.
void main() {
  final harness = ControlFormHarness();

  setUp(harness.reset);

  testWidgets('asks for a type before showing anything that depends on one', (
    tester,
  ) async {
    await harness.pumpForm(tester);

    expect(find.text('Minimum'), findsNothing);
    expect(find.text('Unit'), findsNothing);
    expect(find.text('Positions'), findsNothing);

    await harness.submit(tester);

    expect(find.text('Pick how this control works.'), findsOne);
    expect(harness.submitted, isNull);
  });

  testWidgets('hides the bounds of a type that fixes them itself', (
    tester,
  ) async {
    await harness.pumpForm(tester);
    await harness.pickType(tester, 'Clock knob');

    // A clock knob is always the full 7:00-5:00 sweep, so there is nothing to
    // enter and no way to enter something the clock mapping cannot read.
    expect(find.text('Minimum'), findsNothing);
    expect(find.text('Maximum'), findsNothing);
    expect(find.text('Step'), findsNothing);
    expect(find.text('Unit'), findsNothing);

    await harness.pickType(tester, 'Toggle');

    expect(find.text('Minimum'), findsNothing);
    expect(find.text('Unit'), findsNothing);
  });

  testWidgets('describes a fader by its own marks', (tester) async {
    await harness.pumpForm(tester);
    await harness.pickType(tester, 'Fader');

    // A fader is marked in whatever the pedal chose, so it takes bounds, a step
    // and a unit - 0 to 10 to start from.
    expect(harness.fieldText(tester, 'Minimum'), '0');
    expect(harness.fieldText(tester, 'Maximum'), '10');
    expect(harness.fieldText(tester, 'Step'), '0.5');
    expect(find.text('Unit'), findsOne);

    await harness.enter(tester, 'Name', 'Level');
    await harness.submit(tester);

    expect(harness.submitted?.type, ControlType.fader);
    expect(harness.submitted?.maxValue, 10);
  });

  testWidgets('offers a unit to a numeric control only', (tester) async {
    await harness.pumpForm(tester);
    await harness.pickType(tester, 'Numeric');

    expect(find.text('Minimum'), findsOne);
    expect(find.text('Maximum'), findsOne);
    expect(find.text('Step'), findsOne);
    expect(find.text('Unit'), findsOne);

    // A percentage reads as a percentage, so a unit would only contradict it.
    await harness.pickType(tester, 'Percentage');

    expect(find.text('Minimum'), findsOne);
    expect(find.text('Unit'), findsNothing);
  });

  testWidgets('swaps the bounds of a selection for its positions', (
    tester,
  ) async {
    await harness.pumpForm(tester);
    await harness.pickType(tester, 'Selection');

    expect(find.text('Positions'), findsOne);
    // Two empty rows to start with: a selection with one position is not a
    // choice, so the minimum is what the user is shown.
    expect(find.text('Position 1'), findsOne);
    expect(find.text('Position 2'), findsOne);
    expect(find.text('Minimum'), findsNothing);
    expect(find.text('Maximum'), findsNothing);
  });

  testWidgets('starts each type over on the values the type itself uses', (
    tester,
  ) async {
    await harness.pumpForm(tester);
    await harness.pickType(tester, 'Numeric');
    await harness.enter(tester, 'Minimum', '20');
    await harness.enter(tester, 'Maximum', '2000');
    await harness.enter(tester, 'Unit', 'ms');

    await harness.pickType(tester, 'Percentage');

    // 20-2000 ms means nothing as a percentage, so the percentage domain
    // replaces it rather than being carried over.
    expect(harness.fieldText(tester, 'Minimum'), '0');
    expect(harness.fieldText(tester, 'Maximum'), '100');
    expect(harness.fieldText(tester, 'Step'), '1');
  });

  testWidgets('submits a clock knob on the normalized domain it stores in', (
    tester,
  ) async {
    await harness.pumpForm(tester);
    await harness.enter(tester, 'Name', '  Volume  ');
    await harness.pickType(tester, 'Clock knob');
    await harness.submit(tester);

    final draft = harness.submitted;
    expect(draft?.name, 'Volume');
    expect(draft?.type, ControlType.clock);
    // Clock positions are shown as a clock face but stored as 0..1, so a
    // hidden field still has to produce the domain the mapping expects.
    expect(draft?.minValue, 0);
    expect(draft?.maxValue, 1);
    expect(draft?.step, 0.05);
    expect(draft?.unit, isNull);
  });

  testWidgets('reports a maximum that is not above the minimum', (
    tester,
  ) async {
    await harness.pumpForm(tester);
    await harness.enter(tester, 'Name', 'Level');
    await harness.pickType(tester, 'Numeric');
    await harness.enter(tester, 'Minimum', '10');
    await harness.enter(tester, 'Maximum', '10');
    await harness.submit(tester);

    expect(
      find.text('The maximum has to be greater than the minimum.'),
      findsOne,
    );
    expect(harness.submitted, isNull);
  });

  testWidgets('refuses a selection with fewer than two named positions', (
    tester,
  ) async {
    await harness.pumpForm(tester);
    await harness.enter(tester, 'Name', 'Mode');
    await harness.pickType(tester, 'Selection');
    await harness.enterPosition(tester, 2, 'Bright');
    await harness.submit(tester);

    expect(find.text('Add at least 2 positions.'), findsOne);
    expect(harness.submitted, isNull);
  });

  testWidgets('fills in an existing control and keeps its default value', (
    tester,
  ) async {
    await harness.pumpForm(
      tester,
      initialDraft: const ControlDraft(
        name: 'Delay Time',
        type: ControlType.numeric,
        minValue: 20,
        maxValue: 2000,
        step: 10,
        defaultValue: 400,
        unit: 'ms',
      ),
    );

    expect(harness.fieldText(tester, 'Name'), 'Delay Time');
    expect(harness.fieldText(tester, 'Minimum'), '20');
    expect(harness.fieldText(tester, 'Unit'), 'ms');

    await harness.submit(tester);

    // The form has no default-value editor, so a default set elsewhere has to
    // survive an edit untouched.
    expect(harness.submitted?.defaultValue, 400);
  });

  testWidgets('will not submit twice while a save is in flight', (
    tester,
  ) async {
    await harness.pumpForm(tester, isSaving: true);

    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(find.byType(CircularProgressIndicator), findsOne);
  });
}
