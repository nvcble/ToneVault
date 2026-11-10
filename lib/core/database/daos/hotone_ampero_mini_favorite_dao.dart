import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/hotone_ampero_mini_favorites_table.dart';

part 'hotone_ampero_mini_favorite_dao.g.dart';

/// Typed queries over `hotone_ampero_mini_favorites`.
@DriftAccessor(tables: [HotoneAmperoMiniFavorites])
class HotoneAmperoMiniFavoriteDao extends DatabaseAccessor<AppDatabase>
    with _$HotoneAmperoMiniFavoriteDaoMixin {
  HotoneAmperoMiniFavoriteDao(super.attachedDatabase);

  /// The starred slot indexes for one device, ascending.
  Stream<List<int>> watchFavoriteNumbers(String deviceProfileId) {
    return (select(hotoneAmperoMiniFavorites)
          ..where((row) => row.deviceProfileId.equals(deviceProfileId))
          ..orderBy([(row) => OrderingTerm.asc(row.patchNumber)]))
        .watch()
        .map((rows) => [for (final row in rows) row.patchNumber]);
  }

  Future<void> setFavorite({
    required String deviceProfileId,
    required int patchNumber,
    required bool isFavorite,
    DateTime Function()? clock,
  }) async {
    if (isFavorite) {
      await into(hotoneAmperoMiniFavorites).insert(
        HotoneAmperoMiniFavoritesCompanion.insert(
          deviceProfileId: deviceProfileId,
          patchNumber: patchNumber,
          createdAt: (clock ?? DateTime.now)(),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    } else {
      await (delete(hotoneAmperoMiniFavorites)..where(
            (row) =>
                row.deviceProfileId.equals(deviceProfileId) &
                row.patchNumber.equals(patchNumber),
          ))
          .go();
    }
  }
}
