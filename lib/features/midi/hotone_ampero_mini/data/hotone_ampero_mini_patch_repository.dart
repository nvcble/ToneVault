import 'dart:typed_data';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/hotone_ampero_mini_patch_dao.dart';
import 'hotone_ampero_mini_sync_state.dart';

/// The Ampero Mini's own patch library - independent of ToneVault's pedal
/// inventory. See `hotone_ampero_mini_patches_table.dart` for why.
class HotoneAmperoMiniPatchRepository {
  const HotoneAmperoMiniPatchRepository(this._dao, this.deviceProfileId);

  final HotoneAmperoMiniPatchDao _dao;
  final String deviceProfileId;

  Stream<List<HotoneAmperoMiniPatch>> watchPatches() =>
      _dao.watchPatches(deviceProfileId);

  Future<HotoneAmperoMiniPatch?> findByPatchNumber(int patchNumber) =>
      _dao.findByPatchNumber(deviceProfileId, patchNumber);

  /// Records a successful sync of [patchNumber] - always keeps [rawSysEx],
  /// even when [name]/[decodedJson] could not be produced from it.
  Future<void> saveSynced({
    required int patchNumber,
    String? name,
    required Uint8List rawSysEx,
    String? decodedJson,
    String? firmwareVersion,
    String? protocolVersion,
    DateTime Function()? clock,
  }) {
    return _dao.upsertPatch(
      deviceProfileId: deviceProfileId,
      patchNumber: patchNumber,
      name: name,
      rawSysEx: rawSysEx,
      decodedJson: decodedJson,
      firmwareVersion: firmwareVersion,
      protocolVersion: protocolVersion,
      lastSyncedAt: (clock ?? DateTime.now)(),
      syncState: HotoneAmperoMiniSyncState.synced.storageName,
    );
  }

  Future<void> setLocallyModified(int patchNumber, bool modified) =>
      _dao.setLocallyModified(
        deviceProfileId: deviceProfileId,
        patchNumber: patchNumber,
        modified: modified,
      );
}
