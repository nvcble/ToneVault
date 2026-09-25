import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/patches/data/patch_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';

import '../support/repositories.dart';

void main() {
  late AppDatabase database;
  late int patchId;

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
  });

  tearDown(() => database.close());

  test('has no favorites until one is starred', () async {
    final favorites = await midiPatchFavoriteRepository(
      database,
    ).watchFavoritePatchIds().first;

    expect(favorites, isEmpty);
  });

  test('setFavorite(true) stars a patch', () async {
    final repository = midiPatchFavoriteRepository(database);

    await repository.setFavorite(patchId: patchId, isFavorite: true);

    final favorites = await repository.watchFavoritePatchIds().first;
    expect(favorites, {patchId});
  });

  test('setFavorite(false) unstars a patch', () async {
    final repository = midiPatchFavoriteRepository(database);
    await repository.setFavorite(patchId: patchId, isFavorite: true);

    await repository.setFavorite(patchId: patchId, isFavorite: false);

    final favorites = await repository.watchFavoritePatchIds().first;
    expect(favorites, isEmpty);
  });

  test('starring an already-starred patch does not fail', () async {
    final repository = midiPatchFavoriteRepository(database);
    await repository.setFavorite(patchId: patchId, isFavorite: true);

    await expectLater(
      repository.setFavorite(patchId: patchId, isFavorite: true),
      completes,
    );
  });
}
