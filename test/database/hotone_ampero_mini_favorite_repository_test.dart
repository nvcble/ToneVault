import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/hotone_ampero_mini_favorite_dao.dart';
import 'package:tone_vault/features/midi/hotone_ampero_mini/data/hotone_ampero_mini_favorite_repository.dart';

void main() {
  late AppDatabase database;
  late HotoneAmperoMiniFavoriteRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = HotoneAmperoMiniFavoriteRepository(
      HotoneAmperoMiniFavoriteDao(database),
      'hotone_ampero_mini',
    );
  });
  tearDown(() => database.close());

  test('starring works with no patch ever read from the pedal', () async {
    await repository.setFavorite(7, isFavorite: true);

    expect(await repository.watchFavoriteNumbers().first, [7]);
    expect(
      await database.hotoneAmperoMiniPatchDao
          .watchPatches('hotone_ampero_mini')
          .first,
      isEmpty,
    );
  });

  test(
    'favorites come back in slot order and starring twice keeps one',
    () async {
      await repository.setFavorite(120, isFavorite: true);
      await repository.setFavorite(3, isFavorite: true);
      await repository.setFavorite(3, isFavorite: true);

      expect(await repository.watchFavoriteNumbers().first, [3, 120]);
    },
  );

  test('unstarring removes only that slot', () async {
    await repository.setFavorite(3, isFavorite: true);
    await repository.setFavorite(4, isFavorite: true);

    await repository.setFavorite(3, isFavorite: false);

    expect(await repository.watchFavoriteNumbers().first, [4]);
  });

  test('another device profile does not see these stars', () async {
    await repository.setFavorite(3, isFavorite: true);
    final other = HotoneAmperoMiniFavoriteRepository(
      HotoneAmperoMiniFavoriteDao(database),
      'another_device',
    );

    expect(await other.watchFavoriteNumbers().first, isEmpty);
  });
}
