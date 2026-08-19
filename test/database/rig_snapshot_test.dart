import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/pedalboards/data/pedalboard_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import '../support/repositories.dart';

/// Snapshot rows: how a saved rig reads back, and what a snapshot keeps hold of.
///
/// Capture itself is `RigSnapshotRepository`'s job and lands with it; here the
/// rows are written by hand so the schema and the queries over it can be
/// checked on their own.
void main() {
  late AppDatabase database;
  late int rigId;
  final captured = DateTime.utc(2026, 4, 5, 9, 30);

  Future<int> addPedal(String name) {
    return pedalRepository(database).createPedal(
      PedalDraft(
        name: name,
        type: PedalType.analog,
        category: PedalCategory.overdrive,
      ),
    );
  }

  Future<int> addSnapshot({required String name, DateTime? at, int? onRig}) {
    return database.rigSnapshotDao.insertSnapshot(
      RigSnapshotsCompanion.insert(
        pedalboardId: onRig ?? rigId,
        name: name,
        capturedAt: at ?? captured,
      ),
    );
  }

  Future<int> addEntry(
    int snapshotId, {
    required int pedalId,
    required int position,
    String? configurationName,
  }) {
    return database.rigSnapshotDao.insertEntry(
      RigSnapshotEntriesCompanion.insert(
        snapshotId: snapshotId,
        pedalId: pedalId,
        position: position,
        configurationName: Value(configurationName),
      ),
    );
  }

  Future<void> addValue(
    int entryId, {
    required String control,
    required double value,
    ControlType type = ControlType.clock,
    int displayOrder = 0,
  }) {
    return database.rigSnapshotDao.insertValues([
      RigSnapshotValuesCompanion.insert(
        entryId: entryId,
        controlName: control,
        controlType: type,
        value: value,
        displayOrder: displayOrder,
      ),
    ]);
  }

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    rigId = await pedalboardRepository(
      database,
    ).createPedalboard(const PedalboardDraft(name: 'Hybrid Worship Rig'));
  });

  tearDown(() => database.close());

  test('lists a rig\'s snapshots newest first', () async {
    await addSnapshot(name: 'Easter 2026', at: captured);
    await addSnapshot(
      name: 'Christmas 2026',
      at: DateTime.utc(2026, 12, 24, 19),
    );
    await addSnapshot(name: 'Rehearsal', at: DateTime.utc(2026, 1, 8, 20));

    final snapshots = await database.rigSnapshotDao.watchSnapshots(rigId).first;

    // The last thing played is the thing most likely being looked up.
    expect(snapshots.map((snapshot) => snapshot.name), [
      'Christmas 2026',
      'Easter 2026',
      'Rehearsal',
    ]);
  });

  test('keeps each rig\'s snapshots to itself', () async {
    final otherRigId = await pedalboardRepository(
      database,
    ).createPedalboard(const PedalboardDraft(name: 'Home Practice'));
    await addSnapshot(name: 'Easter 2026');
    await addSnapshot(name: 'Desk noodling', onRig: otherRigId);

    final snapshots = await database.rigSnapshotDao.watchSnapshots(rigId).first;

    expect(snapshots.single.name, 'Easter 2026');
  });

  test('two snapshots may share a name, told apart by their date', () async {
    // No unique key on the name: "Easter" comes round every year.
    await addSnapshot(name: 'Easter', at: DateTime.utc(2026, 4, 5));
    await addSnapshot(name: 'Easter', at: DateTime.utc(2027, 3, 28));

    final snapshots = await database.rigSnapshotDao.watchSnapshots(rigId).first;

    expect(snapshots, hasLength(2));
    expect(snapshots.first.capturedAt, DateTime.utc(2027, 3, 28));
  });

  test('reads the chain back in signal order, with its readings', () async {
    final wahId = await addPedal('Vox Wah');
    final driveId = await addPedal('Caline PureSky');
    final snapshotId = await addSnapshot(name: 'Easter 2026');

    final driveEntry = await addEntry(
      snapshotId,
      pedalId: driveId,
      position: 1,
      configurationName: 'Worship Lead',
    );
    await addEntry(snapshotId, pedalId: wahId, position: 0);
    await addValue(driveEntry, control: 'Volume', value: 0.75);
    await addValue(driveEntry, control: 'Tone', value: 0.5, displayOrder: 1);

    final entries = await database.rigSnapshotDao
        .watchEntries(snapshotId)
        .first;

    // Position, not insertion order, is what the chain read that day.
    expect(
      [for (final entry in entries) entry.pedal.name],
      ['Vox Wah', 'Caline PureSky'],
    );
    expect(entries.last.entry.configurationName, 'Worship Lead');
    expect(
      [for (final value in entries.last.values) value.controlName],
      ['Volume', 'Tone'],
    );
    expect(entries.last.values.first.value, 0.75);
  });

  test('a pedal captured with nothing dialled in still appears', () async {
    final pedalId = await addPedal('Vox Wah');
    final snapshotId = await addSnapshot(name: 'Easter 2026');
    await addEntry(snapshotId, pedalId: pedalId, position: 0);

    final entries = await database.rigSnapshotDao
        .watchEntries(snapshotId)
        .first;

    // A wah has no preset worth recording, and it was still on the board.
    expect(entries.single.pedal.name, 'Vox Wah');
    expect(entries.single.entry.configurationName, isNull);
    expect(entries.single.values, isEmpty);
  });

  test('readings survive the configuration they were copied from', () async {
    final pedalId = await addPedal('Caline PureSky');
    final snapshotId = await addSnapshot(name: 'Easter 2026');
    final entryId = await addEntry(
      snapshotId,
      pedalId: pedalId,
      position: 0,
      configurationName: 'Worship Lead',
    );
    await addValue(entryId, control: 'Volume', value: 0.75);

    // The pedal's own controls and configurations are not referenced at all, so
    // there is nothing here for a later re-tweak to reach.
    final entries = await database.rigSnapshotDao
        .watchEntries(snapshotId)
        .first;
    final reading = entries.single.values.single;

    expect(reading.controlName, 'Volume');
    expect(reading.controlType, ControlType.clock);
    expect(reading.value, 0.75);
  });

  test('deleting a snapshot takes its rows but not the pedals', () async {
    final pedalId = await addPedal('Vox Wah');
    final snapshotId = await addSnapshot(name: 'Easter 2026');
    final entryId = await addEntry(snapshotId, pedalId: pedalId, position: 0);
    await addValue(entryId, control: 'Volume', value: 0.75);

    expect(await database.rigSnapshotDao.deleteSnapshot(snapshotId), isTrue);

    expect(await database.rigSnapshotDao.findSnapshot(snapshotId), isNull);
    expect(
      await database.rigSnapshotDao.watchEntries(snapshotId).first,
      isEmpty,
    );
    // Cascades reach the snapshot's own rows only; the pedal is untouched.
    expect(await database.pedalDao.findPedal(pedalId), isNotNull);
  });

  test('a pedal recorded in a snapshot cannot be deleted', () async {
    final pedalId = await addPedal('Vox Wah');
    final snapshotId = await addSnapshot(name: 'Easter 2026');
    await addEntry(snapshotId, pedalId: pedalId, position: 0);

    await expectLater(
      pedalRepository(database).deletePedal(pedalId),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.message,
          'message',
          contains('snapshots'),
        ),
      ),
    );
    expect(await database.pedalDao.findPedal(pedalId), isNotNull);
  });

  test('renaming a snapshot leaves the date it was taken alone', () async {
    final snapshotId = await addSnapshot(name: 'Easter');

    final matched = await database.rigSnapshotDao.updateSnapshot(
      snapshotId,
      const RigSnapshotsCompanion(
        name: Value('Easter Sunday 2026'),
        notes: Value('Second service'),
      ),
    );

    expect(matched, isTrue);
    final stored = (await database.rigSnapshotDao.findSnapshot(snapshotId))!;
    expect(stored.name, 'Easter Sunday 2026');
    expect(stored.notes, 'Second service');
    expect(stored.capturedAt, captured);
  });
}
