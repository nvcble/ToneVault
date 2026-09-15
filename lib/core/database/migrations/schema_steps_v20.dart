import 'package:drift/drift.dart';

/// Two tables for the Patch Browser: `midi_patch_favorites` (starred
/// patches) and `midi_patch_recents` (when a patch was last successfully
/// loaded).
///
/// Purely additive - two new tables, no ALTER and no DROP - so a phone
/// upgrading into it keeps every pedal, patch and board it already had.
/// Character for character what `createAll` writes on a new install, checked
/// against a fresh database by migration_test.dart.
Future<void> upgradeThroughV20(GeneratedDatabase database, int from) async {
  if (from < 20) {
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "midi_patch_favorites" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"patch_id" INTEGER NOT NULL UNIQUE '
      'REFERENCES patches (id) ON DELETE CASCADE, '
      '"created_at" TEXT NOT NULL)',
    );
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "midi_patch_recents" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"patch_id" INTEGER NOT NULL UNIQUE '
      'REFERENCES patches (id) ON DELETE CASCADE, '
      '"last_used_at" TEXT NOT NULL)',
    );
  }
}
