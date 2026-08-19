import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/values/control_options.dart';
import 'package:tone_vault/features/snapshots/data/snapshot_readings.dart';

/// What gets frozen when a snapshot copies one pedal's settings, and what does
/// not. Pure data in, companions out - no database.
void main() {
  PedalControl control(
    int id, {
    required String name,
    ControlType type = ControlType.clock,
    String? unit,
    List<String> options = const [],
    int displayOrder = 0,
  }) {
    return PedalControl(
      id: id,
      pedalId: 7,
      name: name,
      controlType: type,
      minValue: 0,
      maxValue: 1,
      unit: unit,
      options: encodeControlOptions(options),
      displayOrder: displayOrder,
    );
  }

  ConfigurationValue position(int controlId, double value) {
    return ConfigurationValue(
      id: controlId,
      configurationId: 1,
      controlId: controlId,
      value: value,
    );
  }

  test('copies enough to read a number back later', () {
    final readings = frozenReadings(
      entryId: 42,
      controls: [
        control(3, name: 'Delay', type: ControlType.numeric, unit: 'ms'),
      ],
      values: [position(3, 375)],
    );

    // The control is not referenced, so everything needed to format the value has
    // to travel with it.
    final reading = readings.single;
    expect(reading.entryId.value, 42);
    expect(reading.controlName.value, 'Delay');
    expect(reading.controlType.value, ControlType.numeric);
    expect(reading.value.value, 375);
    expect(reading.unit.value, 'ms');
  });

  test('copies the position names a selection read that day', () {
    final readings = frozenReadings(
      entryId: 42,
      controls: [
        control(
          3,
          name: 'Mode',
          type: ControlType.selection,
          options: ['Chorus', 'Vibrato'],
        ),
      ],
      values: [position(3, 1)],
    );

    // Renaming the positions afterwards must not relabel what was played.
    expect(decodeControlOptions(readings.single.options.value), [
      'Chorus',
      'Vibrato',
    ]);
  });

  test('keeps the controls in the order they sit on the pedal', () {
    final readings = frozenReadings(
      entryId: 42,
      controls: [
        control(3, name: 'Volume'),
        control(4, name: 'Tone', displayOrder: 1),
      ],
      values: [position(4, 0.5), position(3, 0.75)],
    );

    expect(
      [for (final reading in readings) reading.controlName.value],
      ['Volume', 'Tone'],
    );
    expect(
      [for (final reading in readings) reading.displayOrder.value],
      [0, 1],
    );
  });

  test('leaves out a knob the configuration never set', () {
    final readings = frozenReadings(
      entryId: 42,
      controls: [
        control(3, name: 'Volume'),
        control(4, name: 'Tone', displayOrder: 1),
      ],
      values: [position(4, 0.5)],
    );

    // An unset knob is not a reading, and guessing one would put a position in
    // the record that nobody dialled in.
    expect(readings.single.controlName.value, 'Tone');
    expect(readings.single.displayOrder.value, 1);
  });

  test('a configuration with nothing set freezes nothing', () {
    final readings = frozenReadings(
      entryId: 42,
      controls: [control(3, name: 'Volume')],
      values: const [],
    );

    expect(readings, isEmpty);
  });

  test('has no unit or options for a plain analog knob', () {
    final readings = frozenReadings(
      entryId: 42,
      controls: [control(3, name: 'Volume')],
      values: [position(3, 0.75)],
    );

    expect(readings.single.unit.value, isNull);
    expect(readings.single.options.value, isNull);
  });
}
