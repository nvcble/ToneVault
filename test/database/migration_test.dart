import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/migrations.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/values/control_options.dart';
import 'package:tone_vault/features/controls/data/control_draft.dart';
import 'package:tone_vault/features/controls/data/control_repository.dart';

/// The v1 schema and a row in it, spelled out rather than derived from the
/// current table classes.
///
/// This is a fixture of what is already on a user's phone, so it has to keep
/// describing v1 after the Dart definitions have moved on. Only the two tables
/// the v1 to v2 step involves are created; the rest are untouched by it.
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
  'CREATE INDEX IF NOT EXISTS idx_pedals_status ON pedals (status)',
  'CREATE INDEX IF NOT EXISTS idx_pedals_name ON pedals (name)',
  'CREATE INDEX IF NOT EXISTS idx_pedal_controls_pedal_order '
      'ON pedal_controls (pedal_id, display_order)',
];

const List<String> _v1Rows = [
  'INSERT INTO pedals '
      '(id, name, brand, type, category, status, created_at, updated_at) '
      "VALUES (1, 'PureSky', 'Caline', 'analog', 'overdrive', 'active', "
      "'2024-05-01T10:00:00.000Z', '2024-05-01T10:00:00.000Z')",
  'INSERT INTO pedal_controls '
      '(id, pedal_id, name, control_type, min_value, max_value, step, '
      'display_order) '
      "VALUES (1, 1, 'Volume', 'clock', 0.0, 1.0, 0.05, 0)",
];

/// Opens a v1 database that already holds [_v1Rows] and lets drift upgrade it.
AppDatabase _openV1Database() {
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

void main() {
  test(
    'upgrading from v1 keeps the pedals and controls already stored',
    () async {
      final db = _openV1Database();
      addTearDown(db.close);

      final pedals = await db.pedalDao.watchPedals().first;
      final controls = await db.pedalControlDao.controlsOf(1);

      expect(pedals.single.name, 'PureSky');
      expect(controls.single.name, 'Volume');
      expect(controls.single.controlType, ControlType.clock);
      expect(controls.single.step, 0.05);
    },
  );

  test('a control that predates the options column has no positions', () async {
    final db = _openV1Database();
    addTearDown(db.close);

    final control = await db.pedalControlDao.findControl(1);

    expect(control!.options, isNull);
    expect(decodeControlOptions(control.options), isEmpty);
  });

  test('the upgraded database records the new schema version', () async {
    final db = _openV1Database();
    addTearDown(db.close);

    // Forces the connection - and with it the migration - to open.
    await db.pedalControlDao.controlsOf(1);
    final row = await db.customSelect('PRAGMA user_version;').getSingle();

    expect(row.data.values.single, currentSchemaVersion);
  });

  test(
    'the added column stores positions like a freshly created one',
    () async {
      final db = _openV1Database();
      addTearDown(db.close);
      final repository = ControlRepository(db.pedalControlDao);

      await repository.createControl(
        1,
        const ControlDraft(
          name: 'Mode',
          type: ControlType.selection,
          minValue: 0,
          maxValue: 1,
          options: ['Chorus', 'Vibrato'],
        ),
      );

      final controls = await db.pedalControlDao.controlsOf(1);
      expect(controls, hasLength(2));
      expect(decodeControlOptions(controls.last.options), [
        'Chorus',
        'Vibrato',
      ]);
    },
  );
}
