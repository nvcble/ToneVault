import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/hotone_ampero_mini_patches_table.dart';

part 'hotone_ampero_mini_patch_dao.g.dart';

/// Typed queries over `hotone_ampero_mini_patches` - see that table's own
/// documentation for why it holds no foreign key to a pedal.
@DriftAccessor(tables: [HotoneAmperoMiniPatches])
class HotoneAmperoMiniPatchDao extends DatabaseAccessor<AppDatabase>
    with _$HotoneAmperoMiniPatchDaoMixin {
  HotoneAmperoMiniPatchDao(super.attachedDatabase);

  Stream<List<HotoneAmperoMiniPatch>> watchPatches(String deviceProfileId) {
    return (select(hotoneAmperoMiniPatches)
          ..where((row) => row.deviceProfileId.equals(deviceProfileId))
          ..orderBy([(row) => OrderingTerm.asc(row.patchNumber)]))
        .watch();
  }

  Future<HotoneAmperoMiniPatch?> findByPatchNumber(
    String deviceProfileId,
    int patchNumber,
  ) {
    return (select(hotoneAmperoMiniPatches)..where(
          (row) =>
              row.deviceProfileId.equals(deviceProfileId) &
              row.patchNumber.equals(patchNumber),
        ))
        .getSingleOrNull();
  }

  /// Replaces whatever this device profile/patch number held before - one
  /// patch number holds at most one row, the most recent sync of it.
  ///
  /// Deliberately does not list `localLabel`, so a sync overwrites the device's
  /// own fields and leaves the user's hand-typed label standing.
  Future<void> upsertPatch({
    required String deviceProfileId,
    required int patchNumber,
    String? name,
    Uint8List? rawSysEx,
    String? decodedJson,
    String? firmwareVersion,
    String? protocolVersion,
    required DateTime lastSyncedAt,
    required String syncState,
  }) {
    return into(hotoneAmperoMiniPatches).insert(
      HotoneAmperoMiniPatchesCompanion.insert(
        deviceProfileId: deviceProfileId,
        patchNumber: patchNumber,
        name: Value(name),
        rawSysEx: Value(rawSysEx),
        decodedJson: Value(decodedJson),
        firmwareVersion: Value(firmwareVersion),
        protocolVersion: Value(protocolVersion),
        lastSyncedAt: Value(lastSyncedAt),
        syncState: Value(syncState),
      ),
      onConflict: DoUpdate(
        (_) => HotoneAmperoMiniPatchesCompanion(
          name: Value(name),
          rawSysEx: Value(rawSysEx),
          decodedJson: Value(decodedJson),
          firmwareVersion: Value(firmwareVersion),
          protocolVersion: Value(protocolVersion),
          lastSyncedAt: Value(lastSyncedAt),
          syncState: Value(syncState),
          locallyModified: const Value(false),
        ),
        target: [
          hotoneAmperoMiniPatches.deviceProfileId,
          hotoneAmperoMiniPatches.patchNumber,
        ],
      ),
    );
  }

  Future<void> setLocallyModified({
    required String deviceProfileId,
    required int patchNumber,
    required bool modified,
  }) {
    return (update(hotoneAmperoMiniPatches)..where(
          (row) =>
              row.deviceProfileId.equals(deviceProfileId) &
              row.patchNumber.equals(patchNumber),
        ))
        .write(
          HotoneAmperoMiniPatchesCompanion(locallyModified: Value(modified)),
        );
  }
}
