/// The tables holding what a pedal owns, as they stood at v10.
///
/// A fixture of a phone at v10 has these whether or not the upgrade steps under
/// test touch them, and a pedal delete sweeps every one of them, so a fixture
/// without them would be testing a phone that cannot exist. Spelled out rather
/// than derived from the current table classes, exactly as the version fixtures
/// beside this file are: these shapes have to keep describing v10 after the Dart
/// definitions have moved on.
const List<String> pedalRecordTablesAtV10 = [
  // v1, plus the options column the v1 to v2 step adds.
  'CREATE TABLE IF NOT EXISTS pedal_controls ('
      'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'pedal_id INTEGER NOT NULL REFERENCES pedals (id) ON DELETE RESTRICT, '
      'name TEXT NOT NULL, '
      'control_type TEXT NOT NULL, '
      'min_value REAL NOT NULL, '
      'max_value REAL NOT NULL, '
      'step REAL NULL, '
      'default_value REAL NULL, '
      'unit TEXT NULL, '
      'options TEXT NULL, '
      'display_order INTEGER NOT NULL, '
      'UNIQUE (pedal_id, name))',
  'CREATE TABLE IF NOT EXISTS configurations ('
      'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'pedal_id INTEGER NOT NULL REFERENCES pedals (id) ON DELETE RESTRICT, '
      'name TEXT NOT NULL, '
      'notes TEXT NULL, '
      'created_at TEXT NOT NULL, '
      'updated_at TEXT NOT NULL, '
      'UNIQUE (pedal_id, name))',
  // With old_text and new_text from the v3 step and control_pedal_name from the
  // v7 one.
  'CREATE TABLE IF NOT EXISTS change_logs ('
      'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'pedal_id INTEGER NOT NULL REFERENCES pedals (id) ON DELETE RESTRICT, '
      'configuration_id INTEGER NULL '
      'REFERENCES configurations (id) ON DELETE SET NULL, '
      'control_id INTEGER NULL '
      'REFERENCES pedal_controls (id) ON DELETE SET NULL, '
      'configuration_name TEXT NULL, '
      'control_name TEXT NULL, '
      'control_pedal_name TEXT NULL, '
      'change_type TEXT NOT NULL, '
      'old_value REAL NULL, '
      'new_value REAL NULL, '
      'old_text TEXT NULL, '
      'new_text TEXT NULL, '
      'reason TEXT NULL, '
      'created_at TEXT NOT NULL)',
  // The patches of a unit and the scenes inside them, added by the v9 step.
  'CREATE TABLE IF NOT EXISTS "patches" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"pedal_id" INTEGER NOT NULL REFERENCES pedals (id) ON DELETE RESTRICT, '
      '"name" TEXT NOT NULL, '
      '"notes" TEXT NULL, '
      '"created_at" TEXT NOT NULL, '
      '"updated_at" TEXT NOT NULL, '
      'UNIQUE ("pedal_id", "name"))',
  'CREATE TABLE IF NOT EXISTS "scenes" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"patch_id" INTEGER NOT NULL REFERENCES patches (id) ON DELETE CASCADE, '
      '"name" TEXT NOT NULL, '
      '"notes" TEXT NULL, '
      '"created_at" TEXT NOT NULL, '
      '"updated_at" TEXT NOT NULL, '
      'UNIQUE ("patch_id", "name"))',
  'CREATE TABLE IF NOT EXISTS "scene_pedals" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"scene_id" INTEGER NOT NULL REFERENCES scenes (id) ON DELETE CASCADE, '
      '"pedal_id" INTEGER NOT NULL REFERENCES pedals (id) ON DELETE RESTRICT, '
      'UNIQUE ("scene_id", "pedal_id"))',
];
