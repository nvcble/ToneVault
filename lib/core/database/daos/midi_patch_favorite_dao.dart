import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/midi_patch_favorites_table.dart';

part 'midi_patch_favorite_dao.g.dart';

/// Typed queries over `midi_patch_favorites`.
@DriftAccessor(tables: [MidiPatchFavorites])
class MidiPatchFavoriteDao extends DatabaseAccessor<AppDatabase>
    with _$MidiPatchFavoriteDaoMixin {
  MidiPatchFavoriteDao(super.attachedDatabase);

  /// Every favorited patch's id, app-wide - small enough that scoping by unit
  /// is left to whoever already has that unit's patch list in hand.
  Stream<Set<int>> watchFavoritePatchIds() {
    return select(
      midiPatchFavorites,
    ).watch().map((rows) => {for (final row in rows) row.patchId});
  }

  Future<void> setFavorite({required int patchId, required bool isFavorite}) async {
    if (isFavorite) {
      await into(midiPatchFavorites).insert(
        MidiPatchFavoritesCompanion.insert(patchId: patchId, createdAt: DateTime.now()),
        mode: InsertMode.insertOrIgnore,
      );
    } else {
      await (delete(
        midiPatchFavorites,
      )..where((row) => row.patchId.equals(patchId))).go();
    }
  }
}
