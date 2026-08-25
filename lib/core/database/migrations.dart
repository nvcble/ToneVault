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
/// - v8: no new column. The 'multiEffects' pedal type was dropped, so the rows
///   stored as one are refiled as digital pedals of the multi-effects category.
/// - v9: patches, scenes, scene_pedals and scene_values, the sounds of a
///   multi-effects unit: a patch holds scenes, and a scene says which of the
///   unit's pedals it uses and where their controls sit.
/// - v10: rig_snapshot_values.control_pedal_name, so a snapshot of a unit on one
///   of its scenes says which pedal inside it each frozen reading came from. The
///   table is rebuilt rather than altered, because the reading is only unique per
///   pedal now and SQLite cannot change a UNIQUE constraint in place.
/// - v11: signal_blocks replaces pedalboard_slots and signal_connections joins
///   them up. A rig is designed before it is owned, so a block says what belongs
///   at that point in the chain and holds a pedal only once there is one to put
///   there; the connections say what feeds what, which a plain chain leaves empty
///   and reads off the order instead.
/// - v12: signal_endpoints, what the edges of a rig reach. A rig does not always
///   begin at a guitar and end at an amplifier, so an input, an output, a send or
///   a return says which socket it is - and a send and a return name each other,
///   which is what a trip out through an amp's effects loop and back is made of.
///   Purely additive: a rig that says nothing here reads exactly as it did.
/// - v13: rig_snapshot_entries.is_enabled and rig_snapshots.endpoint_summary, so
///   a snapshot says which pedals were switched off as well as which were on, and
///   where the rig reached at either end. The entries table is rebuilt rather than
///   altered: SQLite adds a column after the UNIQUE constraint and `createAll`
///   writes it before, so an altered table would stop reading the same as a new
///   install's.
const int currentSchemaVersion = 13;

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

      if (from < 8) {
        // A type the enum no longer has would make every read of the row throw,
        // so the rows are refiled rather than left to be parsed. Category first:
        // it is what marks a unit now, and the second statement is what makes
        // the first unable to find anything.
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
          'CREATE INDEX IF NOT EXISTS idx_patches_pedal '
          'ON patches (pedal_id)',
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

      if (from < 10) {
        // The readings are copied aside, the table is created again with the new
        // column and the wider unique key, and they are copied back. SQLite
        // cannot drop a UNIQUE constraint in place, and the created statement is
        // the same one `createAll` writes, so an upgraded phone and a new install
        // agree character for character.
        //
        // The rebuilt rows keep control_pedal_name null. Every reading written
        // before this version was one pedal's own, and null means exactly that -
        // filling in the entry's pedal name would be inventing a fact the row
        // never carried.
        await database.customStatement(
          'CREATE TABLE "rig_snapshot_values_v9" ('
          '"id" INTEGER NOT NULL, '
          '"entry_id" INTEGER NOT NULL, '
          '"control_name" TEXT NOT NULL, '
          '"control_type" TEXT NOT NULL, '
          '"value" REAL NOT NULL, '
          '"unit" TEXT NULL, '
          '"options" TEXT NULL, '
          '"display_order" INTEGER NOT NULL)',
        );
        await database.customStatement(
          'INSERT INTO "rig_snapshot_values_v9" '
          'SELECT id, entry_id, control_name, control_type, value, unit, '
          'options, display_order FROM rig_snapshot_values',
        );
        await database.customStatement('DROP TABLE rig_snapshot_values');
        await database.customStatement(
          'CREATE TABLE IF NOT EXISTS "rig_snapshot_values" ('
          '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
          '"entry_id" INTEGER NOT NULL '
          'REFERENCES rig_snapshot_entries (id) ON DELETE CASCADE, '
          '"control_name" TEXT NOT NULL, '
          '"control_pedal_name" TEXT NULL, '
          '"control_type" TEXT NOT NULL, '
          '"value" REAL NOT NULL, '
          '"unit" TEXT NULL, '
          '"options" TEXT NULL, '
          '"display_order" INTEGER NOT NULL, '
          'UNIQUE ("entry_id", "control_pedal_name", "control_name"))',
        );
        await database.customStatement(
          'INSERT INTO rig_snapshot_values '
          '(id, entry_id, control_name, control_type, value, unit, options, '
          'display_order) '
          'SELECT id, entry_id, control_name, control_type, value, unit, '
          'options, display_order FROM "rig_snapshot_values_v9"',
        );
        await database.customStatement('DROP TABLE "rig_snapshot_values_v9"');
      }

      if (from < 11) {
        // The slots are carried over into blocks rather than migrated in place:
        // pedal_id has to become nullable so a chain can be planned with places
        // still to fill, and SQLite cannot drop NOT NULL from a column.
        //
        // Ids are kept, so a snapshot or anything else already pointing at a slot
        // still finds the block it became. Every slot held a pedal, so its type
        // is read off that pedal's category - the same mapping `blockTypeFor`
        // makes, frozen here so a later edit to it cannot change what an old
        // phone's rows say they are. Each is enabled, because a slot said the
        // pedal was on the board and nothing recorded a bypass before now.
        await database.customStatement(
          'CREATE TABLE IF NOT EXISTS "signal_blocks" ('
          '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
          '"pedalboard_id" INTEGER NOT NULL '
          'REFERENCES pedalboards (id) ON DELETE CASCADE, '
          '"pedal_id" INTEGER NULL '
          'REFERENCES pedals (id) ON DELETE RESTRICT, '
          '"block_type" TEXT NOT NULL, '
          '"label" TEXT NULL, '
          '"position" INTEGER NOT NULL, '
          '"is_enabled" INTEGER NOT NULL DEFAULT 1 '
          'CHECK ("is_enabled" IN (0, 1)), '
          '"notes" TEXT NULL, '
          'UNIQUE ("pedalboard_id", "pedal_id"))',
        );
        await database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_signal_blocks_board_position '
          'ON signal_blocks (pedalboard_id, position)',
        );
        await database.customStatement(
          'INSERT INTO signal_blocks '
          '(id, pedalboard_id, pedal_id, block_type, position, is_enabled) '
          'SELECT slot.id, slot.pedalboard_id, slot.pedal_id, CASE pedal.category'
          " WHEN 'equalizer' THEN 'eq'"
          " WHEN 'noiseGate' THEN 'gate'"
          " WHEN 'ampSim' THEN 'amp'"
          " WHEN 'cabinetIr' THEN 'cab'"
          " WHEN 'multiEffects' THEN 'multiEffect'"
          " WHEN 'other' THEN 'custom'"
          ' ELSE pedal.category END, slot.position, 1 '
          'FROM pedalboard_slots AS slot '
          'JOIN pedals AS pedal ON pedal.id = slot.pedal_id',
        );
        await database.customStatement('DROP TABLE pedalboard_slots');
        await database.customStatement(
          'CREATE TABLE IF NOT EXISTS "signal_connections" ('
          '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
          '"pedalboard_id" INTEGER NOT NULL '
          'REFERENCES pedalboards (id) ON DELETE CASCADE, '
          '"source_block_id" INTEGER NOT NULL '
          'REFERENCES signal_blocks (id) ON DELETE CASCADE, '
          '"target_block_id" INTEGER NOT NULL '
          'REFERENCES signal_blocks (id) ON DELETE CASCADE, '
          '"connection_type" TEXT NOT NULL, '
          'UNIQUE ("source_block_id", "target_block_id"))',
        );
        await database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_signal_connections_board '
          'ON signal_connections (pedalboard_id)',
        );
      }

      if (from < 12) {
        // Nothing is backfilled and no existing table is touched. A rig on a
        // phone today has no row here, and none means only that the user has not
        // said yet where the chain starts or finishes - which is exactly what the
        // screen drew before this version, and still draws.
        //
        // Character for character what `createAll` writes on a new install,
        // checked against a fresh database by migration_test.dart.
        await database.customStatement(
          'CREATE TABLE IF NOT EXISTS "signal_endpoints" ('
          '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
          '"block_id" INTEGER NOT NULL '
          'REFERENCES signal_blocks (id) ON DELETE CASCADE, '
          '"destination" TEXT NULL, '
          '"source" TEXT NULL, '
          '"paired_block_id" INTEGER NULL '
          'REFERENCES signal_blocks (id) ON DELETE SET NULL, '
          '"gear" TEXT NULL, '
          '"notes" TEXT NULL, '
          'UNIQUE ("block_id"))',
        );
      }

      if (from < 13) {
        // The entries are copied aside, the table is created again with the
        // bypass column, and they are copied back - the same rebuild v10 makes of
        // the readings, and for the same reason: a column added in place would
        // land after the UNIQUE constraint, and the created statement here is the
        // one `createAll` writes.
        //
        // The rebuilt rows come back enabled, which is what the column's default
        // says and what every entry written before this version meant: a snapshot
        // recorded the pedals on the board, and nothing recorded a bypass.
        //
        // The readings under them are untouched. Ids are kept and the table comes
        // back under its own name, so every rig_snapshot_values row still finds
        // the entry it was frozen against.
        await database.customStatement(
          'CREATE TABLE "rig_snapshot_entries_v12" ('
          '"id" INTEGER NOT NULL, '
          '"snapshot_id" INTEGER NOT NULL, '
          '"pedal_id" INTEGER NOT NULL, '
          '"position" INTEGER NOT NULL, '
          '"configuration_name" TEXT NULL)',
        );
        await database.customStatement(
          'INSERT INTO "rig_snapshot_entries_v12" '
          'SELECT id, snapshot_id, pedal_id, position, configuration_name '
          'FROM rig_snapshot_entries',
        );
        await database.customStatement('DROP TABLE rig_snapshot_entries');
        await database.customStatement(
          'CREATE TABLE IF NOT EXISTS "rig_snapshot_entries" ('
          '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
          '"snapshot_id" INTEGER NOT NULL '
          'REFERENCES rig_snapshots (id) ON DELETE CASCADE, '
          '"pedal_id" INTEGER NOT NULL '
          'REFERENCES pedals (id) ON DELETE RESTRICT, '
          '"position" INTEGER NOT NULL, '
          '"configuration_name" TEXT NULL, '
          '"is_enabled" INTEGER NOT NULL DEFAULT 1 '
          'CHECK ("is_enabled" IN (0, 1)), '
          'UNIQUE ("snapshot_id", "pedal_id"))',
        );
        await database.customStatement(
          'CREATE INDEX IF NOT EXISTS '
          'idx_rig_snapshot_entries_snapshot_position '
          'ON rig_snapshot_entries (snapshot_id, position)',
        );
        await database.customStatement(
          'INSERT INTO rig_snapshot_entries '
          '(id, snapshot_id, pedal_id, position, configuration_name) '
          'SELECT id, snapshot_id, pedal_id, position, configuration_name '
          'FROM "rig_snapshot_entries_v12"',
        );
        await database.customStatement('DROP TABLE "rig_snapshot_entries_v12"');

        // Nullable with no default, so every snapshot already taken keeps saying
        // nothing about its edges - which is exactly what it recorded.
        await database.customStatement(
          'ALTER TABLE rig_snapshots '
          'ADD COLUMN "endpoint_summary" TEXT NULL;',
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
