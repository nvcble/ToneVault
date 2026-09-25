import 'package:drift/drift.dart';

/// `hotone_ampero_mini_patches`, for the independent Hotone Ampero Mini MIDI
/// controller: one row per synchronized (or not-yet-synchronized) patch slot,
/// with no foreign key to a pedal - see that table's own documentation for
/// why it is deliberately not shaped like `midi_preset_captures`.
///
/// Purely additive - one new table, no ALTER and no DROP.
Future<void> upgradeThroughV23(GeneratedDatabase database, int from) async {
  if (from < 23) {
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "hotone_ampero_mini_patches" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"device_profile_id" TEXT NOT NULL, '
      '"patch_number" INTEGER NOT NULL, '
      '"name" TEXT NULL, '
      '"raw_sys_ex" BLOB NULL, '
      '"decoded_json" TEXT NULL, '
      '"firmware_version" TEXT NULL, '
      '"protocol_version" TEXT NULL, '
      '"last_synced_at" TEXT NULL, '
      '"locally_modified" INTEGER NOT NULL DEFAULT 0 CHECK ("locally_modified" IN (0, 1)), '
      '"sync_state" TEXT NOT NULL DEFAULT \'notSynced\', '
      'UNIQUE ("device_profile_id", "patch_number"))',
    );
  }
}
