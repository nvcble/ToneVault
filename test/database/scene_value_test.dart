import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/pedal_control_dao.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/multi_effects_mode.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/configurations/data/configuration_draft.dart';
import 'package:tone_vault/features/configurations/providers/configuration_editor.dart';
import 'package:tone_vault/features/controls/data/control_draft.dart';
import 'package:tone_vault/features/controls/data/control_repository.dart';
import 'package:tone_vault/features/pedalboards/data/pedalboard_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_repository.dart';
import 'package:tone_vault/features/snapshots/data/snapshot_draft.dart';
import '../support/repositories.dart';

/// A scene of a multi-effects unit in scene mode.
///
/// The unit is the patch: it has no controls of its own, and its configurations
/// set the controls of the pedals on it. So the thing being pinned down here is
/// that a configuration reaches the controls of the pedals inside its pedal, and
/// no further.
void main() {
  late AppDatabase database;
  late PedalRepository pedals;
  late ControlRepository controls;
  late int unitId;
  late int screamerId;
  late int driveId;
  late int decayId;
  late int sceneId;
  final now = DateTime.utc(2026, 8, 20, 10);

  /// A refusal the user can read, rather than a raw driver exception.
  Matcher failsWith(String message) => throwsA(
    isA<AppFailure>().having((failure) => failure.message, 'message', message),
  );

  Future<int> addPedalInside(int hostPedalId, String name) {
    return pedals.createPedal(
      PedalDraft(
        name: name,
        type: PedalType.digital,
        category: PedalCategory.overdrive,
        hostPedalId: hostPedalId,
      ),
    );
  }

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    pedals = pedalRepository(database, clock: () => now);
    controls = controlRepository(database);

    unitId = await pedals.createPedal(
      const PedalDraft(
        name: 'Valeton GP-200',
        type: PedalType.multiEffects,
        category: PedalCategory.multiEffects,
        multiEffectsMode: MultiEffectsMode.scene,
      ),
    );
    // Added out of alphabetical order, so the ordering under test is the query's
    // and not the order they happen to have been created in.
    final reverbId = await addPedalInside(unitId, 'Hall Reverb');
    screamerId = await addPedalInside(unitId, 'Tube Screamer');

    driveId = await controls.createControl(
      screamerId,
      // The one control with a default, so what a new scene starts out at can be
      // told apart from what it stores because it was set.
      const ControlDraft(
        name: 'Drive',
        type: ControlType.clock,
        minValue: 0,
        maxValue: 1,
        step: 0.05,
        defaultValue: 0.5,
      ),
    );
    decayId = await controls.createControl(
      reverbId,
      ControlDraft.ofType(ControlType.clock, name: 'Decay'),
    );
    sceneId = await configurationRepository(database, clock: () => now)
        .createConfiguration(
          unitId,
          const ConfigurationDraft(name: 'Chorus scene'),
        );
  });

  tearDown(() => database.close());

  Future<double?> storedValue(int controlId) async {
    final values = await database.configurationDao.valuesOf(sceneId);
    return values
        .where((value) => value.controlId == controlId)
        .map((value) => value.value)
        .firstOrNull;
  }

  test('the unit offers the controls of the pedals on its patch', () async {
    final settable = await database.pedalControlDao.settableControlsOf(unitId);

    // Pedal by pedal, by name, because that is how a patch is read down.
    expect(settable.map((control) => control.name), ['Decay', 'Drive']);
    // And the unit's own controls, of which it has none, would come first.
    expect(await database.pedalControlDao.controlsOf(unitId), isEmpty);
  });

  test('a pedal on the patch still keeps its own controls to itself', () async {
    final onlyItsOwn = await database.pedalControlDao.settableControlsOf(
      screamerId,
    );

    expect(onlyItsOwn.map((control) => control.name), ['Drive']);
  });

  test('a scene holds a value for a control on the patch', () async {
    final repository = configurationValueRepository(database, clock: () => now);

    await repository.setValue(
      configurationId: sceneId,
      controlId: driveId,
      value: 0.75,
    );
    await repository.setValue(
      configurationId: sceneId,
      controlId: decayId,
      value: 0.25,
    );

    // One scene, several pedals: exactly what scene mode is for.
    expect(await storedValue(driveId), 0.75);
    expect(await storedValue(decayId), 0.25);
  });

  test('the change is filed under the unit, which is what changed', () async {
    await configurationValueRepository(
      database,
      clock: () => now,
    ).setValue(configurationId: sceneId, controlId: driveId, value: 0.75);

    // Under the unit, because the scene is the unit's: the pedal the control sits
    // on did not change, the sound the unit makes did.
    final entries = await database.changeLogDao.entriesOf(unitId);
    expect(entries.map((entry) => entry.controlName), contains('Drive'));
  });

  test('a control on a pedal outside the unit is still refused', () async {
    final strayPedalId = await pedals.createPedal(
      const PedalDraft(
        name: 'Caline PureSky',
        type: PedalType.analog,
        category: PedalCategory.overdrive,
      ),
    );
    final strayControlId = await controls.createControl(
      strayPedalId,
      ControlDraft.ofType(ControlType.clock, name: 'Volume'),
    );

    await expectLater(
      configurationValueRepository(database).setValue(
        configurationId: sceneId,
        controlId: strayControlId,
        value: 0.5,
      ),
      failsWith('That control is no longer on this pedal.'),
    );
    expect(await storedValue(strayControlId), isNull);
  });

  test('a new scene starts out at the patch\'s own defaults', () async {
    final editor = ConfigurationEditor(
      configurationRepository(database, clock: () => now),
      configurationValueRepository(database, clock: () => now),
      PedalControlDao(database),
    );

    final second = await editor.save(
      const ConfigurationDraft(name: 'Lead scene'),
      pedalId: unitId,
    );

    // The defaults belong to the pedals on the patch, not to the unit, which
    // declares none: without them a new scene would start out empty.
    final values = await database.configurationDao.valuesOf(second);
    expect(
      {for (final value in values) value.controlId: value.value},
      {driveId: 0.5},
    );
  });

  test('a snapshot freezes the whole scene, not just the unit', () async {
    final rigId = await pedalboardRepository(
      database,
    ).createPedalboard(const PedalboardDraft(name: 'Hybrid Worship Rig'));
    await rigChainRepository(
      database,
    ).addPedal(pedalboardId: rigId, pedalId: unitId);
    await configurationValueRepository(
      database,
    ).setValue(configurationId: sceneId, controlId: driveId, value: 0.75);

    final snapshotId = await rigSnapshotRepository(database, clock: () => now)
        .captureSnapshot(
          rigId,
          const SnapshotDraft(name: 'Easter 2026'),
          configurationChoices: {unitId: sceneId},
        );

    // The unit is the only thing on the rig, so without the patch's controls the
    // record of that day would be a name and nothing else.
    final entries = await database.rigSnapshotDao
        .watchEntries(snapshotId)
        .first;
    final readings = entries.single.values;
    expect(entries.single.entry.configurationName, 'Chorus scene');
    expect(readings.map((reading) => reading.controlName), contains('Drive'));
    expect(readings.map((reading) => reading.value), contains(0.75));
  });
}
