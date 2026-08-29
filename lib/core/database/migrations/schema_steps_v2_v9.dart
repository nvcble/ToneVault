import 'package:drift/drift.dart';

/// The first era: the columns the pedals and the history grew, the rigs tables as
/// they were first written, and the patches and scenes of a multi-effects unit.
///
/// One ascending run of steps, called before every later one. They are written as
/// literal SQL on purpose: a shipped migration has to keep doing exactly what it did
/// on the day it shipped, even after the Dart table definition it came from has moved
/// on. Deriving the statement from the current definition instead would quietly
/// rewrite history.
Future<void> upgradeThroughV9(GeneratedDatabase database, int from) async {
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
      'CREATE INDEX IF NOT EXISTS idx_pedals_host ON pedals (host_pedal_id)',
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

  if (from < 8) {
    // A type the enum no longer has would make every read of the row throw,
    // so the rows are refiled rather than left to be parsed. Category first:
    // it is what marks a unit now, and the second statement is what makes
    // the first unable to find anything.
    //
    // Before v11, which reads a pedal's category to decide what kind of block a
    // slot becomes.
    await database.customStatement(
      "UPDATE pedals SET category = 'multiEffects' "
      "WHERE type = 'multiEffects';",
    );
    await database.customStatement(
      "UPDATE pedals SET type = 'digital' WHERE type = 'multiEffects';",
    );
  }

  if (from < 9) {
    // Character for character what `createAll` writes, checked against a
    // fresh database by migration_test.dart. Parents before children, so
    // each REFERENCES clause names a table that already exists.
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "patches" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"pedal_id" INTEGER NOT NULL '
      'REFERENCES pedals (id) ON DELETE RESTRICT, '
      '"name" TEXT NOT NULL, '
      '"notes" TEXT NULL, '
      '"created_at" TEXT NOT NULL, '
      '"updated_at" TEXT NOT NULL, '
      'UNIQUE ("pedal_id", "name"))',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_patches_pedal ON patches (pedal_id)',
    );
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "scenes" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"patch_id" INTEGER NOT NULL '
      'REFERENCES patches (id) ON DELETE CASCADE, '
      '"name" TEXT NOT NULL, '
      '"notes" TEXT NULL, '
      '"created_at" TEXT NOT NULL, '
      '"updated_at" TEXT NOT NULL, '
      'UNIQUE ("patch_id", "name"))',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_scenes_patch ON scenes (patch_id)',
    );
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "scene_pedals" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"scene_id" INTEGER NOT NULL '
      'REFERENCES scenes (id) ON DELETE CASCADE, '
      '"pedal_id" INTEGER NOT NULL '
      'REFERENCES pedals (id) ON DELETE RESTRICT, '
      'UNIQUE ("scene_id", "pedal_id"))',
    );
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "scene_values" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"scene_id" INTEGER NOT NULL '
      'REFERENCES scenes (id) ON DELETE CASCADE, '
      '"control_id" INTEGER NOT NULL '
      'REFERENCES pedal_controls (id) ON DELETE CASCADE, '
      '"value" REAL NOT NULL, '
      'UNIQUE ("scene_id", "control_id"))',
    );
  }
}
