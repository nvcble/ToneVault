import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/controls/data/control_draft.dart';
import 'package:tone_vault/features/patches/data/patch_draft.dart';
import 'package:tone_vault/features/patches/data/scene_pedal_repository.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import '../support/repositories.dart';

/// Which of the unit's pedals a scene uses.
///
/// A scene never creates a pedal: the unit owns its pedals once, and a scene
/// points at the ones it reaches for. So what is pinned down here is that a scene
/// can only reach inside its own unit, and that taking a pedal out takes the
/// positions it held with it.
void main() {
  late AppDatabase database;
  late ScenePedalRepository scenePedals;
  late int unitId;
  late int screamerId;
  late int delayId;
  late int driveId;
  late int sceneId;
  final now = DateTime.utc(2026, 8, 20, 10);

  /// A refusal the user can read, rather than a raw driver exception.
  Matcher failsWith(String message) => throwsA(
    isA<AppFailure>().having((failure) => failure.message, 'message', message),
  );

  /// A pedal standing inside [unitId], or on the floor when [hostPedalId] is
  /// left out.
  Future<int> addPedal(String name, {int? hostPedalId}) {
    return pedalRepository(database).createPedal(
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
    scenePedals = scenePedalRepository(database, clock: () => now);

    unitId = await pedalRepository(database).createPedal(
      const PedalDraft(
        name: 'Valeton GP-200',
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
      ),
    );
    screamerId = await addPedal('Tube Screamer', hostPedalId: unitId);
    delayId = await addPedal('Digital Delay', hostPedalId: unitId);

    // One control with a default and one without, so the seeding rule shows.
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
    await controlRepository(database).createControl(
      screamerId,
      ControlDraft.ofType(ControlType.clock, name: 'Tone'),
    );

    final patchId = await patchRepository(
      database,
    ).createPatch(unitId, const PatchDraft(name: 'Worship Clean'));
    sceneId = await sceneRepository(
      database,
    ).createScene(patchId, const SceneDraft(name: 'Verse'));
  });

  tearDown(() => database.close());

  test('a scene starts out using none of the unit\'s pedals', () async {
    // Guessing would put pedals in a sound that does not have them.
    expect(await scenePedals.watchScenePedals(sceneId).first, isEmpty);
    expect(await scenePedals.watchSceneControls(sceneId).first, isEmpty);
  });

  test('a pedal put into a scene brings its controls within reach', () async {
    await scenePedals.addPedal(sceneId: sceneId, pedalId: screamerId);

    final pedals = await scenePedals.watchScenePedals(sceneId).first;
    expect(pedals.single.name, 'Tube Screamer');

    final controls = await scenePedals.watchSceneControls(sceneId).first;
    expect(controls.map((owned) => owned.control.name), ['Drive', 'Tone']);
    // Each control comes back with the pedal it is on, because a scene of three
    // pedals with a Level each cannot say which moved otherwise.
    expect(controls.first.owner.name, 'Tube Screamer');
  });

  test('a pedal is added at whatever defaults its controls declare', () async {
    await scenePedals.addPedal(sceneId: sceneId, pedalId: screamerId);

    final values = await database.sceneDao.valuesOf(sceneId);
    // Only Drive: the knob whose default was never recorded is left unset rather
    // than filled in with a guess.
    expect(values.single.controlId, driveId);
    expect(values.single.value, 0.5);
  });

  test('adding a pedal moves the scene\'s own timestamp', () async {
    final later = DateTime.utc(2026, 8, 21, 9);
    await scenePedalRepository(
      database,
      clock: () => later,
    ).addPedal(sceneId: sceneId, pedalId: screamerId);

    final scene = await database.patchDao.findScene(sceneId);
    expect(scene!.updatedAt, later);
  });

  test('the scene\'s pedals read back in name order', () async {
    await scenePedals.addPedal(sceneId: sceneId, pedalId: screamerId);
    await scenePedals.addPedal(sceneId: sceneId, pedalId: delayId);

    // A scene is a set of sounds switched on together, so name order is the only
    // order it has - and it is the same one every read.
    final pedals = await scenePedals.watchScenePedals(sceneId).first;
    expect(pedals.map((pedal) => pedal.name), [
      'Digital Delay',
      'Tube Screamer',
    ]);
  });

  test('a scene reaches for a pedal once', () async {
    await scenePedals.addPedal(sceneId: sceneId, pedalId: screamerId);

    expect(
      () => scenePedals.addPedal(sceneId: sceneId, pedalId: screamerId),
      failsWith('This scene already uses Tube Screamer.'),
    );
  });

  test('a scene cannot reach for a pedal outside its unit', () async {
    final floorPedal = await addPedal('Caline PureSky');

    // The foreign key alone would take any pedal in the vault. A scene of a
    // Valeton reaching for a pedal on the floor is what this refuses.
    expect(
      () => scenePedals.addPedal(sceneId: sceneId, pedalId: floorPedal),
      failsWith('That pedal is not inside this unit.'),
    );
    expect(await scenePedals.watchScenePedals(sceneId).first, isEmpty);
  });

  test('nor for the unit itself, which is not inside itself', () async {
    expect(
      () => scenePedals.addPedal(sceneId: sceneId, pedalId: unitId),
      failsWith('That pedal is not inside this unit.'),
    );
  });

  test('nor for a pedal that is gone', () async {
    expect(
      () => scenePedals.addPedal(sceneId: sceneId, pedalId: 404),
      failsWith('That pedal is not inside this unit.'),
    );
  });

  test('taking a pedal out drops the positions it held', () async {
    await scenePedals.addPedal(sceneId: sceneId, pedalId: screamerId);
    await scenePedals.addPedal(sceneId: sceneId, pedalId: delayId);

    await scenePedals.removePedal(sceneId: sceneId, pedalId: screamerId);

    // Rows for a pedal the scene no longer uses are unreachable, and would come
    // back the moment it was added again, showing positions the user thought they
    // had discarded.
    expect(await database.sceneDao.valuesOf(sceneId), isEmpty);
    final pedals = await scenePedals.watchScenePedals(sceneId).first;
    expect(pedals.single.name, 'Digital Delay');
  });

  test('and leaves the pedal itself in the vault', () async {
    await scenePedals.addPedal(sceneId: sceneId, pedalId: screamerId);

    await scenePedals.removePedal(sceneId: sceneId, pedalId: screamerId);

    // It belongs to the unit, not to the scene: another scene may still use it,
    // and its history is the unit's history.
    final inside = await pedalRepository(
      database,
    ).watchComponentPedals(unitId).first;
    expect(inside.map((pedal) => pedal.name), [
      'Digital Delay',
      'Tube Screamer',
    ]);
  });

  test('taking out a pedal the scene never used says so', () async {
    expect(
      () => scenePedals.removePedal(sceneId: sceneId, pedalId: screamerId),
      failsWith('This scene does not use that pedal.'),
    );
  });

  test('two scenes share one pedal rather than a copy of it', () async {
    final patchId = (await database.patchDao.findScene(sceneId))!.patchId;
    final chorusId = await sceneRepository(
      database,
    ).createScene(patchId, const SceneDraft(name: 'Chorus'));

    await scenePedals.addPedal(sceneId: sceneId, pedalId: screamerId);
    await scenePedals.addPedal(sceneId: chorusId, pedalId: screamerId);

    // One row of gear reached from both, so the Tube Screamer's own details and
    // history are entered once.
    expect(
      (await scenePedals.watchScenePedals(sceneId).first).single.id,
      screamerId,
    );
    expect(
      (await scenePedals.watchScenePedals(chorusId).first).single.id,
      screamerId,
    );
    expect(
      await pedalRepository(database).watchComponentPedals(unitId).first,
      hasLength(2),
    );
  });

  test('deleting a scene lets go of the pedals it used', () async {
    await scenePedals.addPedal(sceneId: sceneId, pedalId: screamerId);

    // `scene_pedals` cascades from `scenes`, so the rows that pointed at the
    // pedal go without the RESTRICT on the pedal itself standing in the way.
    await sceneRepository(database).deleteScene(sceneId);

    expect(await database.sceneDao.scenePedalsOf(sceneId), isEmpty);
    expect(
      await pedalRepository(database).watchComponentPedals(unitId).first,
      hasLength(2),
    );
  });

  test('a scene that is gone is refused, in words', () async {
    await sceneRepository(database).deleteScene(sceneId);

    expect(
      () => scenePedals.addPedal(sceneId: sceneId, pedalId: screamerId),
      failsWith('That scene no longer exists.'),
    );
  });
}
