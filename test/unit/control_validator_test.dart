import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/features/controls/data/control_draft.dart';
import 'package:tone_vault/features/controls/data/control_validator.dart';

void main() {
  group('name', () {
    test('accepts an ordinary control name', () {
      expect(ControlValidator.name('Volume'), isNull);
    });

    test('rejects a name that is only whitespace', () {
      expect(ControlValidator.name('   '), isNotNull);
      expect(ControlValidator.name(null), isNotNull);
    });

    test('rejects a name past the column limit', () {
      final tooLong = 'a' * (ControlValidator.nameMaxLength + 1);

      expect(ControlValidator.name(tooLong), isNotNull);
      expect(
        ControlValidator.name('a' * ControlValidator.nameMaxLength),
        isNull,
      );
    });
  });

  group('unit', () {
    test('treats an empty unit as unset', () {
      expect(ControlValidator.unit(''), isNull);
      expect(ControlValidator.unit(null), isNull);
    });

    test('rejects a unit past the column limit', () {
      expect(
        ControlValidator.unit('a' * (ControlValidator.unitMaxLength + 1)),
        isNotNull,
      );
    });
  });

  group('domain', () {
    test('accepts an increasing range', () {
      expect(ControlValidator.domain(minValue: 20, maxValue: 600), isNull);
    });

    test('rejects a range that does not increase', () {
      expect(ControlValidator.domain(minValue: 1, maxValue: 1), isNotNull);
      expect(ControlValidator.domain(minValue: 5, maxValue: 1), isNotNull);
    });

    test('rejects a bound that is not a plain number', () {
      expect(
        ControlValidator.domain(minValue: 0, maxValue: double.infinity),
        isNotNull,
      );
      expect(
        ControlValidator.domain(minValue: double.nan, maxValue: 1),
        isNotNull,
      );
    });
  });

  group('step', () {
    test('accepts no step at all, meaning continuous', () {
      expect(ControlValidator.step(null, minValue: 0, maxValue: 10), isNull);
    });

    test('rejects a step of zero or less', () {
      expect(ControlValidator.step(0, minValue: 0, maxValue: 10), isNotNull);
      expect(ControlValidator.step(-1, minValue: 0, maxValue: 10), isNotNull);
    });

    test('rejects a step wider than the range it divides', () {
      // A step of 20 across 0..10 leaves a knob with one position.
      expect(ControlValidator.step(20, minValue: 0, maxValue: 10), isNotNull);
      expect(ControlValidator.step(10, minValue: 0, maxValue: 10), isNull);
    });
  });

  group('defaultValue', () {
    test('accepts a value inside the range, and no value at all', () {
      expect(
        ControlValidator.defaultValue(0.5, minValue: 0, maxValue: 1),
        isNull,
      );
      expect(
        ControlValidator.defaultValue(null, minValue: 0, maxValue: 1),
        isNull,
      );
    });

    test('rejects a value the control could never be set to', () {
      expect(
        ControlValidator.defaultValue(1.5, minValue: 0, maxValue: 1),
        isNotNull,
      );
      expect(
        ControlValidator.defaultValue(-1, minValue: 0, maxValue: 1),
        isNotNull,
      );
    });
  });

  group('options', () {
    test('accepts two or more distinct positions', () {
      expect(ControlValidator.options(const ['Chorus', 'Vibrato']), isNull);
    });

    test('rejects a selection that is not a choice', () {
      expect(ControlValidator.options(const []), isNotNull);
      expect(ControlValidator.options(const ['Chorus']), isNotNull);
    });

    test('rejects positions that read the same', () {
      expect(ControlValidator.options(const ['Chorus', 'chorus']), isNotNull);
    });

    test('rejects more positions than a control can show', () {
      final tooMany = [
        for (var index = 0; index <= ControlValidator.maxOptions; index++)
          'Position $index',
      ];

      expect(ControlValidator.options(tooMany), isNotNull);
    });

    test('rejects a position label that cannot be read in a list', () {
      final tooLong = 'a' * (ControlValidator.optionMaxLength + 1);

      expect(ControlValidator.options(['Chorus', tooLong]), isNotNull);
    });
  });

  group('draft', () {
    test('accepts a control that can be stored', () {
      expect(
        ControlValidator.draft(
          ControlDraft.ofType(ControlType.clock, name: 'Volume'),
        ),
        isNull,
      );
    });

    test('reports the missing positions of a selection, not its bounds', () {
      // The bounds of a selection are derived, so complaining about them would
      // point the user at a field they never filled in.
      final problem = ControlValidator.draft(
        const ControlDraft(
          name: 'Mode',
          type: ControlType.selection,
          minValue: 0,
          maxValue: 0,
        ).normalized(),
      );

      expect(problem, contains('positions'));
    });

    test('reports the name before anything else', () {
      final problem = ControlValidator.draft(
        const ControlDraft(
          name: '',
          type: ControlType.numeric,
          minValue: 10,
          maxValue: 0,
        ),
      );

      expect(problem, ControlValidator.name(''));
    });
  });
}
