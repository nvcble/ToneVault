import 'package:drift/drift.dart';

/// Two tables for a user's own MIDI setup, where it differs from a device
/// profile's shipped defaults:
///
/// - `midi_parameter_overrides`: one row per named CC parameter that has been
///   remapped, mirroring what NUX's own QuickTone app lets a user do to the
///   MG-30 itself.
/// - `midi_patch_selection_settings`: one row per device profile, for the
///   Bank Select / Program Change strategy used to load a patch by number -
///   kept apart from the parameter table because it is a sequence with its
///   own shape rather than a single named value.
///
/// Purely additive - two new tables and one index, no ALTER and no DROP - so
/// a phone upgrading into it keeps every pedal, patch and board it already
/// had. Character for character what `createAll` writes on a new install,
/// checked against a fresh database by migration_test.dart.
Future<void> upgradeThroughV18(GeneratedDatabase database, int from) async {
  if (from < 18) {
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "midi_parameter_overrides" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"device_profile_id" TEXT NOT NULL, '
      '"parameter_name" TEXT NOT NULL, '
      '"cc_number" INTEGER NOT NULL, '
      '"updated_at" TEXT NOT NULL, '
      'UNIQUE ("device_profile_id", "parameter_name"), '
      'CHECK (cc_number BETWEEN 0 AND 127))',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_midi_parameter_overrides_device '
      'ON midi_parameter_overrides (device_profile_id)',
    );
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "midi_patch_selection_settings" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"device_profile_id" TEXT NOT NULL UNIQUE, '
      '"uses_bank_select" INTEGER NULL '
      'CHECK ("uses_bank_select" IN (0, 1)), '
      '"bank_select_msb" INTEGER NULL, '
      '"bank_select_lsb" INTEGER NULL, '
      '"updated_at" TEXT NOT NULL, '
      'CHECK (bank_select_msb IS NULL OR bank_select_msb BETWEEN 0 AND 127), '
      'CHECK (bank_select_lsb IS NULL OR bank_select_lsb BETWEEN 0 AND 127))',
    );
  }
}
