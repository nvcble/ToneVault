import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/patches/data/patch_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';

import '../support/repositories.dart';

void main() {
  late AppDatabase database;
  late int patchId;
  late int sceneAId;
  late int sceneBId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    final unitId = await pedalRepository(database).createPedal(
      const PedalDraft(
        name: 'NUX MG-30 (V5)',
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
      ),
    );
    patchId = await patchRepository(
      database,
    ).createPatch(unitId, const PatchDraft(name: 'Worship Lead'));
    sceneAId = await sceneRepository(
      database,
    ).createScene(patchId, const SceneDraft(name: 'Verse'));
    sceneBId = await sceneRepository(
      database,
    ).createScene(patchId, const SceneDraft(name: 'Chorus'));
  });

  tearDown(() => database.close());

  test('has no number until one is set', () async {
    final repository = midiSceneNumberRepository(database);

    final number = await repository.watchNumber(sceneAId).first;

    expect(number, isNull);
  });

  test('setNumber stores the scene number', () async {
    final repository = midiSceneNumberRepository(database);

    await repository.setNumber(patchId: patchId, sceneId: sceneAId, sceneNumber: 1);

    final number = await repository.watchNumber(sceneAId).first;
    expect(number!.sceneNumber, 1);
  });

  test('refuses a number outside 1-3', () async {
    final repository = midiSceneNumberRepository(database);

    await expectLater(
      repository.setNumber(patchId: patchId, sceneId: sceneAId, sceneNumber: 0),
      throwsA(isA<AppFailure>()),
    );
    await expectLater(
      repository.setNumber(patchId: patchId, sceneId: sceneAId, sceneNumber: 4),
      throwsA(isA<AppFailure>()),
    );
  });

  test('refuses a number another scene of the same patch already holds', () async {
    final repository = midiSceneNumberRepository(database);
    await repository.setNumber(patchId: patchId, sceneId: sceneAId, sceneNumber: 1);

    await expectLater(
      repository.setNumber(patchId: patchId, sceneId: sceneBId, sceneNumber: 1),
      throwsA(isA<AppFailure>()),
    );
  });

  test('changing a scene\'s own number back to itself is not a clash', () async {
    final repository = midiSceneNumberRepository(database);
    await repository.setNumber(patchId: patchId, sceneId: sceneAId, sceneNumber: 1);

    await expectLater(
      repository.setNumber(patchId: patchId, sceneId: sceneAId, sceneNumber: 1),
      completes,
    );
  });

  test('clearNumber removes it', () async {
    final repository = midiSceneNumberRepository(database);
    await repository.setNumber(patchId: patchId, sceneId: sceneAId, sceneNumber: 1);

    await repository.clearNumber(sceneAId);

    final number = await repository.watchNumber(sceneAId).first;
    expect(number, isNull);
  });
}
