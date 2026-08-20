import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/controls/data/control_draft.dart';
import 'package:tone_vault/features/patches/data/patch_draft.dart';
import 'package:tone_vault/features/patches/data/scene_value_repository.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import '../support/repositories.dart';

/// Where each control sits within one scene, and what the history says about it.
///
/// This is where the record of a multi-effects rig actually lives: the patch and
/// the scene are containers the user names, and these rows are what say the drive
/// came up before Easter. Which pedals a scene uses at all is
/// `scene_pedal_test.dart`.
void main() {
  late AppDatabase database;
  late SceneValueRepository settings;
  late int unitId;
  late int screamerId;
  late int driveId;
  late int modeId;
  late int sceneId;
  final now = DateTime.utc(2026, 8, 20, 10);

  /// A refusal the user can read, rather than a raw driver exception.
  Matcher failsWith(String message) => throwsA(
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

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    settings = sceneValueRepository(database, clock: () => now);

    unitId = await pedalRepository(database).createPedal(
      const PedalDraft(
        name: 'Valeton GP-200',
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
      ),
    );
    screamerId = await addPedalInside('Tube Screamer');

    driveId = await controlRepository(database).createControl(
      screamerId,
      const ControlDraft(
        name: 'Drive',
        type: ControlType.clock,
        minValue: 0,
        maxValue: 1,
        step: 0.05,
        defaultValue: 0.5,
      ),
    );
    modeId = await controlRepository(database).createControl(
      screamerId,
      const ControlDraft(
        name: 'Mode',
        type: ControlType.selection,
        minValue: 0,
        maxValue: 2,
        options: ['Warm', 'Bright', 'Fat'],
      ),
    );

    final patchId = await patchRepository(
      database,
    ).createPatch(unitId, const PatchDraft(name: 'Worship Clean'));
    sceneId = await sceneRepository(
      database,
    ).createScene(patchId, const SceneDraft(name: 'Verse'));
    await scenePedalRepository(
      database,
      clock: () => now,
    ).addPedal(sceneId: sceneId, pedalId: screamerId);
  });

  tearDown(() => database.close());

  Future<double?> storedValue(int controlId) async {
    final values = await database.sceneDao.valuesOf(sceneId);
    return values
        .where((value) => value.controlId == controlId)
        .map((value) => value.value)
        .firstOrNull;
  }

  Future<List<ChangeLog>> unitHistory() =>
      database.changeLogDao.entriesOf(unitId);

  test('a scene holds where one control sits', () async {
    await settings.setValue(sceneId: sceneId, controlId: driveId, value: 0.75);

    expect(await storedValue(driveId), 0.75);
    // Numerically, never as "3 o'clock": the clock face is how it is read out.
    expect(await storedValue(driveId), isA<double>());
  });

  test(
    'setting the same control again moves it rather than adding a row',
    () async {
      await settings.setValue(
        sceneId: sceneId,
        controlId: driveId,
        value: 0.75,
      );
      await settings.setValue(
        sceneId: sceneId,
        controlId: driveId,
        value: 0.25,
      );

      final values = await database.sceneDao.valuesOf(sceneId);
      expect(values.where((value) => value.controlId == driveId), hasLength(1));
      expect(await storedValue(driveId), 0.25);
    },
  );

  test('a position outside the control\'s own range is refused', () async {
    // Every control keeps its own domain, so this is the same rule a
    // configuration is held to - `ConfigurationValidator.value` decides both.
    expect(
      () => settings.setValue(sceneId: sceneId, controlId: driveId, value: 1.5),
      failsWith('Drive cannot be set to that.'),
    );
    expect(await storedValue(driveId), 0.5);
  });

  test('a selection is refused a position between two of its own', () async {
    expect(
      () => settings.setValue(sceneId: sceneId, controlId: modeId, value: 1.5),
      failsWith('Pick one of Mode\'s positions.'),
    );
  });

  test('a control on a pedal the scene does not use is refused', () async {
    final delayId = await addPedalInside('Digital Delay');
    final timeId = await controlRepository(database).createControl(
      delayId,
      ControlDraft.ofType(ControlType.clock, name: 'Time'),
    );

    // Inside the unit, so the foreign key is satisfied - but this scene never
    // reached for it, and a position it does not use is a position nobody set.
    expect(
      () => settings.setValue(sceneId: sceneId, controlId: timeId, value: 0.5),
      failsWith('That control is not in this scene.'),
    );
    expect(await storedValue(timeId), isNull);
  });

  test('a control on a pedal outside the unit likewise', () async {
    final strayId = await pedalRepository(database).createPedal(
      const PedalDraft(
        name: 'Caline PureSky',
        type: PedalType.analog,
        category: PedalCategory.overdrive,
      ),
    );
    final volumeId = await controlRepository(database).createControl(
      strayId,
      ControlDraft.ofType(ControlType.clock, name: 'Volume'),
    );

    expect(
      () =>
          settings.setValue(sceneId: sceneId, controlId: volumeId, value: 0.5),
      failsWith('That control is not in this scene.'),
    );
  });

  test('the change is filed under the unit, named for patch and scene', () async {
    await settings.setValue(sceneId: sceneId, controlId: driveId, value: 0.75);

    // Under the unit, because the scene is the unit's: the Tube Screamer inside
    // it did not change, the sound the unit makes did.
    final moved = (await unitHistory()).firstWhere(
      (entry) => entry.controlName == 'Drive',
    );
    // Both names, because "Verse" alone means nothing across four patches.
    expect(moved.configurationName, 'Worship Clean · Verse');
    expect(moved.oldValue, 0.5);
    expect(moved.newValue, 0.75);
  });

  test('and names which of the unit\'s pedals the control is on', () async {
    await settings.setValue(sceneId: sceneId, controlId: driveId, value: 0.75);

    // Nothing stops two pedals in one scene each having a Level: the pedal is
    // what tells the two entries apart.
    final moved = (await unitHistory()).firstWhere(
      (entry) => entry.controlName == 'Drive',
    );
    expect(moved.controlPedalName, 'Tube Screamer');
    expect(moved.pedalId, unitId);
  });

  test('the user\'s own reason is kept with the entry', () async {
    await settings.setValue(
      sceneId: sceneId,
      controlId: driveId,
      value: 0.75,
      reason: 'Too polite in the big room',
    );

    final moved = (await unitHistory()).firstWhere(
      (entry) => entry.controlName == 'Drive',
    );
    expect(moved.reason, 'Too polite in the big room');
  });

  test('saving the position it is already in records nothing', () async {
    final before = (await unitHistory()).length;

    await settings.setValue(sceneId: sceneId, controlId: driveId, value: 0.5);

    // Nothing moved, so a history that said it did would be worse than silence.
    expect(await unitHistory(), hasLength(before));
  });

  test('history is added to rather than rewritten', () async {
    await settings.setValue(sceneId: sceneId, controlId: driveId, value: 0.75);
    await settings.setValue(sceneId: sceneId, controlId: driveId, value: 0.25);

    // Two entries for one knob: the second position does not erase the day the
    // first was chosen.
    final drive = (await unitHistory()).where(
      (entry) => entry.controlName == 'Drive',
    );
    expect(drive.map((entry) => entry.newValue), containsAll([0.75, 0.25]));
  });

  test('clearing a position leaves the control unset, and says so', () async {
    await settings.setValue(sceneId: sceneId, controlId: driveId, value: 0.75);

    await settings.clearValue(sceneId: sceneId, controlId: driveId);

    expect(await storedValue(driveId), isNull);
    final cleared = (await unitHistory()).last;
    expect(cleared.oldValue, 0.75);
    expect(cleared.newValue, isNull);
  });

  test('clearing a control that was never set records nothing', () async {
    // Already in that state, so this is not a problem the user can act on.
    await settings.clearValue(sceneId: sceneId, controlId: modeId);

    final mode = (await unitHistory()).where(
      (entry) => entry.controlName == 'Mode',
    );
    expect(mode, isEmpty);
  });

  test('setting a control moves the scene\'s own timestamp', () async {
    final later = DateTime.utc(2026, 8, 21, 9);

    await sceneValueRepository(
      database,
      clock: () => later,
    ).setValue(sceneId: sceneId, controlId: driveId, value: 0.75);

    final scene = await database.patchDao.findScene(sceneId);
    expect(scene!.updatedAt, later);
  });

  test('a scene that is gone is refused, in words', () async {
    await sceneRepository(database).deleteScene(sceneId);

    expect(
      () =>
          settings.setValue(sceneId: sceneId, controlId: driveId, value: 0.75),
      failsWith('That scene no longer exists.'),
    );
  });

  test('deleting the scene takes its positions with it', () async {
    await settings.setValue(sceneId: sceneId, controlId: driveId, value: 0.75);

    await sceneRepository(database).deleteScene(sceneId);

    // `scene_values` cascades from `scenes`: a position has no meaning apart
    // from the sound it was part of. The history of it stays.
    expect(await database.sceneDao.valuesOf(sceneId), isEmpty);
    expect(await unitHistory(), isNotEmpty);
  });
}
