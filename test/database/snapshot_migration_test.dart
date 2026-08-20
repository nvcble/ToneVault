import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import '../support/v1_database.dart';

/// Rebuilding the frozen readings of a snapshot, which is what v10 does.
///
/// The table is dropped and created again rather than altered, because a reading
/// is only unique per pedal now and SQLite cannot widen a UNIQUE constraint in
/// place. That makes losing rows a real possibility, so it is what these tests
/// watch: `test/support/v1_database.dart` holds a v9 phone with a reading on it.
void main() {
  test('a reading frozen before v10 comes through the rebuild', () async {
    final db = openV9SnapshotDatabase();
    addTearDown(db.close);

    final entries = await db.rigSnapshotDao.watchEntries(1).first;

    // A snapshot that came out of the rebuild without its numbers would be a
    // date and a list of pedal names.
    expect(entries.single.entry.configurationName, 'Worship Clean');
    final reading = entries.single.values.single;
    expect(reading.controlName, 'Volume');
    expect(reading.value, 0.75);
    // Null rather than filled in with the entry's pedal: every reading written
    // before v10 was that pedal's own, which is what null already means.
    expect(reading.controlPedalName, isNull);
  });

  test('the rebuilt table is created exactly as a fresh one is', () async {
    // One at a time: two live databases at once only earn a drift warning.
    final fresh = AppDatabase(NativeDatabase.memory());
    final expected = await schemaFor(fresh, 'rig_snapshot_values');
    await fresh.close();

    final upgraded = openV9SnapshotDatabase();
    addTearDown(upgraded.close);

    // An upgraded phone and a new install have to end up with the same table,
    // constraints and auto-index, not merely similar ones.
    expect(await schemaFor(upgraded, 'rig_snapshot_values'), expected);
  });

  test('the rebuilt table holds two knobs of the same name', () async {
    final db = openV9SnapshotDatabase();
    addTearDown(db.close);

    await db.rigSnapshotDao.insertValues([
      RigSnapshotValuesCompanion.insert(
        entryId: 1,
        controlName: 'Level',
        controlPedalName: const Value('Tube Screamer'),
        controlType: ControlType.clock,
        value: 0.5,
        displayOrder: 1,
      ),
      RigSnapshotValuesCompanion.insert(
        entryId: 1,
        controlName: 'Level',
        controlPedalName: const Value('Hall Reverb'),
        controlType: ControlType.clock,
        value: 0.25,
        displayOrder: 2,
      ),
    ]);

    // What the wider key is for: a unit captured on one of its scenes freezes the
    // Level of every pedal it uses, and the old key allowed one of them.
    final values =
        (await db.rigSnapshotDao.watchEntries(1).first).single.values;
    expect(values.map((value) => value.controlPedalName), [
      isNull,
      'Tube Screamer',
      'Hall Reverb',
    ]);
  });
}
