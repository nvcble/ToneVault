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
/// - v5: rig_snapshots, rig_snapshot_entries and rig_snapshot_values, a rig as
///   it stood on one date with every reading frozen.
/// - v6: pedals.host_pedal_id and pedals.multi_effects_mode, the stomps and
///   blocks inside a multi-effects unit and how that unit is organised.
/// - v7: change_logs.control_pedal_name, so a scene's history says which pedal
///   on the patch the control it moved belongs to.
const int currentSchemaVersion = 7;

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

      if (from < 5) {
        // Again character for character what `createAll` writes, checked against
        // a fresh database by migration_test.dart.
        await database.customStatement(
          'CREATE TABLE IF NOT EXISTS "rig_snapshots" ('
          '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
          '"pedalboard_id" INTEGER NOT NULL '
          'REFERENCES pedalboards (id) ON DELETE RESTRICT, '
          '"name" TEXT NOT NULL, '
          '"notes" TEXT NULL, '
          '"captured_at" TEXT NOT NULL)',
        );
        await database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_rig_snapshots_board_captured '
          'ON rig_snapshots (pedalboard_id, captured_at)',
        );
        await database.customStatement(
          'CREATE TABLE IF NOT EXISTS "rig_snapshot_entries" ('
          '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
          '"snapshot_id" INTEGER NOT NULL '
          'REFERENCES rig_snapshots (id) ON DELETE CASCADE, '
          '"pedal_id" INTEGER NOT NULL '
          'REFERENCES pedals (id) ON DELETE RESTRICT, '
          '"position" INTEGER NOT NULL, '
          '"configuration_name" TEXT NULL, '
          'UNIQUE ("snapshot_id", "pedal_id"))',
        );
        await database.customStatement(
          'CREATE INDEX IF NOT EXISTS '
          'idx_rig_snapshot_entries_snapshot_position '
          'ON rig_snapshot_entries (snapshot_id, position)',
        );
        await database.customStatement(
          'CREATE TABLE IF NOT EXISTS "rig_snapshot_values" ('
          '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
          '"entry_id" INTEGER NOT NULL '
          'REFERENCES rig_snapshot_entries (id) ON DELETE CASCADE, '
          '"control_name" TEXT NOT NULL, '
          '"control_type" TEXT NOT NULL, '
          '"value" REAL NOT NULL, '
          '"unit" TEXT NULL, '
          '"options" TEXT NULL, '
          '"display_order" INTEGER NOT NULL, '
          'UNIQUE ("entry_id", "control_name"))',
        );
      }

      if (from < 6) {
        // Both columns are nullable with no default, which is what lets SQLite
        // add them - a REFERENCES clause included - to a table that already has
        // rows in it. Every pedal already stored keeps standing on its own floor.
        await database.customStatement(
          'ALTER TABLE pedals ADD COLUMN host_pedal_id INTEGER NULL '
          'REFERENCES pedals (id) ON DELETE RESTRICT;',
        );
        await database.customStatement(
          'ALTER TABLE pedals ADD COLUMN multi_effects_mode TEXT NULL;',
        );
        await database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_pedals_host '
          'ON pedals (host_pedal_id)',
        );
      }

      if (from < 7) {
        // Nullable with no default, so the entries already written keep reading
        // exactly as they did: null means the control is on the pedal the entry
        // is filed under, which is what every one of them recorded.
        await database.customStatement(
          'ALTER TABLE change_logs ADD COLUMN control_pedal_name TEXT NULL;',
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
