import 'package:drift/drift.dart';

/// Three tables for treating a MIDI device as gear:
///
/// - `midi_device_links`: which owned pedal is which device profile.
/// - `midi_patch_program_numbers`: which Program Change number one patch
///   loads as.
/// - `midi_scene_numbers`: which of the device's Pro Scene slots one scene
///   sends as.
///
/// Purely additive - three new tables and one index, no ALTER and no DROP -
/// so a phone upgrading into it keeps every pedal, patch and board it already
/// had. Character for character what `createAll` writes on a new install,
/// checked against a fresh database by migration_test.dart.
Future<void> upgradeThroughV19(GeneratedDatabase database, int from) async {
  if (from < 19) {
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "midi_device_links" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"pedal_id" INTEGER NOT NULL UNIQUE '
      'REFERENCES pedals (id) ON DELETE RESTRICT, '
      '"device_profile_id" TEXT NOT NULL, '
      '"linked_at" TEXT NOT NULL)',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_midi_device_links_profile '
      'ON midi_device_links (device_profile_id)',
    );
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "midi_patch_program_numbers" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"patch_id" INTEGER NOT NULL UNIQUE '
      'REFERENCES patches (id) ON DELETE CASCADE, '
      '"program_number" INTEGER NOT NULL, '
      '"updated_at" TEXT NOT NULL, '
      'CHECK (program_number BETWEEN 1 AND 128))',
    );
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "midi_scene_numbers" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"scene_id" INTEGER NOT NULL UNIQUE '
      'REFERENCES scenes (id) ON DELETE CASCADE, '
      '"scene_number" INTEGER NOT NULL, '
      '"updated_at" TEXT NOT NULL, '
      'CHECK (scene_number BETWEEN 1 AND 3))',
    );
  }
}
