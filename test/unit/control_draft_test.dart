import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/features/controls/data/control_draft.dart';

void main() {
  group('ControlDraft.ofType', () {
    test("starts from the type's own domain and step", () {
      final draft = ControlDraft.ofType(ControlType.percentage);

      expect(draft.minValue, 0);
      expect(draft.maxValue, 100);
      expect(draft.step, 1);
    });

    test('carries the name across a change of type', () {
      final draft = ControlDraft.ofType(ControlType.numeric, name: 'Delay');

      expect(draft.name, 'Delay');
      expect(draft.maxValue, 10);
      expect(draft.step, isNull);
    });
  });

  group('normalized', () {
    test('trims the name and drops a blank unit', () {
      // A cleared text field hands back an empty string, which the column would
      // reject: `unit` has a minimum length of one character.
      final normalized = const ControlDraft(
        name: '  Delay time  ',
        type: ControlType.numeric,
        minValue: 0,
        maxValue: 10,
        unit: '   ',
      ).normalized();

      expect(normalized.name, 'Delay time');
      expect(normalized.unit, isNull);
    });

    test('puts a clock knob back on the domain the clock mapping expects', () {
      // A knob stored on 0..10 would read every position wrong.
      final normalized = const ControlDraft(
        name: 'Volume',
        type: ControlType.clock,
        minValue: 0,
        maxValue: 10,
      ).normalized();

      expect(normalized.minValue, 0);
      expect(normalized.maxValue, 1);
    });

    test('holds a toggle to its two states', () {
      final normalized = const ControlDraft(
        name: 'Bright',
        type: ControlType.toggle,
        minValue: -5,
        maxValue: 5,
      ).normalized();

      expect(normalized.minValue, 0);
      expect(normalized.maxValue, 1);
    });

    test('leaves a user-set numeric domain alone', () {
      final normalized = const ControlDraft(
        name: 'Delay',
        type: ControlType.numeric,
        minValue: 20,
        maxValue: 600,
        unit: 'ms',
      ).normalized();

      expect(normalized.minValue, 20);
      expect(normalized.maxValue, 600);
      expect(normalized.unit, 'ms');
    });

    test('derives a selection domain from its positions', () {
      final normalized = const ControlDraft(
        name: 'Mode',
        type: ControlType.selection,
        minValue: 3,
        maxValue: 99,
        options: ['Chorus', ' Vibrato ', '  ', 'Rotary'],
      ).normalized();

      expect(normalized.options, ['Chorus', 'Vibrato', 'Rotary']);
      expect(normalized.minValue, 0);
      expect(normalized.maxValue, 2);
    });

    test('drops positions left behind by a change of type', () {
      final normalized = const ControlDraft(
        name: 'Level',
        type: ControlType.percentage,
        minValue: 0,
        maxValue: 100,
        options: ['Chorus', 'Vibrato'],
      ).normalized();

      expect(normalized.options, isEmpty);
    });
  });
}
