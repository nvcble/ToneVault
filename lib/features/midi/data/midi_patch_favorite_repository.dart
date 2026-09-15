import '../../../core/database/daos/midi_patch_favorite_dao.dart';

/// Which patches the user has starred, for the Patch Browser.
class MidiPatchFavoriteRepository {
  const MidiPatchFavoriteRepository(this._dao);

  final MidiPatchFavoriteDao _dao;

  Stream<Set<int>> watchFavoritePatchIds() => _dao.watchFavoritePatchIds();

  Future<void> setFavorite({required int patchId, required bool isFavorite}) =>
      _dao.setFavorite(patchId: patchId, isFavorite: isFavorite);
}
