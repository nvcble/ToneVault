import 'package:drift/drift.dart';

/// Schema history. Every version bump gets an entry here and a matching branch
/// in [buildMigrationStrategy], so user data is never dropped to fix a schema.
///
/// - v1: pedals, pedal_controls, configurations, configuration_values,
///   change_logs, pedal_replacements, pedalboards.
/// - v2: pedal_controls.options, the position names of a selection control.
/// - v3: change_logs.old_text and change_logs.new_text, so history can record a
///   rename or a status change as well as a knob that moved.
/// - v4: pedalboard_slots, the ordered signal chain of each rig.
const int currentSchemaVersion = 4;

MigrationStrategy buildMigrationStrategy(GeneratedDatabase database) {
  return MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      // Steps run in ascending order and each one preserves existing rows.
      //
      // They are written as literal SQL on purpose: a shipped migration has to
      // keep doing exactly what it did on the day it shipped, even after the
      // Dart table definition it came from has moved on. Deriving the statement
      // from the current definition instead would quietly rewrite history.
      if (from < 2) {
        await database.customStatement(
          'ALTER TABLE pedal_controls ADD COLUMN options TEXT NULL;',
        );
      }

      if (from < 3) {
        await database.customStatement(
          'ALTER TABLE change_logs ADD COLUMN old_text TEXT NULL;',
        );
        await database.customStatement(
          'ALTER TABLE change_logs ADD COLUMN new_text TEXT NULL;',
        );
      }

      if (from < 4) {
        // Character for character what `createAll` writes on a new install, so
        // an upgraded database and a fresh one hold the same table.
        await database.customStatement(
          'CREATE TABLE IF NOT EXISTS "pedalboard_slots" ('
          '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
          '"pedalboard_id" INTEGER NOT NULL '
          'REFERENCES pedalboards (id) ON DELETE CASCADE, '
          '"pedal_id" INTEGER NOT NULL '
          'REFERENCES pedals (id) ON DELETE RESTRICT, '
          '"position" INTEGER NOT NULL, '
          'UNIQUE ("pedalboard_id", "pedal_id"))',
        );
        await database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_pedalboard_slots_board_position '
          'ON pedalboard_slots (pedalboard_id, position)',
        );
      }

      if (to > currentSchemaVersion) {
        throw StateError('No migration registered up to schema $to.');
      }
    },
    beforeOpen: (details) async {
      // SQLite disables foreign keys per connection, so without this the
      // restrict/cascade rules declared on the tables would do nothing.
      await database.customStatement('PRAGMA foreign_keys = ON;');
    },
  );
}
