import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/patches/data/patch_draft.dart';
import 'package:tone_vault/features/patches/data/scene_pedal_repository.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import '../support/repositories.dart';

/// Entering a pedal from inside a scene.
///
/// Naming a block while filling in the scene that uses it is how a unit is
/// actually set up, so it is one step. What is pinned down here is where the pedal
/// lands: inside the unit the scene's patch is on, which is the only place its
/// controls, configurations and history can hang off - and in the scene as well, so
/// the user is not left wondering where it went.
void main() {
  late AppDatabase database;
  late ScenePedalRepository scenePedals;
  late int unitId;
  late int patchId;
  late int sceneId;
  final now = DateTime.utc(2026, 8, 21, 10);

  /// A refusal the user can read, rather than a raw driver exception.
  Matcher failsWith(String message) => throwsA(
    isA<AppFailure>().having((failure) => failure.message, 'message', message),
  );

  const draft = PedalDraft(
    name: 'Tube Screamer',
    type: PedalType.digital,
    category: PedalCategory.overdrive,
  );

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
    patchId = await patchRepository(
      database,
    ).createPatch(unitId, const PatchDraft(name: 'Worship Clean'));
    sceneId = await sceneRepository(
      database,
    ).createScene(patchId, const SceneDraft(name: 'Verse'));
  });

  tearDown(() => database.close());

  test('the pedal lands inside the unit and in the scene', () async {
    final pedalId = await scenePedals.addNewPedal(
      sceneId: sceneId,
      draft: draft,
    );

    final inside = await pedalRepository(
      database,
    ).watchComponentPedals(unitId).first;
    expect(inside.single.id, pedalId);
    expect(
      (await scenePedals.watchScenePedals(sceneId).first).single.id,
      pedalId,
    );
  });

  test(
    'it is filed under the unit the scene is on, not under the draft',
    () async {
      final elsewhere = await pedalRepository(database).createPedal(
        const PedalDraft(
          name: 'Zoom G3X',
          type: PedalType.digital,
          category: PedalCategory.multiEffects,
        ),
      );

      // A form that could name the host would file a block in the wrong unit, where
      // the scene it was entered from could never reach it.
      final pedalId = await scenePedals.addNewPedal(
        sceneId: sceneId,
        draft: PedalDraft(
          name: draft.name,
          type: draft.type,
          category: draft.category,
          hostPedalId: elsewhere,
        ),
      );

      final pedal = await database.pedalDao.findPedal(pedalId);
      expect(pedal!.hostPedalId, unitId);
    },
  );

  test('the details entered are kept as entered', () async {
    final pedalId = await scenePedals.addNewPedal(
      sceneId: sceneId,
      draft: draft,
    );

    final pedal = await database.pedalDao.findPedal(pedalId);
    expect(pedal!.name, 'Tube Screamer');
    expect(pedal.category, PedalCategory.overdrive);
    expect(pedal.createdAt, now);
  });

  test('another scene of the unit can then use it too', () async {
    final pedalId = await scenePedals.addNewPedal(
      sceneId: sceneId,
      draft: draft,
    );
    final chorusId = await sceneRepository(
      database,
    ).createScene(patchId, const SceneDraft(name: 'Chorus'));

    // It belongs to the unit, so it is on offer to every scene on it - which is
    // the whole reason the pedal is not owned by the scene that entered it.
    await scenePedals.addPedal(sceneId: chorusId, pedalId: pedalId);

    expect(
      (await scenePedals.watchScenePedals(chorusId).first).single.id,
      pedalId,
    );
  });

  test('a pedal with no name is refused, and none is left behind', () async {
    await expectLater(
      scenePedals.addNewPedal(
        sceneId: sceneId,
        draft: const PedalDraft(
          name: '  ',
          type: PedalType.digital,
          category: PedalCategory.overdrive,
        ),
      ),
      failsWith('Enter a pedal name.'),
    );

    // Both writes are one transaction, so a refusal cannot strand a nameless
    // pedal inside the unit.
    expect(
      await pedalRepository(database).watchComponentPedals(unitId).first,
      isEmpty,
    );
  });

  test('a scene that is gone is refused before anything is created', () async {
    await sceneRepository(database).deleteScene(sceneId);

    await expectLater(
      scenePedals.addNewPedal(sceneId: sceneId, draft: draft),
      failsWith('That scene no longer exists.'),
    );
    expect(
      await pedalRepository(database).watchComponentPedals(unitId).first,
      isEmpty,
    );
  });

  test('the scene it was added to is marked as changed', () async {
    final later = DateTime.utc(2026, 8, 22, 9);

    await scenePedalRepository(
      database,
      clock: () => later,
    ).addNewPedal(sceneId: sceneId, draft: draft);

    final scene = await database.patchDao.findScene(sceneId);
    expect(scene!.updatedAt, later);
  });
}
