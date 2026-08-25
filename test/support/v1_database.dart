import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:tone_vault/core/database/app_database.dart';

/// The v1 schema and a row in it, spelled out rather than derived from the
/// current table classes.
///
/// This is a fixture of what is already on a user's phone, so it has to keep
/// describing v1 after the Dart definitions have moved on. Only the tables the
/// upgrade steps touch are created, plus `configurations`, which `change_logs`
/// references; the rest, and every index, are untouched by the migrations.
const List<String> _v1Schema = [
  'CREATE TABLE IF NOT EXISTS pedals ('
      'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'name TEXT NOT NULL CHECK (LENGTH(name) >= 1 AND LENGTH(name) <= 100), '
      'brand TEXT NULL CHECK (LENGTH(brand) >= 1 AND LENGTH(brand) <= 60), '
      'type TEXT NOT NULL, '
      'category TEXT NOT NULL, '
      "status TEXT NOT NULL DEFAULT 'active', "
      'photo_path TEXT NULL, '
      'purchase_date TEXT NULL, '
      'notes TEXT NULL, '
      'created_at TEXT NOT NULL, '
      'updated_at TEXT NOT NULL)',
  'CREATE TABLE IF NOT EXISTS pedal_controls ('
      'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'pedal_id INTEGER NOT NULL REFERENCES pedals (id) ON DELETE RESTRICT, '
      'name TEXT NOT NULL CHECK (LENGTH(name) >= 1 AND LENGTH(name) <= 60), '
      'control_type TEXT NOT NULL, '
      'min_value REAL NOT NULL, '
      'max_value REAL NOT NULL, '
      'step REAL NULL, '
      'default_value REAL NULL, '
      'unit TEXT NULL CHECK (LENGTH(unit) >= 1 AND LENGTH(unit) <= 12), '
      'display_order INTEGER NOT NULL, '
      'UNIQUE (pedal_id, name), '
      'CHECK (max_value > min_value), '
      'CHECK (step IS NULL OR step > 0))',
  'CREATE TABLE IF NOT EXISTS configurations ('
      'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'pedal_id INTEGER NOT NULL REFERENCES pedals (id) ON DELETE RESTRICT, '
      'name TEXT NOT NULL, '
      'notes TEXT NULL, '
      'created_at TEXT NOT NULL, '
      'updated_at TEXT NOT NULL, '
      'UNIQUE (pedal_id, name))',
  // Without old_text and new_text, which is what the v2 to v3 step adds.
  'CREATE TABLE IF NOT EXISTS change_logs ('
      'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'pedal_id INTEGER NOT NULL REFERENCES pedals (id) ON DELETE RESTRICT, '
      'configuration_id INTEGER NULL '
      'REFERENCES configurations (id) ON DELETE SET NULL, '
      'control_id INTEGER NULL '
      'REFERENCES pedal_controls (id) ON DELETE SET NULL, '
      'configuration_name TEXT NULL, '
      'control_name TEXT NULL, '
      'change_type TEXT NOT NULL, '
      'old_value REAL NULL, '
      'new_value REAL NULL, '
      'reason TEXT NULL, '
      'created_at TEXT NOT NULL)',
  // Named rigs shipped in v1 with nothing to hold their chain, which is what
  // the v3 to v4 step adds.
  'CREATE TABLE IF NOT EXISTS pedalboards ('
      'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'name TEXT NOT NULL UNIQUE, '
      'description TEXT NULL, '
      'created_at TEXT NOT NULL, '
      'updated_at TEXT NOT NULL)',
  'CREATE INDEX IF NOT EXISTS idx_pedals_status ON pedals (status)',
  'CREATE INDEX IF NOT EXISTS idx_pedals_name ON pedals (name)',
  'CREATE INDEX IF NOT EXISTS idx_pedal_controls_pedal_order '
      'ON pedal_controls (pedal_id, display_order)',
];

/// Pedal 1, its one control, and one history entry about that control.
const List<String> _v1Rows = [
  'INSERT INTO pedals '
      '(id, name, brand, type, category, status, created_at, updated_at) '
      "VALUES (1, 'PureSky', 'Caline', 'analog', 'overdrive', 'active', "
      "'2024-05-01T10:00:00.000Z', '2024-05-01T10:00:00.000Z')",
  'INSERT INTO pedal_controls '
      '(id, pedal_id, name, control_type, min_value, max_value, step, '
      'display_order) '
      "VALUES (1, 1, 'Volume', 'clock', 0.0, 1.0, 0.05, 0)",
  'INSERT INTO change_logs '
      '(id, pedal_id, control_id, control_name, change_type, created_at) '
      "VALUES (1, 1, 1, 'Volume', 'controlAdded', '2024-05-01T10:00:00.000Z')",
];

/// Opens a v1 database that already holds [_v1Rows] and lets drift upgrade it.
AppDatabase openV1Database() => _openAt(1, [..._v1Schema, ..._v1Rows]);

/// The `pedals` table as it stood from v6 to v8, shared by the fixtures of both
/// versions because no step between them touches its shape.
const String _pedalsAtV7 =
    'CREATE TABLE IF NOT EXISTS pedals ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'name TEXT NOT NULL, '
    'brand TEXT NULL, '
    'type TEXT NOT NULL, '
    'category TEXT NOT NULL, '
    "status TEXT NOT NULL DEFAULT 'active', "
    'photo_path TEXT NULL, '
    'purchase_date TEXT NULL, '
    'notes TEXT NULL, '
    'host_pedal_id INTEGER NULL REFERENCES pedals (id) ON DELETE RESTRICT, '
    'multi_effects_mode TEXT NULL, '
    'created_at TEXT NOT NULL, '
    'updated_at TEXT NOT NULL)';

/// The rigs table and the snapshot tables as they stood from v5 to v9, before
/// the v10 step rebuilt `rig_snapshot_values` around the pedal a reading is on.
///
/// Every phone from v5 on has these, so a fixture of one has to have them too:
/// the v10 step reads the readings out of the old table and puts them back, and
/// a fixture missing the table would be testing a phone that cannot exist.
const List<String> _snapshotSchemaAtV9 = [
  ..._snapshotTablesToV12,
  // Without control_pedal_name, and unique per knob name alone, which is what
  // the v10 step rebuilds.
  'CREATE TABLE IF NOT EXISTS rig_snapshot_values ('
      'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'entry_id INTEGER NOT NULL '
      'REFERENCES rig_snapshot_entries (id) ON DELETE CASCADE, '
      'control_name TEXT NOT NULL, '
      'control_type TEXT NOT NULL, '
      'value REAL NOT NULL, '
      'unit TEXT NULL, '
      'options TEXT NULL, '
      'display_order INTEGER NOT NULL, '
      'UNIQUE (entry_id, control_name))',
];

/// The rigs table, the snapshots of one and the entries under them, unchanged
/// from v5 all the way to v12.
///
/// Every phone from v5 on has all three, so every fixture of one has to have them
/// too: the v13 step reads the entries out of their table and puts them back, and
/// a fixture missing it would be testing a phone that cannot exist.
const List<String> _snapshotTablesToV12 = [
  _pedalboardsTable,
  'CREATE TABLE IF NOT EXISTS rig_snapshots ('
      'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'pedalboard_id INTEGER NOT NULL '
      'REFERENCES pedalboards (id) ON DELETE RESTRICT, '
      'name TEXT NOT NULL, '
      'notes TEXT NULL, '
      'captured_at TEXT NOT NULL)',
  // Without is_enabled, which is what the v13 step rebuilds.
  'CREATE TABLE IF NOT EXISTS rig_snapshot_entries ('
      'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'snapshot_id INTEGER NOT NULL '
      'REFERENCES rig_snapshots (id) ON DELETE CASCADE, '
      'pedal_id INTEGER NOT NULL REFERENCES pedals (id) ON DELETE RESTRICT, '
      'position INTEGER NOT NULL, '
      'configuration_name TEXT NULL, '
      'UNIQUE (snapshot_id, pedal_id))',
];

/// A unit filed under the 'multiEffects' pedal type that v8 dropped.
///
/// Its category is deliberately something other than multi-effects, so the
/// upgrade has to set it rather than find it already right.
const List<String> _v7Rows = [
  'INSERT INTO pedals '
      '(id, name, type, category, status, multi_effects_mode, '
      'created_at, updated_at) '
      "VALUES (1, 'Valeton GP-200', 'multiEffects', 'other', 'active', "
      "'scene', '2026-08-01T10:00:00.000Z', '2026-08-01T10:00:00.000Z')",
];

/// Opens a v7 database holding [_v7Rows] and lets drift upgrade it.
AppDatabase openV7MultiEffectsDatabase() {
  return _openAt(7, [
    _pedalsAtV7,
    ..._snapshotSchemaAtV9,
    _pedalboardSlotsAtV10,
    ..._v7Rows,
  ]);
}

/// A rig, a snapshot of it, and one knob frozen in that snapshot.
const List<String> _v9Rows = [
  'INSERT INTO pedals (id, name, type, category, status, created_at, '
      'updated_at) '
      "VALUES (1, 'PureSky', 'analog', 'overdrive', 'active', "
      "'2026-04-01T10:00:00.000Z', '2026-04-01T10:00:00.000Z')",
  'INSERT INTO pedalboards (id, name, created_at, updated_at) '
      "VALUES (1, 'Sunday Rig', '2026-04-01T10:00:00.000Z', "
      "'2026-04-01T10:00:00.000Z')",
  'INSERT INTO rig_snapshots (id, pedalboard_id, name, captured_at) '
      "VALUES (1, 1, 'Easter 2026', '2026-04-05T09:00:00.000Z')",
  'INSERT INTO rig_snapshot_entries (id, snapshot_id, pedal_id, position, '
      'configuration_name) '
      "VALUES (1, 1, 1, 0, 'Worship Clean')",
  'INSERT INTO rig_snapshot_values (id, entry_id, control_name, control_type, '
      'value, display_order) '
      "VALUES (1, 1, 'Volume', 'clock', 0.75, 0)",
];

/// Opens a v9 database holding [_v9Rows] and lets drift upgrade it.
///
/// This is the fixture the v10 rebuild is judged on: the reading in it was
/// frozen before the table was rebuilt, and it has to come back out unchanged.
AppDatabase openV9SnapshotDatabase() {
  return _openAt(9, [
    _pedalsAtV7,
    ..._snapshotSchemaAtV9,
    _pedalboardSlotsAtV10,
    ..._v9Rows,
  ]);
}

/// The rigs table, which shipped in v1 and has not changed since.
const String _pedalboardsTable =
    'CREATE TABLE IF NOT EXISTS pedalboards ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'name TEXT NOT NULL UNIQUE, '
    'description TEXT NULL, '
    'created_at TEXT NOT NULL, '
    'updated_at TEXT NOT NULL)';

/// The chain table as it stood from v4 to v10, when a slot was a pedal on a rig
/// and nothing else: no type, no label, and never empty.
///
/// Every phone from v4 on has it, so every fixture of one has to have it too: the
/// v11 step reads the slots out of it into blocks and then drops it, and a fixture
/// missing the table would be testing a phone that cannot exist.
const String _pedalboardSlotsAtV10 =
    'CREATE TABLE IF NOT EXISTS pedalboard_slots ('
    'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    'pedalboard_id INTEGER NOT NULL '
    'REFERENCES pedalboards (id) ON DELETE CASCADE, '
    'pedal_id INTEGER NOT NULL REFERENCES pedals (id) ON DELETE RESTRICT, '
    'position INTEGER NOT NULL, '
    'UNIQUE (pedalboard_id, pedal_id))';

/// A rig with three pedals on it, chosen for what their categories become: one
/// that is a block type under the same name, one under a different name, and one
/// with no block of its own at all.
const List<String> _v10Rows = [
  'INSERT INTO pedals (id, name, type, category, status, created_at, '
      'updated_at) '
      "VALUES (1, 'PureSky', 'analog', 'overdrive', 'active', "
      "'2026-04-01T10:00:00.000Z', '2026-04-01T10:00:00.000Z')",
  'INSERT INTO pedals (id, name, type, category, status, created_at, '
      'updated_at) '
      "VALUES (2, 'NS-2', 'analog', 'noiseGate', 'active', "
      "'2026-04-01T10:00:00.000Z', '2026-04-01T10:00:00.000Z')",
  'INSERT INTO pedals (id, name, type, category, status, created_at, '
      'updated_at) '
      "VALUES (3, 'Line Selector', 'analog', 'other', 'active', "
      "'2026-04-01T10:00:00.000Z', '2026-04-01T10:00:00.000Z')",
  'INSERT INTO pedalboards (id, name, created_at, updated_at) '
      "VALUES (1, 'Sunday Rig', '2026-04-01T10:00:00.000Z', "
      "'2026-04-01T10:00:00.000Z')",
  'INSERT INTO pedalboard_slots (id, pedalboard_id, pedal_id, position) '
      'VALUES (7, 1, 2, 0)',
  'INSERT INTO pedalboard_slots (id, pedalboard_id, pedal_id, position) '
      'VALUES (8, 1, 1, 1)',
  'INSERT INTO pedalboard_slots (id, pedalboard_id, pedal_id, position) '
      'VALUES (9, 1, 3, 2)',
];

/// Opens a v10 database holding [_v10Rows] and lets drift upgrade it.
///
/// This is the fixture the v11 carry-over is judged on: the slots in it were
/// written before a block had a type, and they have to come out as the blocks
/// they always were, under the ids anything else already points at.
AppDatabase openV10ChainDatabase() {
  return _openAt(10, [
    _pedalsAtV7,
    ..._snapshotTablesToV12,
    _pedalboardSlotsAtV10,
    ..._v10Rows,
  ]);
}

/// A database that already holds [statements], at schema [version].
AppDatabase _openAt(int version, List<String> statements) {
  return AppDatabase(
    NativeDatabase.memory(
      setup: (rawDb) {
        for (final statement in statements) {
          rawDb.execute(statement);
        }
        // What tells drift there is an upgrade to run at all.
        rawDb.userVersion = version;
      },
    ),
  );
}

/// How SQLite itself describes one table and everything attached to it.
///
/// The statement is null for an index SQLite made up itself, such as the one
/// behind a UNIQUE constraint, so those are compared by name alone.
Future<List<String>> schemaFor(AppDatabase db, String table) async {
  final rows = await db
      .customSelect(
        'SELECT name, sql FROM sqlite_master WHERE tbl_name = ? ORDER BY name;',
        variables: [Variable.withString(table)],
      )
      .get();
  return [
    for (final row in rows)
      '${row.read<String>('name')}: ${row.readNullable<String>('sql')}',
  ];
}
