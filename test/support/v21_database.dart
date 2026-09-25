import 'package:tone_vault/core/database/app_database.dart';

import 'v1_database.dart' show openAt;

/// A phone at v21, where a patch's program number was counted from 1.
///
/// Only what the v22 step touches is spelled out: the numbers themselves, and
/// the two tables they hang off. Every earlier step is a no-op at this version,
/// so the tables they build are not part of the fixture.
const List<String> _v21Schema = [
  'CREATE TABLE IF NOT EXISTS pedals ('
      'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'name TEXT NOT NULL, '
      'type TEXT NOT NULL, '
      'category TEXT NOT NULL, '
      "status TEXT NOT NULL DEFAULT 'active', "
      'created_at TEXT NOT NULL, '
      'updated_at TEXT NOT NULL)',
  'CREATE TABLE IF NOT EXISTS patches ('
      'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      'pedal_id INTEGER NOT NULL REFERENCES pedals (id) ON DELETE RESTRICT, '
      'name TEXT NOT NULL, '
      'notes TEXT NULL, '
      'created_at TEXT NOT NULL, '
      'updated_at TEXT NOT NULL, '
      'UNIQUE (pedal_id, name))',
  // Counted from 1, which is what the v22 step rebuilds.
  'CREATE TABLE IF NOT EXISTS "midi_patch_program_numbers" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"patch_id" INTEGER NOT NULL UNIQUE '
      'REFERENCES patches (id) ON DELETE CASCADE, '
      '"program_number" INTEGER NOT NULL, '
      '"updated_at" TEXT NOT NULL, '
      'CHECK (program_number BETWEEN 1 AND 128))',
];

/// A unit with three numbered patches: the first slot the old range could hold,
/// one in the middle, and the very last.
final List<String> _v21Rows = [
  'INSERT INTO pedals (id, name, type, category, created_at, updated_at) '
      "VALUES (1, 'NUX MG-30', 'digital', 'multiEffects', "
      "'2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z')",
  for (final (id, name) in [
    (1, 'Worship Clean'),
    (2, 'Core Lead'),
    (3, 'Ambient'),
  ])
    'INSERT INTO patches (id, pedal_id, name, created_at, updated_at) '
        "VALUES ($id, 1, '$name', "
        "'2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z')",
  for (final (patchId, number) in [(1, 1), (2, 22), (3, 128)])
    'INSERT INTO midi_patch_program_numbers '
        '(patch_id, program_number, updated_at) '
        "VALUES ($patchId, $number, '2026-01-01T00:00:00.000Z')",
];

/// Opens a v21 database holding [_v21Rows] and lets drift upgrade it.
///
/// This is the fixture the v22 renumbering is judged on: the numbers in it were
/// stored when 1 meant the device's first slot, and they have to come back out
/// pointing at the same slots under the new counting.
AppDatabase openV21ProgramNumberDatabase() =>
    openAt(21, [..._v21Schema, ..._v21Rows]);
