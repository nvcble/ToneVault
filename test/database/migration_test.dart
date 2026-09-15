import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/migrations.dart';
import 'package:tone_vault/core/enums/change_type.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/multi_effects_mode.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/core/values/control_options.dart';
import 'package:tone_vault/features/configurations/data/configuration_draft.dart';
import 'package:tone_vault/features/controls/data/control_draft.dart';
import 'package:tone_vault/features/history/data/change_entry.dart';
import 'package:tone_vault/features/patches/data/patch_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import '../support/repositories.dart';
import '../support/v1_database.dart';
import '../support/v21_database.dart';

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

  test('the chain tables are created exactly as fresh ones are', () async {
    const tables = ['signal_blocks', 'signal_connections', 'signal_endpoints'];

    // One at a time: two live databases at once only earn a drift warning.
    final fresh = AppDatabase(NativeDatabase.memory());
    final expected = <String, List<String>>{
      for (final table in tables) table: await schemaFor(fresh, table),
    };
    await fresh.close();

    final upgraded = openV1Database();
    addTearDown(upgraded.close);

    // Hand-written migration SQL against what the current definition creates:
    // an upgraded phone and a new install have to end up with the same tables,
    // constraints and indexes, not merely similar ones.
    for (final table in tables) {
      expect(
        await schemaFor(upgraded, table),
        expected[table],
        reason: '$table differs between an upgraded phone and a new install',
      );
    }
  });

  test('the table the blocks replaced is gone', () async {
    final db = openV1Database();
    addTearDown(db.close);

    // Left behind, it would be a second copy of every chain, drifting from the
    // one the app writes to.
    expect(await schemaFor(db, 'pedalboard_slots'), isEmpty);
  });

  test('a new install still builds the snapshot tables', () async {
    // Not because anything in the app writes them - nothing does - but because a
    // backup file carries them, and a table the phone does not have is a table a
    // restore cannot put its rows into. A user moving to a new phone gets their
    // recorded rigs back only if this holds.
    final fresh = AppDatabase(NativeDatabase.memory());
    addTearDown(fresh.close);

    for (final table in const [
      'rig_snapshots',
      'rig_snapshot_entries',
      'rig_snapshot_values',
    ]) {
      expect(await schemaFor(fresh, table), isNotEmpty, reason: table);
    }
  });

  test('taking rigs out of the app does not take the snapshots', () async {
    // The whole point of leaving the tables standing. No screen and no repository
    // reads these rows any more, which is exactly why they are read here through
    // the tables themselves: the user recorded which pedals were on the board and
    // where every knob stood on a night they played, and an upgrade that dropped
    // the tables would take that away with nowhere to get it back from.
    final db = openV9SnapshotDatabase();
    addTearDown(db.close);

    final snapshot = (await db.select(db.rigSnapshots).get()).single;
    final entry = (await db.select(db.rigSnapshotEntries).get()).single;
    final reading = (await db.select(db.rigSnapshotValues).get()).single;

    expect(snapshot.name, 'Easter 2026');
    expect(snapshot.pedalboardId, 1);
    expect(snapshot.capturedAt, DateTime.utc(2026, 4, 5, 9));
    expect(entry.snapshotId, snapshot.id);
    expect(entry.configurationName, 'Worship Clean');
    // What v13 added, filled in by that step rather than left null: a snapshot
    // taken before the app recorded a bypass recorded the pedals that were on.
    expect(entry.isEnabled, isTrue);
    expect(reading.entryId, entry.id);
    expect(reading.controlName, 'Volume');
    expect(reading.controlType, ControlType.clock);
    expect(reading.value, 0.75);
  });

  test('the patch tables are created exactly as fresh ones are', () async {
    const tables = ['patches', 'scenes', 'scene_pedals', 'scene_values'];

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

  test('the academy tables are created exactly as fresh ones are', () async {
    const tables = [
      'academy_courses',
      'academy_modules',
      'academy_lessons',
      'academy_exercises',
      'academy_progress',
      'academy_exercise_progress',
      'academy_practice_sessions',
      'academy_bookmarks',
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

  test('the academy arrives without touching the gear already stored', () async {
    // The whole promise of the v15 step: six new tables and nothing else. A
    // player who upgrades into the Academy still has every pedal, control and
    // history entry they had before it.
    final db = openV1Database();
    addTearDown(db.close);

    expect((await db.pedalDao.watchPedals().first).single.name, 'PureSky');
    expect((await db.pedalControlDao.controlsOf(1)).single.name, 'Volume');
    expect(await db.changeLogDao.entriesOf(1), hasLength(1));
    // And the Academy is empty, because the curriculum is seeded from the assets
    // on the next launch rather than written into the upgrade.
    expect(await db.select(db.academyCourses).get(), isEmpty);
  });

  test('an upgraded database can hold a patch', () async {
    final db = openV1Database();
    addTearDown(db.close);

    final unitId = await pedalRepository(db).createPedal(
      const PedalDraft(
        name: 'Valeton GP-200',
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
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

    final patchId = await patchRepository(
      db,
    ).createPatch(unitId, const PatchDraft(name: 'Worship Clean'));
    final sceneId = await sceneRepository(
      db,
    ).createScene(patchId, const SceneDraft(name: 'Verse'));
    await scenePedalRepository(
      db,
    ).addPedal(sceneId: sceneId, pedalId: screamerId);
    await sceneValueRepository(
      db,
    ).setValue(sceneId: sceneId, controlId: controlId, value: 0.75);

    // All four tables at once, because a patch nobody can put a position into is
    // an empty container: the upgrade has to land the whole shape.
    expect(
      (await patchRepository(db).watchPatches(unitId).first).single.name,
      'Worship Clean',
    );
    final pedals = await scenePedalRepository(
      db,
    ).watchScenePedals(sceneId).first;
    expect(pedals.single.name, 'Tube Screamer');
    expect((await db.sceneDao.valuesOf(sceneId)).single.value, 0.75);
  });

  test('the board a phone already had is still on it', () async {
    // The rigs feature is gone and there is no screen and no repository left to
    // read these rows through, which is exactly why they are read here through
    // the table itself. They are the user's own record of how a board was wired,
    // and an upgrade that quietly emptied it would be an upgrade that took
    // something away. Ids are kept, so anything already pointing at a slot finds
    // the block it became.
    final db = openV10ChainDatabase();
    addTearDown(db.close);

    final blocks = await db.select(db.signalBlocks).get();

    expect(blocks.map((block) => block.id), [7, 8, 9]);
    expect(blocks.map((block) => block.pedalId), [2, 1, 3]);
    expect(blocks.map((block) => block.blockType), [
      SignalBlockType.gate,
      SignalBlockType.overdrive,
      SignalBlockType.custom,
    ]);
  });

  test('a pedal that held a place on an old board can be deleted', () async {
    // Blocks reference pedals with ON DELETE RESTRICT, and there is no screen
    // left that could take a pedal off a board first, so a pedal that was ever
    // on one would otherwise be impossible to delete for good.
    final db = openV10ChainDatabase();
    addTearDown(db.close);

    await pedalRepository(db).deletePedal(1);

    // Ordered by name, as the pedals tab streams them: Line Selector, NS-2.
    expect((await db.pedalDao.watchPedals().first).map((row) => row.name), [
      'Line Selector',
      'NS-2',
    ]);
    // The block went with it. What is left is still the record of the board.
    final blocks = await db.select(db.signalBlocks).get();
    expect(blocks.map((block) => block.id), [7, 9]);
  });

  test('an upgraded database can hold a pedal inside a unit', () async {
    final db = openV1Database();
    addTearDown(db.close);
    final repository = pedalRepository(db);

    final unitId = await repository.createPedal(
      const PedalDraft(
        name: 'Valeton GP-200',
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
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
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
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

  test('a unit stored as a multi-effects type is refiled, not lost', () async {
    // The type it was saved under no longer exists, so reading the row at all is
    // what the upgrade has to make possible again.
    final db = openV7MultiEffectsDatabase();
    addTearDown(db.close);

    final unit = await db.pedalDao.findPedal(1);

    expect(unit!.name, 'Valeton GP-200');
    expect(unit.type, PedalType.digital);
    expect(unit.category, PedalCategory.multiEffects);
    // What it was used in is dormant rather than cleared: nothing writes it now,
    // and the answer the user gave is still there to read.
    expect(unit.multiEffectsMode, MultiEffectsMode.scene);
    // And being a unit is what it is asked about from here on.
    expect(unit.category.hasOwnControls, isFalse);
  });

  test('the MIDI mapping tables are created exactly as fresh ones are', () async {
    const tables = ['midi_parameter_overrides', 'midi_patch_selection_settings'];

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

  test('an upgraded database can hold a MIDI CC remapping', () async {
    final db = openV1Database();
    addTearDown(db.close);

    await db.midiParameterOverrideDao.upsertOverride(
      deviceProfileId: 'nux_mg30_v5',
      parameterName: 'Scene',
      ccNumber: 90,
      updatedAt: DateTime.utc(2026, 9),
    );

    final override = await db.midiParameterOverrideDao.findOverride(
      deviceProfileId: 'nux_mg30_v5',
      parameterName: 'Scene',
    );
    expect(override!.ccNumber, 90);
    // The gear already on the phone is untouched by a table that did not exist
    // when it was stored.
    expect((await db.pedalDao.watchPedals().first).single.name, 'PureSky');
  });

  test('the device-link tables are created exactly as fresh ones are', () async {
    const tables = [
      'midi_device_links',
      'midi_patch_program_numbers',
      'midi_scene_numbers',
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

  test('an upgraded database can link a pedal to a device profile', () async {
    final db = openV1Database();
    addTearDown(db.close);

    await db.midiDeviceLinkDao.insertLink(
      MidiDeviceLinksCompanion.insert(
        pedalId: 1,
        deviceProfileId: 'nux_mg30_v5',
        linkedAt: DateTime.utc(2026, 9),
      ),
    );

    final link = await db.midiDeviceLinkDao.findLink('nux_mg30_v5');
    expect(link!.pedalId, 1);
    expect((await db.pedalDao.watchPedals().first).single.name, 'PureSky');
  });

  test('the Patch Browser tables are created exactly as fresh ones are', () async {
    const tables = ['midi_patch_favorites', 'midi_patch_recents'];

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

  test('an upgraded database can favorite and record a recent patch', () async {
    final db = openV1Database();
    addTearDown(db.close);
    final unitId = await pedalRepository(db).createPedal(
      const PedalDraft(
        name: 'Valeton GP-200',
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
      ),
    );
    final patchId = await patchRepository(
      db,
    ).createPatch(unitId, const PatchDraft(name: 'Worship Clean'));

    await db.midiPatchFavoriteDao.setFavorite(patchId: patchId, isFavorite: true);
    await db.midiPatchRecentDao.recordUsed(patchId);

    expect(await db.midiPatchFavoriteDao.watchFavoritePatchIds().first, {patchId});
    expect((await db.midiPatchRecentDao.watchRecents().first).single.patchId, patchId);
  });

  test('the preset capture table is created exactly as a fresh one is', () async {
    const tables = ['midi_preset_captures'];

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

  test('an upgraded database can hold a raw preset capture', () async {
    final db = openV1Database();
    addTearDown(db.close);
    final unitId = await pedalRepository(db).createPedal(
      const PedalDraft(
        name: 'Valeton GP-200',
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
      ),
    );

    await db.midiPresetCaptureDao.upsertCapture(
      pedalId: unitId,
      deviceProfileId: 'nux_mg30_v5',
      programNumber: 5,
      rawSysEx: Uint8List.fromList([0xF0, 0x43, 0x58, 0xF7]),
      decodedName: 'Worship Lead',
      capturedAt: DateTime.utc(2026, 9),
    );

    final captures = await db.midiPresetCaptureDao.watchCaptures(unitId).first;
    expect(captures.single.decodedName, 'Worship Lead');
    expect(captures.single.rawSysEx, [0xF0, 0x43, 0x58, 0xF7]);
  });

  test('program numbers shift down to keep the same physical slot', () async {
    final db = openV21ProgramNumberDatabase();
    addTearDown(db.close);

    final numbered = await db.midiPatchProgramNumberDao
        .watchNumberedPatches(1)
        .first;

    // Slot 1 under the old counting and slot 0 under the new one are the same
    // Program Change 0, because the sender no longer subtracts one.
    expect(
      numbered.map((row) => (row.patch.name, row.programNumber)),
      [('Worship Clean', 0), ('Core Lead', 21), ('Ambient', 127)],
    );
  });

  test('an upgraded database can hold the first slot of all', () async {
    final db = openV21ProgramNumberDatabase();
    addTearDown(db.close);

    // 0 is what the old CHECK rejected, so importing a unit's first preset was
    // impossible until the table was rebuilt.
    await db.midiPatchProgramNumberDao.upsertNumber(
      patchId: 2,
      programNumber: 0,
      updatedAt: DateTime.utc(2026, 9),
    );

    expect((await db.midiPatchProgramNumberDao.findNumber(2))!.programNumber, 0);
  });

  test('the renumbered table matches a freshly created one', () async {
    // One at a time: two live databases at once only earn a drift warning.
    final fresh = AppDatabase(NativeDatabase.memory());
    final expected = await schemaFor(fresh, 'midi_patch_program_numbers');
    await fresh.close();

    final upgraded = openV21ProgramNumberDatabase();
    addTearDown(upgraded.close);

    // Including the CHECK: a rebuild that left the old range behind would let
    // an upgraded phone reject a number a new install accepts.
    expect(await schemaFor(upgraded, 'midi_patch_program_numbers'), expected);
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
