import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/configurations/providers/configuration_providers.dart';
import 'package:tone_vault/features/configurations/widgets/configuration_value_list.dart';
import 'package:tone_vault/features/controls/data/control_group.dart';
import 'package:tone_vault/features/controls/providers/control_providers.dart';
import 'package:tone_vault/shared/widgets/knob_dial.dart';

import '../support/themed_app.dart';

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
    int onPedal = pedalId,
    double minValue = 0,
    double maxValue = 1,
    double? step,
    String? unit,
    String? options,
    int displayOrder = 0,
  }) {
    return PedalControl(
      id: id,
      pedalId: onPedal,
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

  Pedal pedal({required int id, required String name}) => Pedal(
    id: id,
    name: name,
    type: PedalType.analog,
    category: PedalCategory.overdrive,
    status: PedalStatus.active,
    createdAt: DateTime.utc(2026, 8, 20),
    updatedAt: DateTime.utc(2026, 8, 20),
  );

  /// The controls of the pedal being configured, which is every case except a
  /// multi-effects patch.
  List<ControlGroup> own(List<PedalControl> controls) => [
    (owner: pedal(id: pedalId, name: 'Strymon Flint'), controls: controls),
  ];

  Future<void> pumpList(
    WidgetTester tester, {
    required Stream<List<ControlGroup>> groups,
    required Stream<Map<int, double>> values,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settableControlsProvider(pedalId).overrideWith((ref) => groups),
          configurationValuesProvider(
            configurationId,
          ).overrideWith((ref) => values),
        ],
        // The app's own theme, because the editor sheet this list opens has to
        // lay out under the button sizing the app actually ships.
        child: themedApp(
          const ConfigurationValueList(
            pedalId: pedalId,
            configurationId: configurationId,
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
      groups: Stream.value(
        own([
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
      ),
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
      groups: Stream.value(
        own([
          control(id: 1, name: 'Volume', type: ControlType.clock),
          // A default is where a control usually sits, not where this
          // configuration says it does.
          control(
            id: 2,
            name: 'Tone',
            type: ControlType.clock,
            displayOrder: 1,
          ),
        ]),
      ),
      values: Stream.value(const {1: 0.5}),
    );

    expect(find.text('12:00'), findsOne);
    expect(find.text('Not set'), findsOne);
  });

  testWidgets('lists the controls in the pedal\'s own order', (tester) async {
    await pumpList(
      tester,
      groups: Stream.value(
        own([
          control(id: 1, name: 'Volume', type: ControlType.clock),
          control(
            id: 2,
            name: 'Tone',
            type: ControlType.clock,
            displayOrder: 1,
          ),
        ]),
      ),
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
      groups: Stream.value(
        own([
          control(id: 1, name: 'Volume', type: ControlType.clock, step: 0.05),
        ]),
      ),
      values: Stream.value(const {1: 0.5}),
    );

    await tester.tap(find.text('Volume'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Save'), findsOne);
    // A clock control is set by turning a knob, and the sheet has to survive
    // laying its actions out: it used to throw here and leave the screen looking
    // untouched.
    expect(find.byType(KnobDial), findsOne);
    // Only offered for a control that has something stored to clear.
    expect(find.widgetWithText(TextButton, 'Clear'), findsOne);
  });

  testWidgets('has nothing to clear on a control that was never set', (
    tester,
  ) async {
    await pumpList(
      tester,
      groups: Stream.value(
        own([
          control(id: 1, name: 'Volume', type: ControlType.clock, step: 0.05),
        ]),
      ),
      values: Stream.value(const {}),
    );

    await tester.tap(find.text('Volume'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextButton, 'Clear'), findsNothing);
  });

  testWidgets('names the pedal each control on a patch belongs to', (
    tester,
  ) async {
    // A scene of a multi-effects unit: the unit has no controls of its own, and
    // the ones it sets live on the pedals of its patch.
    await pumpList(
      tester,
      groups: Stream.value([
        (
          owner: pedal(id: 11, name: 'Tube Screamer'),
          controls: [
            control(id: 1, name: 'Drive', type: ControlType.clock, onPedal: 11),
          ],
        ),
        (
          owner: pedal(id: 12, name: 'Hall Reverb'),
          controls: [
            control(id: 2, name: 'Decay', type: ControlType.clock, onPedal: 12),
          ],
        ),
      ]),
      values: Stream.value(const {1: 0.5}),
    );

    // Each pedal is named once, above its own controls, so a scene reads down
    // the patch rather than as one flat list of knobs.
    expect(find.text('Tube Screamer'), findsOne);
    expect(find.text('Hall Reverb'), findsOne);
    expect(
      tester.getTopLeft(find.text('Drive')).dy,
      lessThan(tester.getTopLeft(find.text('Hall Reverb')).dy),
    );
    expect(find.text('12:00'), findsOne);
    expect(find.text('Not set'), findsOne);
  });

  testWidgets('does not name the pedal being configured', (tester) async {
    await pumpList(
      tester,
      groups: Stream.value(
        own([control(id: 1, name: 'Volume', type: ControlType.clock)]),
      ),
      values: Stream.value(const {}),
    );

    // Its name is already the title of the screen this list sits on.
    expect(find.text('Strymon Flint'), findsNothing);
  });

  testWidgets('explains a pedal with no controls to set', (tester) async {
    await pumpList(
      tester,
      groups: Stream.value(const []),
      values: Stream.value(const {}),
    );

    expect(find.text('Nothing to set yet'), findsOne);
  });

  testWidgets('keeps a failure readable', (tester) async {
    await pumpList(
      tester,
      groups: Stream.value(const []),
      values: Stream<Map<int, double>>.error(Exception('disk gone')),
    );

    expect(find.text('Could not load these settings'), findsOne);
    expect(find.textContaining('disk gone'), findsNothing);
  });
}
