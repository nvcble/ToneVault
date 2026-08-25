import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import '../support/v1_database.dart';

/// Rebuilding a snapshot's tables, which v10 does to the readings and v13 to the
/// entries above them.
///
/// Each table is dropped and created again rather than altered - a reading is only
/// unique per pedal now, and a column added in place lands after the UNIQUE
/// constraint - so losing rows is a real possibility either time, and it is what
/// these tests watch: `test/support/v1_database.dart` holds a v9 phone with a
/// snapshot on it.
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

  test('the rebuilt tables are created exactly as fresh ones are', () async {
    const tables = ['rig_snapshot_entries', 'rig_snapshot_values'];

    // One at a time: two live databases at once only earn a drift warning.
    final fresh = AppDatabase(NativeDatabase.memory());
    final expected = <String, List<String>>{
      for (final table in tables) table: await schemaFor(fresh, table),
    };
    await fresh.close();

    final upgraded = openV9SnapshotDatabase();
    addTearDown(upgraded.close);

    // An upgraded phone and a new install have to end up with the same tables,
    // constraints, indexes and auto-indexes, not merely similar ones.
    for (final table in tables) {
      expect(
        await schemaFor(upgraded, table),
        expected[table],
        reason: '$table differs between an upgraded phone and a new install',
      );
    }
  });

  test('a pedal recorded before v13 comes back as one that was on', () async {
    final db = openV9SnapshotDatabase();
    addTearDown(db.close);

    final entry = (await db.rigSnapshotDao.watchEntries(1).first).single.entry;

    // The entry, its place in the chain and the readings under it all survive the
    // second rebuild - and nothing recorded a bypass before this version, so the
    // pedal was on.
    expect(entry.pedalId, 1);
    expect(entry.position, 0);
    expect(entry.isEnabled, isTrue);
  });

  test('a snapshot taken before v13 says nothing about its edges', () async {
    final db = openV9SnapshotDatabase();
    addTearDown(db.close);

    final snapshot = await db.rigSnapshotDao.findSnapshot(1);

    // Null rather than a guessed amplifier: the rig never said where it ran,
    // and putting words in the user's mouth is not migrating their data.
    expect(snapshot!.endpointSummary, isNull);
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
