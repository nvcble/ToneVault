import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/rig_snapshot_dao.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/configurations/data/configuration_draft.dart';
import 'package:tone_vault/features/controls/data/control_draft.dart';
import 'package:tone_vault/features/patches/data/patch_draft.dart';
import 'package:tone_vault/features/pedalboards/data/pedalboard_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import 'package:tone_vault/features/snapshots/data/snapshot_draft.dart';
import '../support/repositories.dart';

/// Snapshotting a multi-effects unit, which is recorded as the scene it was on.
///
/// A unit has no configurations of its own, so without this a snapshot could say
/// the unit was on the board and nothing more. The scene is copied rather than
/// referenced, exactly as a configuration is: the scene stays editable, and what
/// was played does not.
void main() {
  late AppDatabase database;
  late int rigId;
  late int unitId;
  late int screamerId;
  late int reverbId;
  late int driveId;
  late int screamerLevelId;
  late int reverbLevelId;
  late int patchId;
  late int verseId;
  final captured = DateTime.utc(2026, 4, 5, 9, 30);

  /// A refusal the user can read, rather than a raw driver exception.
  Matcher failsWith(Object message) => throwsA(
    isA<AppFailure>().having((failure) => failure.message, 'message', message),
  );

  Future<int> addPedalInside(String name) {
    return pedalRepository(database).createPedal(
      PedalDraft(
        name: name,
        type: PedalType.digital,
        category: PedalCategory.overdrive,
        hostPedalId: unitId,
      ),
    );
  }

  Future<int> addKnob(int pedalId, String name) {
    return controlRepository(database).createControl(
      pedalId,
      ControlDraft(
        name: name,
        type: ControlType.clock,
        minValue: 0,
        maxValue: 1,
      ),
    );
  }

  Future<int> capture({
    Map<int, int> scenes = const {},
    Map<int, int> configurations = const {},
  }) {
    return rigSnapshotRepository(
      database,
      clock: () => captured,
    ).captureSnapshot(
      rigId,
      const SnapshotDraft(name: 'Easter 2026'),
      configurationChoices: configurations,
      sceneChoices: scenes,
    );
  }

  Future<SnapshotEntry> entryOf(int snapshotId) async =>
      (await database.rigSnapshotDao.watchEntries(snapshotId).first).single;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());

    rigId = await pedalboardRepository(
      database,
    ).createPedalboard(const PedalboardDraft(name: 'Hybrid Worship Rig'));
    unitId = await pedalRepository(database).createPedal(
      const PedalDraft(
        name: 'Valeton GP-200',
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
      ),
    );
    await signalChainRepository(database).addBlock(
      pedalboardId: rigId,
      blockType: SignalBlockType.multiEffect,
      pedalId: unitId,
    );

    screamerId = await addPedalInside('Tube Screamer');
    reverbId = await addPedalInside('Hall Reverb');
    driveId = await addKnob(screamerId, 'Drive');
    screamerLevelId = await addKnob(screamerId, 'Level');
    reverbLevelId = await addKnob(reverbId, 'Level');

    patchId = await patchRepository(
      database,
    ).createPatch(unitId, const PatchDraft(name: 'Worship Clean'));
    verseId = await sceneRepository(
      database,
    ).createScene(patchId, const SceneDraft(name: 'Verse'));
    for (final pedalId in [screamerId, reverbId]) {
      await scenePedalRepository(
        database,
      ).addPedal(sceneId: verseId, pedalId: pedalId);
    }
    await sceneValueRepository(
      database,
    ).setValue(sceneId: verseId, controlId: driveId, value: 0.75);
    await sceneValueRepository(
      database,
    ).setValue(sceneId: verseId, controlId: screamerLevelId, value: 0.5);
    await sceneValueRepository(
      database,
    ).setValue(sceneId: verseId, controlId: reverbLevelId, value: 0.25);
  });

  tearDown(() => database.close());

  test('the unit is recorded as the scene it was on', () async {
    final snapshotId = await capture(scenes: {unitId: verseId});

    // The patch as well as the scene: two patches may each have a "Verse".
    final entry = await entryOf(snapshotId);
    expect(entry.pedal.name, 'Valeton GP-200');
    expect(entry.entry.configurationName, 'Worship Clean · Verse');
    expect(entry.entry.position, 0);
  });

  test('every knob the scene set is frozen, on whichever pedal', () async {
    final snapshotId = await capture(scenes: {unitId: verseId});

    // One entry for the unit, and the readings of the pedals inside it under it -
    // the unit is one box in the chain however many pedals it holds.
    final entry = await entryOf(snapshotId);
    expect(
      {
        for (final value in entry.values)
          '${value.controlPedalName} ${value.controlName}': value.value,
      },
      {
        'Tube Screamer Drive': 0.75,
        'Tube Screamer Level': 0.5,
        'Hall Reverb Level': 0.25,
      },
    );
  });

  test('two knobs of the same name are both kept', () async {
    final snapshotId = await capture(scenes: {unitId: verseId});

    // Both Levels, told apart by the pedal each was on. A reading unique by name
    // alone would have kept one of them and lost the other.
    final entry = await entryOf(snapshotId);
    expect([
      for (final value in entry.values)
        if (value.controlName == 'Level') value.controlPedalName,
    ], containsAll(['Tube Screamer', 'Hall Reverb']));
  });

  test('a pedal the scene does not use is left out of it', () async {
    final delayId = await addPedalInside('Tape Delay');
    final timeId = await addKnob(delayId, 'Time');

    final snapshotId = await capture(scenes: {unitId: verseId});

    // The unit holds it, the scene does not reach for it, and a snapshot of the
    // scene claims only what the scene claims.
    final entry = await entryOf(snapshotId);
    expect(
      entry.values.map((value) => value.controlName),
      isNot(contains('Time')),
    );
    expect(await database.pedalControlDao.findControl(timeId), isNotNull);
  });

  test('editing the scene afterwards cannot rewrite the record', () async {
    final snapshotId = await capture(scenes: {unitId: verseId});

    await sceneValueRepository(
      database,
    ).setValue(sceneId: verseId, controlId: driveId, value: 0.1);
    await sceneRepository(
      database,
    ).updateScene(verseId, const SceneDraft(name: 'Verse quiet'));

    final entry = await entryOf(snapshotId);
    expect(entry.entry.configurationName, 'Worship Clean · Verse');
    expect(
      entry.values.firstWhere((value) => value.controlName == 'Drive').value,
      0.75,
    );
  });

  test('a scene of another unit is refused', () async {
    final otherId = await pedalRepository(database).createPedal(
      const PedalDraft(
        name: 'Zoom G3X',
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
      ),
    );
    final elsewhere = await patchRepository(
      database,
    ).createPatch(otherId, const PatchDraft(name: 'Rehearsal'));
    final theirScene = await sceneRepository(
      database,
    ).createScene(elsewhere, const SceneDraft(name: 'Verse'));

    await expectLater(
      capture(scenes: {unitId: theirScene}),
      failsWith(contains('no longer on its unit')),
    );
    // Nothing half-written: the refusal comes before the snapshot row.
    expect(await database.rigSnapshotDao.watchSnapshots(rigId).first, isEmpty);
  });

  test('a scene that has been deleted is refused', () async {
    await sceneRepository(database).deleteScene(verseId);

    await expectLater(
      capture(scenes: {unitId: verseId}),
      failsWith(contains('no longer on its unit')),
    );
  });

  test('one pedal cannot be recorded as being on two sounds', () async {
    final configurationId = await configurationRepository(
      database,
    ).createConfiguration(unitId, const ConfigurationDraft(name: 'Chorus'));

    // No screen offers a unit both, and letting the second answer win would
    // record a sound nobody chose.
    await expectLater(
      capture(
        scenes: {unitId: verseId},
        configurations: {unitId: configurationId},
      ),
      failsWith(contains('two settings')),
    );
  });
}
