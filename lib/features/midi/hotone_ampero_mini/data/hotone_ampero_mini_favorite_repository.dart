import '../../../../core/database/daos/hotone_ampero_mini_favorite_dao.dart';

/// Which Ampero Mini patch slots the user has starred.
///
/// Slot indexes only - a star never depends on a patch having been read from
/// the pedal, so it works while names are still unknown.
class HotoneAmperoMiniFavoriteRepository {
  const HotoneAmperoMiniFavoriteRepository(this._dao, this.deviceProfileId);

  final HotoneAmperoMiniFavoriteDao _dao;
  final String deviceProfileId;

  /// Starred slot indexes, ascending.
  Stream<List<int>> watchFavoriteNumbers() =>
      _dao.watchFavoriteNumbers(deviceProfileId);

  Future<void> setFavorite(int patchNumber, {required bool isFavorite}) =>
      _dao.setFavorite(
        deviceProfileId: deviceProfileId,
        patchNumber: patchNumber,
        isFavorite: isFavorite,
      );
}
