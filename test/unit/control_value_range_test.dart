import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/features/configurations/data/control_value_range.dart';

/// Where a value editor opens, and how finely it moves. Both are read off the
/// control's own row, which is what keeps the editors free of per-pedal code.
void main() {
  PedalControl control({
    required ControlType type,
    double minValue = 0,
    double maxValue = 1,
    double? step,
    double? defaultValue,
  }) {
    return PedalControl(
      id: 1,
      pedalId: 1,
      name: 'Volume',
      controlType: type,
      minValue: minValue,
      maxValue: maxValue,
      step: step,
      defaultValue: defaultValue,
      displayOrder: 0,
    );
  }

  group('startingValueFor', () {
    test('opens at the control\'s own default when it has one', () {
      expect(
        startingValueFor(control(type: ControlType.clock, defaultValue: 0.25)),
        0.25,
      );
    });

    test('opens a sweeping control halfway through its own domain', () {
      expect(startingValueFor(control(type: ControlType.clock)), 0.5);
      expect(
        startingValueFor(
          control(type: ControlType.numeric, minValue: 20, maxValue: 2000),
        ),
        1010,
      );
    });

    test('opens a switch or a selection on its first position', () {
      // Halfway between off and on is not a position a switch has.
      expect(startingValueFor(control(type: ControlType.toggle)), 0);
      expect(
        startingValueFor(control(type: ControlType.selection, maxValue: 2)),
        0,
      );
    });
  });

  group('normalizing a value into a knob\'s sweep', () {
    test('leaves a clock control alone, since it is already normalized', () {
      final knob = control(type: ControlType.clock);

      expect(normalizedValueFor(knob, 0.25), 0.25);
      expect(valueFromNormalized(knob, 0.25), 0.25);
    });

    test('maps a control with its own bounds onto the sweep and back', () {
      final fader = control(type: ControlType.fader, maxValue: 10);

      expect(normalizedValueFor(fader, 7.5), 0.75);
      expect(valueFromNormalized(fader, 0.75), 7.5);
    });

    test('holds a value from outside the domain at the end stop', () {
      // Only reachable through a hand-edited database, and a knob pinned at its
      // end reads better than a knob pointing off the face.
      final fader = control(type: ControlType.fader, maxValue: 10);

      expect(normalizedValueFor(fader, 40), 1);
      expect(valueFromNormalized(fader, -2), 0);
    });

    test('reads a domain with no width as fully back', () {
      // A selection with one position, which the validator rejects anyway.
      expect(
        normalizedValueFor(
          control(type: ControlType.selection, maxValue: 0),
          0,
        ),
        0,
      );
    });
  });

  group('sliderDivisionsFor', () {
    test('turns a clock knob\'s step into one notch per half hour', () {
      expect(
        sliderDivisionsFor(control(type: ControlType.clock, step: 0.05)),
        20,
      );
    });

    test('slides freely when the control declares no step', () {
      expect(sliderDivisionsFor(control(type: ControlType.numeric)), isNull);
    });

    test('slides freely rather than notching finer than a fingertip', () {
      final tooFine = control(
        type: ControlType.numeric,
        maxValue: 2000,
        step: 1,
      );

      expect(maxSliderDivisions, 200);
      expect(sliderDivisionsFor(tooFine), isNull);
    });

    test('ignores a step that cannot divide anything', () {
      expect(
        sliderDivisionsFor(control(type: ControlType.percentage, step: 0)),
        isNull,
      );
      // A step wider than the domain would leave a single notch at each end.
      expect(
        sliderDivisionsFor(
          control(type: ControlType.numeric, maxValue: 10, step: 30),
        ),
        isNull,
      );
    });
  });
}
