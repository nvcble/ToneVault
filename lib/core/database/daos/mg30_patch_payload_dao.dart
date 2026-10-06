import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/mg30_patch_payloads_table.dart';

part 'mg30_patch_payload_dao.g.dart';

/// Typed queries over `mg30_patch_payloads`.
///
/// Timestamps and error translation belong to the repository above it; this
/// class only reads and writes rows.
@DriftAccessor(tables: [Mg30PatchPayloads])
class Mg30PatchPayloadDao extends DatabaseAccessor<AppDatabase>
    with _$Mg30PatchPayloadDaoMixin {
  Mg30PatchPayloadDao(super.attachedDatabase);

  /// Replaces whatever was stored for this patch: one row says what the patch
  /// currently is, so a re-import overwrites rather than accumulating.
  Future<void> upsert(Mg30PatchPayloadsCompanion payload) async {
    await into(mg30PatchPayloads).insertOnConflictUpdate(payload);
  }

  Future<Mg30PatchPayload?> findByPatch(int patchId) {
    return (select(
      mg30PatchPayloads,
    )..where((row) => row.patchId.equals(patchId))).getSingleOrNull();
  }

  /// Every payload of one unit's patches, slot order - what a sync screen reads
  /// to say which slots are held locally.
  Future<List<Mg30PatchPayload>> payloadsOfPatches(List<int> patchIds) {
    return (select(mg30PatchPayloads)
          ..where((row) => row.patchId.isIn(patchIds))
          ..orderBy([(row) => OrderingTerm.asc(row.slot)]))
        .get();
  }
}
