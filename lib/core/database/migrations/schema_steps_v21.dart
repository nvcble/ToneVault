import 'package:drift/drift.dart';

/// `midi_preset_captures`, for the diagnostic-capture milestone: a raw
/// SysEx preset dump kept alongside whatever the decoder made of it, so a
/// decoder improvement later can re-run against bytes already captured
/// without reconnecting to the device.
///
/// Purely additive - one new table, no ALTER and no DROP.
Future<void> upgradeThroughV21(GeneratedDatabase database, int from) async {
  if (from < 21) {
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "midi_preset_captures" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"pedal_id" INTEGER NOT NULL REFERENCES pedals (id) ON DELETE CASCADE, '
      '"device_profile_id" TEXT NOT NULL, '
      '"program_number" INTEGER NOT NULL, '
      '"raw_sys_ex" BLOB NOT NULL, '
      '"decoded_name" TEXT NULL, '
      '"decoded_summary_json" TEXT NULL, '
      '"firmware_label" TEXT NULL, '
      '"captured_at" TEXT NOT NULL, '
      'UNIQUE ("pedal_id", "program_number"))',
    );
  }
}
