import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/migrations.dart';
import 'package:tone_vault/core/enums/change_type.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/multi_effects_mode.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/values/control_options.dart';
import 'package:tone_vault/features/configurations/data/configuration_draft.dart';
import 'package:tone_vault/features/controls/data/control_draft.dart';
import 'package:tone_vault/features/history/data/change_entry.dart';
import 'package:tone_vault/features/pedalboards/data/pedalboard_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import '../support/repositories.dart';
import '../support/v1_database.dart';

/// What an upgrade does to a database that was already on a phone.
///
/// The v1 schema and the rows in it are a fixture in
/// `test/support/v1_database.dart`, spelled out there rather than derived from
/// the current table classes.
void main() {
  test(
    'upgrading from v1 keeps the pedals and controls already stored',
    () async {
      final db = openV1Database();
      addTearDown(db.close);

      final pedals = await db.pedalDao.watchPedals().first;
      final controls = await db.pedalControlDao.controlsOf(1);

      expect(pedals.single.name, 'PureSky');
      expect(controls.single.name, 'Volume');
      expect(controls.single.controlType, ControlType.clock);
      expect(controls.single.step, 0.05);
    },
  );

  test('a control that predates the options column has no positions', () async {
    final db = openV1Database();
    addTearDown(db.close);

    final control = await db.pedalControlDao.findControl(1);

    expect(control!.options, isNull);
    expect(decodeControlOptions(control.options), isEmpty);
  });

  test('history written before the text columns still reads', () async {
    final db = openV1Database();
    addTearDown(db.close);

    final entries = await db.changeLogDao.entriesOf(1);

    // An entry that predates old_text and new_text keeps the meaning it was
    // written with, rather than being dropped or backfilled with a guess.
    expect(entries.single.changeType, ChangeType.controlAdded);
    expect(entries.single.controlName, 'Volume');
    expect(entries.single.oldText, isNull);
    expect(entries.single.newText, isNull);
  });

  test('the upgraded database records the new schema version', () async {
    final db = openV1Database();
    addTearDown(db.close);

    // Forces the connection - and with it the migration - to open.
    await db.pedalControlDao.controlsOf(1);
    final row = await db.customSelect('PRAGMA user_version;').getSingle();

    expect(row.data.values.single, currentSchemaVersion);
  });

  test('the rig chain table is created exactly as a fresh one is', () async {
    // One at a time: two live databases at once only earn a drift warning.
    final fresh = AppDatabase(NativeDatabase.memory());
    final expected = await schemaFor(fresh, 'pedalboard_slots');
    await fresh.close();

    final upgraded = openV1Database();
    addTearDown(upgraded.close);

    // Hand-written migration SQL against what the current definition creates:
    // an upgraded phone and a new install have to end up with the same table,
    // constraints and index, not merely similar ones.
    expect(await schemaFor(upgraded, 'pedalboard_slots'), expected);
  });

  test('the snapshot tables are created exactly as fresh ones are', () async {
    const tables = [
      'rig_snapshots',
      'rig_snapshot_entries',
      'rig_snapshot_values',
    ];

    // One at a time: two live databases at once only earn a drift warning.
    final fresh = AppDatabase(NativeDatabase.memory());
    final expected = <String, List<String>>{
      for (final table in tables) table: await schemaFor(fresh, table),
    };
    await fresh.close();

    final upgraded = openV1Database();
    addTearDown(upgraded.close);

    for (final table in tables) {
      expect(
        await schemaFor(upgraded, table),
        expected[table],
        reason: '$table differs between an upgraded phone and a new install',
      );
    }
  });

  test('an upgraded database can hold a snapshot', () async {
    final db = openV1Database();
    addTearDown(db.close);

    final rigId = await pedalboardRepository(
      db,
    ).createPedalboard(const PedalboardDraft(name: 'Hybrid Worship Rig'));
    final snapshotId = await db.rigSnapshotDao.insertSnapshot(
      RigSnapshotsCompanion.insert(
        pedalboardId: rigId,
        name: 'Easter 2026',
        capturedAt: DateTime.utc(2026, 4, 5),
      ),
    );
    // Pedal 1 is the one already stored in the v1 fixture.
    await db.rigSnapshotDao.insertEntry(
      RigSnapshotEntriesCompanion.insert(
        snapshotId: snapshotId,
        pedalId: 1,
        position: 0,
      ),
    );

    final entries = await db.rigSnapshotDao.watchEntries(snapshotId).first;
    expect(entries.single.pedal.name, 'PureSky');
  });

  test('an upgraded database can hold a rig chain', () async {
    final db = openV1Database();
    addTearDown(db.close);

    final rigId = await pedalboardRepository(
      db,
    ).createPedalboard(const PedalboardDraft(name: 'Hybrid Worship Rig'));
    // Pedal 1 is the one already stored in the v1 fixture.
    await rigChainRepository(db).addPedal(pedalboardId: rigId, pedalId: 1);

    final chain = await db.pedalboardDao.watchChain(rigId).first;
    expect(chain.single.pedal.name, 'PureSky');
    expect(chain.single.slot.position, 0);
  });

  test('an upgraded database can hold a pedal inside a unit', () async {
    final db = openV1Database();
    addTearDown(db.close);
    final repository = pedalRepository(db);

    final unitId = await repository.createPedal(
      const PedalDraft(
        name: 'Valeton GP-200',
        type: PedalType.multiEffects,
        category: PedalCategory.multiEffects,
        multiEffectsMode: MultiEffectsMode.stomp,
      ),
    );
    await repository.createPedal(
      PedalDraft(
        name: 'Tube Screamer',
        type: PedalType.digital,
        category: PedalCategory.overdrive,
        hostPedalId: unitId,
      ),
    );

    // Pedal 1 is the one already in the v1 fixture, and it keeps standing on its
    // own floor: the columns the upgrade added are null on every row it found.
    final owned = await repository.watchPedals().first;
    expect(owned.map((pedal) => pedal.name), ['PureSky', 'Valeton GP-200']);
    expect(owned.first.hostPedalId, isNull);
    expect(owned.first.multiEffectsMode, isNull);

    final inside = await repository.watchComponentPedals(unitId).first;
    expect(inside.single.name, 'Tube Screamer');
  });

  test('an upgraded database can name the pedal a control is on', () async {
    final db = openV1Database();
    addTearDown(db.close);

    final unitId = await pedalRepository(db).createPedal(
      const PedalDraft(
        name: 'Valeton GP-200',
        type: PedalType.multiEffects,
        category: PedalCategory.multiEffects,
        multiEffectsMode: MultiEffectsMode.scene,
      ),
    );
    final screamerId = await pedalRepository(db).createPedal(
      PedalDraft(
        name: 'Tube Screamer',
        type: PedalType.digital,
        category: PedalCategory.overdrive,
        hostPedalId: unitId,
      ),
    );
    final controlId = await controlRepository(db).createControl(
      screamerId,
      ControlDraft.ofType(ControlType.clock, name: 'Drive'),
    );
    final sceneId = await configurationRepository(
      db,
    ).createConfiguration(unitId, const ConfigurationDraft(name: 'Chorus'));

    final owned = await db.pedalControlDao.findSettableControl(
      controlId: controlId,
      pedalId: unitId,
    );
    await changeLogRepository(db).record(
      ChangeEntry.controlValueChanged(
        configuration: (await db.configurationDao.findConfiguration(sceneId))!,
        control: owned!.control,
        controlPedal: owned.owner,
        oldValue: null,
        newValue: 0.75,
      ),
    );

    // The column the upgrade added holds what a fresh install would hold, and
    // the entry the fixture came with still reads without it.
    final entries = await db.changeLogDao.entriesOf(unitId);
    final moved = entries.firstWhere(
      (entry) => entry.changeType == ChangeType.controlValueChanged,
    );
    expect(moved.controlPedalName, 'Tube Screamer');
    expect(
      (await db.changeLogDao.entriesOf(1)).single.controlPedalName,
      isNull,
    );
  });

  test(
    'the added column stores positions like a freshly created one',
    () async {
      final db = openV1Database();
      addTearDown(db.close);
      final repository = controlRepository(db);

      await repository.createControl(
        1,
        const ControlDraft(
          name: 'Mode',
          type: ControlType.selection,
          minValue: 0,
          maxValue: 1,
          options: ['Chorus', 'Vibrato'],
        ),
      );

      final controls = await db.pedalControlDao.controlsOf(1);
      expect(controls, hasLength(2));
      expect(decodeControlOptions(controls.last.options), [
        'Chorus',
        'Vibrato',
      ]);
    },
  );
}
