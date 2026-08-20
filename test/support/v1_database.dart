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
AppDatabase openV1Database() {
  return AppDatabase(
    NativeDatabase.memory(
      setup: (rawDb) {
        for (final statement in [..._v1Schema, ..._v1Rows]) {
          rawDb.execute(statement);
        }
        // What tells drift there is an upgrade to run at all.
        rawDb.userVersion = 1;
      },
    ),
  );
}

/// The `pedals` table as it stood at v7, holding a unit filed under the
/// 'multiEffects' pedal type that v8 dropped.
///
/// Only `pedals` is created: the v8 step is the only one that runs from here, and
/// it touches nothing else. The unit's category is deliberately something other
/// than multi-effects, so the upgrade has to set it rather than find it already
/// right.
const List<String> _v7Pedals = [
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
      'updated_at TEXT NOT NULL)',
  'INSERT INTO pedals '
      '(id, name, type, category, status, multi_effects_mode, '
      'created_at, updated_at) '
      "VALUES (1, 'Valeton GP-200', 'multiEffects', 'other', 'active', "
      "'scene', '2026-08-01T10:00:00.000Z', '2026-08-01T10:00:00.000Z')",
];

/// Opens a v7 database holding [_v7Pedals] and lets drift upgrade it.
AppDatabase openV7MultiEffectsDatabase() {
  return AppDatabase(
    NativeDatabase.memory(
      setup: (rawDb) {
        for (final statement in _v7Pedals) {
          rawDb.execute(statement);
        }
        rawDb.userVersion = 7;
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
