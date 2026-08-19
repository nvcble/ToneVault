import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/features/configurations/data/configuration_validator.dart';

void main() {
  PedalControl control({
    required ControlType type,
    String name = 'Volume',
    double minValue = 0,
    double maxValue = 1,
  }) {
    return PedalControl(
      id: 1,
      pedalId: 1,
      name: name,
      controlType: type,
      minValue: minValue,
      maxValue: maxValue,
      displayOrder: 0,
    );
  }

  group('name', () {
    test('is required', () {
      expect(ConfigurationValidator.name('   '), 'Enter a configuration name.');
    });

    test('is measured after trimming', () {
      final longest = 'c' * ConfigurationValidator.nameMaxLength;

      expect(ConfigurationValidator.name('  $longest  '), isNull);
      expect(ConfigurationValidator.name('$longest!'), isNotNull);
    });
  });

  group('value', () {
    test('is required', () {
      expect(
        ConfigurationValidator.value(
          null,
          control: control(type: ControlType.clock),
        ),
        'Enter a value for Volume.',
      );
    });

    test('has to sit inside the control\'s own domain', () {
      final knob = control(type: ControlType.clock);

      // A clock knob stores 0..1 whatever it reads as on the face.
      expect(ConfigurationValidator.value(0, control: knob), isNull);
      expect(ConfigurationValidator.value(1, control: knob), isNull);
      expect(
        ConfigurationValidator.value(1.01, control: knob),
        'Volume cannot be set to that.',
      );
      expect(ConfigurationValidator.value(-0.01, control: knob), isNotNull);
    });

    test('reads the domain off the control rather than the type', () {
      final delay = control(
        type: ControlType.numeric,
        name: 'Delay Time',
        minValue: 20,
        maxValue: 2000,
      );

      expect(ConfigurationValidator.value(400, control: delay), isNull);
      expect(ConfigurationValidator.value(0, control: delay), isNotNull);
    });

    test('rejects a number that is not a number', () {
      expect(
        ConfigurationValidator.value(
          double.nan,
          control: control(type: ControlType.clock),
        ),
        isNotNull,
      );
    });

    test('accepts a fraction on a knob but not on a selection', () {
      final knob = control(type: ControlType.clock);
      final mode = control(
        type: ControlType.selection,
        name: 'Mode',
        maxValue: 2,
      );

      // A knob sits wherever it sits; a selection is in one position or another.
      expect(ConfigurationValidator.value(0.37, control: knob), isNull);
      expect(ConfigurationValidator.value(1, control: mode), isNull);
      expect(
        ConfigurationValidator.value(1.5, control: mode),
        'Pick one of Mode\'s positions.',
      );
    });
  });
}
