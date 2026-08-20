import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/pedal_control_dao.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/values/control_options.dart';
import 'package:tone_vault/features/snapshots/data/snapshot_readings.dart';

/// What gets frozen when a snapshot copies one setting's readings, and what does
/// not. Pure data in, companions out - no database.
void main() {
  final moment = DateTime.utc(2026, 8, 21);

  Pedal pedal(int id, String name) {
    return Pedal(
      id: id,
      name: name,
      type: PedalType.digital,
      category: PedalCategory.overdrive,
      status: PedalStatus.active,
      createdAt: moment,
      updatedAt: moment,
    );
  }

  final screamer = pedal(7, 'Tube Screamer');

  /// One control with the pedal it is on, which is what the readings are built
  /// from: a scene of a unit reaches the controls of several pedals.
  OwnedControl owned(
    int id, {
    required String name,
    Pedal? on,
    ControlType type = ControlType.clock,
    String? unit,
    List<String> options = const [],
    int displayOrder = 0,
  }) {
    final owner = on ?? screamer;
    return (
      owner: owner,
      control: PedalControl(
        id: id,
        pedalId: owner.id,
        name: name,
        controlType: type,
        minValue: 0,
        maxValue: 1,
        unit: unit,
        options: encodeControlOptions(options),
        displayOrder: displayOrder,
      ),
    );
  }

  test('copies enough to read a number back later', () {
    final readings = frozenReadings(
      entryId: 42,
      controls: [
        owned(3, name: 'Delay', type: ControlType.numeric, unit: 'ms'),
      ],
      positions: {3: 375},
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

  test('names the pedal each knob was on', () {
    final readings = frozenReadings(
      entryId: 42,
      controls: [
        owned(3, name: 'Level'),
        owned(4, name: 'Level', on: pedal(8, 'Hall Reverb')),
      ],
      positions: {3: 0.75, 4: 0.25},
    );

    // Without it a unit captured on one of its scenes would read as three knobs
    // called Level, and the pedals are not referenced to look up afterwards.
    expect(
      [for (final reading in readings) reading.controlPedalName.value],
      ['Tube Screamer', 'Hall Reverb'],
    );
  });

  test('copies the position names a selection read that day', () {
    final readings = frozenReadings(
      entryId: 42,
      controls: [
        owned(
          3,
          name: 'Mode',
          type: ControlType.selection,
          options: ['Chorus', 'Vibrato'],
        ),
      ],
      positions: {3: 1},
    );

    // Renaming the positions afterwards must not relabel what was played.
    expect(decodeControlOptions(readings.single.options.value), [
      'Chorus',
      'Vibrato',
    ]);
  });

  test('keeps the controls in the order they were given in', () {
    final readings = frozenReadings(
      entryId: 42,
      controls: [
        owned(3, name: 'Volume'),
        owned(4, name: 'Tone', displayOrder: 1),
      ],
      positions: {4: 0.5, 3: 0.75},
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

  test('leaves out a knob the setting never dialled in', () {
    final readings = frozenReadings(
      entryId: 42,
      controls: [
        owned(3, name: 'Volume'),
        owned(4, name: 'Tone', displayOrder: 1),
      ],
      positions: {4: 0.5},
    );

    // An unset knob is not a reading, and guessing one would put a position in
    // the record that nobody dialled in.
    expect(readings.single.controlName.value, 'Tone');
    expect(readings.single.displayOrder.value, 1);
  });

  test('a setting with nothing dialled in freezes nothing', () {
    final readings = frozenReadings(
      entryId: 42,
      controls: [owned(3, name: 'Volume')],
      positions: const {},
    );

    expect(readings, isEmpty);
  });

  test('has no unit or options for a plain analog knob', () {
    final readings = frozenReadings(
      entryId: 42,
      controls: [owned(3, name: 'Volume')],
      positions: {3: 0.75},
    );

    expect(readings.single.unit.value, isNull);
    expect(readings.single.options.value, isNull);
  });
}
