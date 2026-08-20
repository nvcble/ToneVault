import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/features/configurations/widgets/control_value_editor.dart';
import 'package:tone_vault/shared/widgets/knob_dial.dart';

/// Which input a control gets, decided by the control's own type and nothing
/// else. This is where §10 is enforced: no pedal name reaches this code.
void main() {
  PedalControl control({
    required ControlType type,
    String name = 'Volume',
    double minValue = 0,
    double maxValue = 1,
    double? step,
    String? unit,
    String? options,
  }) {
    return PedalControl(
      id: 1,
      pedalId: 1,
      name: name,
      controlType: type,
      minValue: minValue,
      maxValue: maxValue,
      step: step,
      unit: unit,
      options: options,
      displayOrder: 0,
    );
  }

  double? changedTo;

  Future<void> pumpEditor(
    WidgetTester tester,
    PedalControl control, {
    double? value,
    String? errorText,
    bool enabled = true,
  }) async {
    changedTo = null;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ControlValueEditor(
            control: control,
            value: value,
            errorText: errorText,
            onChanged: enabled ? (changed) => changedTo = changed : null,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('turns a clock knob, snapped to the half hour', (tester) async {
    await pumpEditor(
      tester,
      control(type: ControlType.clock, step: 0.05),
      value: 0.5,
    );

    // 20 notches across the 7:00-5:00 sweep is one per half hour, which is as
    // fine as a real knob can be read.
    expect(tester.widget<KnobDial>(find.byType(KnobDial)).divisions, 20);
    // Read as the clock face and as a position out of 100, never as the 0..1
    // that is stored.
    expect(find.text('12:00'), findsOne);
    expect(find.text('50 of 100'), findsOne);
    expect(find.byType(Slider), findsNothing);
  });

  testWidgets('slides a fader between its own marks', (tester) async {
    await pumpEditor(
      tester,
      control(type: ControlType.fader, name: 'Level', maxValue: 10, step: 0.5),
      value: 7.5,
    );

    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.value, 7.5);
    expect(slider.max, 10);
    expect(slider.divisions, 20);
    // A fader reads as the number beside it, so both ends are plain.
    expect(find.text('0'), findsOne);
    expect(find.text('10'), findsOne);
  });

  testWidgets('slides a percentage between its own bounds', (tester) async {
    await pumpEditor(
      tester,
      control(type: ControlType.percentage, maxValue: 100, step: 1),
      value: 70,
    );

    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.value, 70);
    expect(slider.max, 100);
    expect(find.text('100%'), findsOne);
  });

  testWidgets('opens an unset sweeping control halfway, without saving', (
    tester,
  ) async {
    await pumpEditor(
      tester,
      control(type: ControlType.percentage, maxValue: 100),
    );

    // Somewhere to start from; nothing is stored until Save is tapped.
    expect(tester.widget<Slider>(find.byType(Slider)).value, 50);
    expect(changedTo, isNull);
  });

  testWidgets('types a numeric control rather than sliding it', (tester) async {
    await pumpEditor(
      tester,
      control(
        type: ControlType.numeric,
        name: 'Delay Time',
        maxValue: 2000,
        unit: 'ms',
      ),
      value: 400,
    );

    // 20 to 2000 ms is too wide a range to place a fingertip on.
    expect(find.byType(Slider), findsNothing);
    expect(find.text('400'), findsOne);
    expect(find.text('ms'), findsOne);

    await tester.enterText(find.byType(TextField), '750');
    expect(changedTo, 750);
  });

  testWidgets('reports a typed value that is not a number as unusable', (
    tester,
  ) async {
    await pumpEditor(tester, control(type: ControlType.numeric), value: 5);

    await tester.enterText(find.byType(TextField), '.');

    // Null rather than a guess, so the sheet can refuse to save it.
    expect(changedTo, isNull);
  });

  testWidgets('switches a toggle between its own ends', (tester) async {
    await pumpEditor(tester, control(type: ControlType.toggle), value: 0);

    expect(find.text('Off'), findsOne);
    await tester.tap(find.byType(SwitchListTile));

    expect(changedTo, 1);
  });

  testWidgets('offers one radio per named position of a selection', (
    tester,
  ) async {
    await pumpEditor(
      tester,
      control(
        type: ControlType.selection,
        name: 'Mode',
        maxValue: 2,
        options: '["Bright","Flat","Dark"]',
      ),
      value: 0,
    );

    expect(find.byType(RadioListTile<int>), findsExactly(3));
    await tester.tap(find.text('Dark'));

    // A selection stores which position it is in, so the third is 2.
    expect(changedTo, 2);
  });

  testWidgets('shows a problem a slider has nowhere else to put', (
    tester,
  ) async {
    await pumpEditor(
      tester,
      control(type: ControlType.clock, step: 0.05),
      value: 0.5,
      errorText: 'Volume cannot be set to that.',
    );

    expect(find.text('Volume cannot be set to that.'), findsOne);
  });

  testWidgets('locks every input while a save is in flight', (tester) async {
    await pumpEditor(
      tester,
      control(type: ControlType.toggle),
      value: 0,
      enabled: false,
    );

    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).onChanged,
      isNull,
    );
  });
}
