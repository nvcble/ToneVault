import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/values/control_value_label.dart';

void main() {
  group('formatControlValue', () {
    test('reads a clock knob as a position', () {
      expect(formatControlValue(0.25, type: ControlType.clock), '9:30');
    });

    test('reads a percentage with its sign', () {
      expect(formatControlValue(70, type: ControlType.percentage), '70%');
      expect(formatControlValue(0, type: ControlType.percentage), '0%');
    });

    test('appends the unit of a numeric control', () {
      expect(
        formatControlValue(7.5, type: ControlType.numeric, unit: 'ms'),
        '7.5 ms',
      );
      expect(formatControlValue(8, type: ControlType.numeric), '8');
    });

    test('ignores a unit on types that carry their own notation', () {
      expect(
        formatControlValue(0.5, type: ControlType.clock, unit: 'ms'),
        '12:00',
      );
      expect(
        formatControlValue(50, type: ControlType.percentage, unit: 'ms'),
        '50%',
      );
    });

    test('reads a toggle as on or off', () {
      expect(formatControlValue(0, type: ControlType.toggle), 'Off');
      expect(formatControlValue(1, type: ControlType.toggle), 'On');
    });

    test('reads a selection as the name of its position', () {
      expect(
        formatControlValue(
          1,
          type: ControlType.selection,
          options: const ['Chorus', 'Vibrato'],
        ),
        'Vibrato',
      );
    });

    test('still reads a selection whose options were shortened', () {
      expect(
        formatControlValue(
          2,
          type: ControlType.selection,
          options: const ['Chorus', 'Vibrato'],
        ),
        'Position 3',
      );
    });
  });

  group('formatControlNumber', () {
    test('drops a trailing zero decimal', () {
      expect(formatControlNumber(8), '8');
      expect(formatControlNumber(8.5), '8.5');
      expect(formatControlNumber(8.05), '8.05');
    });

    test('keeps floating point noise off the screen', () {
      expect(formatControlNumber(0.1 + 0.2), '0.3');
    });
  });

  group('formatControlRange', () {
    test('describes a clock sweep by its end stops', () {
      expect(
        formatControlRange(type: ControlType.clock, minValue: 0, maxValue: 1),
        '7:00 – 5:00',
      );
    });

    test('signs a percentage range once, not twice', () {
      expect(
        formatControlRange(
          type: ControlType.percentage,
          minValue: 0,
          maxValue: 100,
        ),
        '0 – 100%',
      );
    });

    test('puts the unit after a numeric range', () {
      expect(
        formatControlRange(
          type: ControlType.numeric,
          minValue: 0,
          maxValue: 10,
          unit: 'dB',
        ),
        '0 – 10 dB',
      );
    });

    test('names both states of a toggle', () {
      expect(
        formatControlRange(type: ControlType.toggle, minValue: 0, maxValue: 1),
        'Off / On',
      );
    });

    test('lists the positions of a selection', () {
      expect(
        formatControlRange(
          type: ControlType.selection,
          minValue: 0,
          maxValue: 1,
          options: const ['Chorus', 'Vibrato'],
        ),
        'Chorus / Vibrato',
      );
    });

    test('says so when a selection has no positions yet', () {
      expect(
        formatControlRange(
          type: ControlType.selection,
          minValue: 0,
          maxValue: 1,
        ),
        'No positions yet',
      );
    });
  });
}
