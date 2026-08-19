import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/features/controls/providers/control_providers.dart';
import 'package:tone_vault/features/controls/widgets/control_list_view.dart';

/// The controls tab of a pedal, given its list directly.
///
/// What the repository stores and how it orders rows is covered by
/// control_repository_test.dart and control_ordering_test.dart; here the only
/// question is whether a control the app has never heard of lists correctly.
void main() {
  const pedalId = 7;

  PedalControl control({
    required int id,
    required String name,
    required ControlType type,
    double minValue = 0,
    double maxValue = 1,
    double? defaultValue,
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
      defaultValue: defaultValue,
      unit: unit,
      options: options,
      displayOrder: displayOrder,
    );
  }

  Future<void> pumpList(
    WidgetTester tester,
    Stream<List<PedalControl>> controls,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          controlListProvider(pedalId).overrideWith((ref) => controls),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ControlListView(pedalId: pedalId)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('explains what controls are for when the pedal has none', (
    tester,
  ) async {
    await pumpList(tester, Stream.value(const []));

    expect(find.text('No controls yet'), findsOne);
    // Adding one is the only thing to do here, so the button is on screen even
    // with an empty list.
    expect(find.widgetWithText(FilledButton, 'Add control'), findsOne);
  });

  testWidgets('summarises each control by what it accepts', (tester) async {
    await pumpList(
      tester,
      Stream.value([
        control(
          id: 1,
          name: 'Volume',
          type: ControlType.clock,
          defaultValue: 0.5,
        ),
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
    );

    // Every reading rule comes from the row's own type, so five unrelated
    // controls list side by side without the list knowing which is which.
    expect(find.text('Clock knob · 7:00 – 5:00 · default 12:00'), findsOne);
    expect(find.text('Percentage · 0 – 100%'), findsOne);
    expect(find.text('Numeric · 0 – 2000 ms'), findsOne);
    expect(find.text('Selection · Bright / Dark'), findsOne);
    expect(find.text('Toggle · Off / On'), findsOne);
  });

  testWidgets('gives every control its own drag handle', (tester) async {
    await pumpList(
      tester,
      Stream.value([
        control(id: 1, name: 'Volume', type: ControlType.clock),
        control(id: 2, name: 'Tone', type: ControlType.clock, displayOrder: 1),
      ]),
    );

    // The row itself opens the control for editing, so dragging needs a handle
    // of its own rather than a long press that would fight the tap.
    expect(find.byIcon(Icons.drag_handle), findsExactly(2));
  });

  testWidgets('keeps a failure readable', (tester) async {
    await pumpList(
      tester,
      Stream<List<PedalControl>>.error(Exception('disk gone')),
    );

    expect(find.text('Could not load the controls'), findsOne);
    expect(find.textContaining('disk gone'), findsNothing);
  });
}
