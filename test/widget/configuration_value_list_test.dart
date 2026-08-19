import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/features/configurations/providers/configuration_providers.dart';
import 'package:tone_vault/features/configurations/widgets/configuration_value_list.dart';
import 'package:tone_vault/features/controls/providers/control_providers.dart';

/// Where a pedal is set in one configuration, given the controls and the stored
/// values directly. What the repository writes is covered by
/// configuration_value_test.dart.
void main() {
  const pedalId = 7;
  const configurationId = 3;

  PedalControl control({
    required int id,
    required String name,
    required ControlType type,
    double minValue = 0,
    double maxValue = 1,
    double? step,
    String? unit,
    String? options,
    int displayOrder = 0,
  }) {
    return PedalControl(
      id: id,
      pedalId: pedalId,
      name: name,
      controlType: type,
      minValue: minValue,
      maxValue: maxValue,
      step: step,
      unit: unit,
      options: options,
      displayOrder: displayOrder,
    );
  }

  Future<void> pumpList(
    WidgetTester tester, {
    required Stream<List<PedalControl>> controls,
    required Stream<Map<int, double>> values,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          controlListProvider(pedalId).overrideWith((ref) => controls),
          configurationValuesProvider(
            configurationId,
          ).overrideWith((ref) => values),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ConfigurationValueList(
              pedalId: pedalId,
              configurationId: configurationId,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('reads every control the way its own type is read', (
    tester,
  ) async {
    await pumpList(
      tester,
      controls: Stream.value([
        control(id: 1, name: 'Volume', type: ControlType.clock, step: 0.05),
        control(
          id: 2,
          name: 'Mix',
          type: ControlType.percentage,
          maxValue: 100,
          displayOrder: 1,
        ),
        control(
          id: 3,
          name: 'Delay Time',
          type: ControlType.numeric,
          maxValue: 2000,
          unit: 'ms',
          displayOrder: 2,
        ),
        control(
          id: 4,
          name: 'Mode',
          type: ControlType.selection,
          options: '["Bright","Dark"]',
          displayOrder: 3,
        ),
        control(
          id: 5,
          name: 'Boost',
          type: ControlType.toggle,
          displayOrder: 4,
        ),
      ]),
      values: Stream.value(const {1: 0.75, 2: 70, 3: 400, 4: 1, 5: 1}),
    );

    // One stored number per control, each read through the control's own type.
    // 0.75 is three quarters along the 7:00-5:00 sweep, which is 2:30.
    expect(find.text('2:30'), findsOne);
    expect(find.text('70%'), findsOne);
    expect(find.text('400 ms'), findsOne);
    expect(find.text('Dark'), findsOne);
    expect(find.text('On'), findsOne);
  });

  testWidgets('shows a control with nothing stored as unset', (tester) async {
    await pumpList(
      tester,
      controls: Stream.value([
        control(id: 1, name: 'Volume', type: ControlType.clock),
        // A default is where a control usually sits, not where this
        // configuration says it does.
        control(id: 2, name: 'Tone', type: ControlType.clock, displayOrder: 1),
      ]),
      values: Stream.value(const {1: 0.5}),
    );

    expect(find.text('12:00'), findsOne);
    expect(find.text('Not set'), findsOne);
  });

  testWidgets('lists the controls in the pedal\'s own order', (tester) async {
    await pumpList(
      tester,
      controls: Stream.value([
        control(id: 1, name: 'Volume', type: ControlType.clock),
        control(id: 2, name: 'Tone', type: ControlType.clock, displayOrder: 1),
      ]),
      values: Stream.value(const {}),
    );

    // The list follows the controls as the pedal orders them, so the rows read
    // like the front of the pedal.
    expect(
      tester.getTopLeft(find.text('Volume')).dy,
      lessThan(tester.getTopLeft(find.text('Tone')).dy),
    );
  });

  testWidgets('opens an editor for the control that was tapped', (
    tester,
  ) async {
    await pumpList(
      tester,
      controls: Stream.value([
        control(id: 1, name: 'Volume', type: ControlType.clock, step: 0.05),
      ]),
      values: Stream.value(const {1: 0.5}),
    );

    await tester.tap(find.text('Volume'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Save'), findsOne);
    expect(find.byType(Slider), findsOne);
    // Only offered for a control that has something stored to clear.
    expect(find.widgetWithText(TextButton, 'Clear'), findsOne);
  });

  testWidgets('has nothing to clear on a control that was never set', (
    tester,
  ) async {
    await pumpList(
      tester,
      controls: Stream.value([
        control(id: 1, name: 'Volume', type: ControlType.clock, step: 0.05),
      ]),
      values: Stream.value(const {}),
    );

    await tester.tap(find.text('Volume'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextButton, 'Clear'), findsNothing);
  });

  testWidgets('explains a pedal with no controls to set', (tester) async {
    await pumpList(
      tester,
      controls: Stream.value(const []),
      values: Stream.value(const {}),
    );

    expect(find.text('This pedal has no controls yet'), findsOne);
  });

  testWidgets('keeps a failure readable', (tester) async {
    await pumpList(
      tester,
      controls: Stream.value(const []),
      values: Stream<Map<int, double>>.error(Exception('disk gone')),
    );

    expect(find.text('Could not load these settings'), findsOne);
    expect(find.textContaining('disk gone'), findsNothing);
  });
}
