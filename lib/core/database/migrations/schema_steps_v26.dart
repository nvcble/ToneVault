import 'package:drift/drift.dart';

/// `mg30_patch_payloads`, the exact MG-30 V5 bytes a library patch was decoded
/// from - see that table for why they are worth keeping.
///
/// Purely additive: one new table and one index, no ALTER and no DROP, so a
/// phone upgrading into it keeps every patch it already had. Character for
/// character what `createAll` writes on a new install, checked against a fresh
/// database by migration_test.dart.
Future<void> upgradeThroughV26(GeneratedDatabase database, int from) async {
  if (from < 26) {
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "mg30_patch_payloads" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"patch_id" INTEGER NOT NULL UNIQUE '
      'REFERENCES patches (id) ON DELETE CASCADE, '
      '"slot" INTEGER NOT NULL, '
      '"source" TEXT NOT NULL, '
      '"firmware_label" TEXT NULL, '
      '"raw_record" BLOB NOT NULL, '
      '"imported_at" TEXT NOT NULL)',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_mg30_patch_payloads_slot '
      'ON mg30_patch_payloads (slot)',
    );
  }
}
