import 'package:drift/drift.dart';

/// The rebuilds: the versions where a table had to be created again rather than
/// altered, and the signal chain that replaced the plain row of slots.
///
/// Run after [upgradeThroughV9] and before the Academy steps, in the same ascending
/// line. A rebuild copies the rows aside, creates the table as `createAll` writes it,
/// and copies them back under their own ids - SQLite cannot change a UNIQUE
/// constraint in place, and it adds a new column after that constraint where
/// `createAll` writes it before, so an altered table would stop reading the same as a
/// new install's.
///
/// Foreign keys are off while a migration runs, which is what makes dropping a parent
/// table safe here.
Future<void> upgradeThroughV13(GeneratedDatabase database, int from) async {
  if (from < 10) {
    // The readings are copied aside, the table is created again with the new
    // column and the wider unique key, and they are copied back.
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
    // the readings.
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
      'ALTER TABLE rig_snapshots ADD COLUMN "endpoint_summary" TEXT NULL;',
    );
  }
}
