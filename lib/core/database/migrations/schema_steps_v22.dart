import 'package:drift/drift.dart';

/// Counts patch program numbers from 0 instead of 1, widening the CHECK
/// constraint from `BETWEEN 1 AND 128` to `BETWEEN 0 AND 127`.
///
/// A program number is now the Program Change value itself, so it has to be
/// able to hold 0 - the device's first slot, which the old range rejected
/// outright, making the very first preset of any unit impossible to store.
///
/// Existing rows shift down by one so they keep pointing at the same physical
/// slot: `buildPatchSelectionMessages` used to send `number - 1` and now sends
/// `number`, so a patch stored as 1 then and 0 now both come out as Program
/// Change 0. Nothing the user set changes meaning.
///
/// SQLite cannot alter a CHECK constraint, so the table is rebuilt the same way
/// v10 rebuilt one: the rows are copied aside, the table is created again with
/// the new constraint, and they are copied back. The `CREATE` is character for
/// character what `createAll` writes on a new install, checked against a fresh
/// database by migration_test.dart.
Future<void> upgradeThroughV22(GeneratedDatabase database, int from) async {
  if (from >= 22) {
    return;
  }
  await database.customStatement(
    'CREATE TABLE "midi_patch_program_numbers_v21" ('
    '"id" INTEGER NOT NULL, '
    '"patch_id" INTEGER NOT NULL, '
    '"program_number" INTEGER NOT NULL, '
    // TEXT, matching `storeDateTimeAsText: true` on the database itself.
    '"updated_at" TEXT NOT NULL)',
  );
  await database.customStatement(
    'INSERT INTO "midi_patch_program_numbers_v21" '
    'SELECT id, patch_id, program_number, updated_at '
    'FROM midi_patch_program_numbers',
  );
  await database.customStatement('DROP TABLE midi_patch_program_numbers');
  await database.customStatement(
    'CREATE TABLE IF NOT EXISTS "midi_patch_program_numbers" ('
    '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    '"patch_id" INTEGER NOT NULL UNIQUE '
    'REFERENCES patches (id) ON DELETE CASCADE, '
    '"program_number" INTEGER NOT NULL, '
    '"updated_at" TEXT NOT NULL, '
    'CHECK (program_number BETWEEN 0 AND 127))',
  );
  // MAX(..., 0) guards the two rows the old range allowed that the new one does
  // not: 128 shifts to 127, and a stray 0 written before the CHECK existed
  // stays 0 rather than becoming -1 and failing the copy back.
  await database.customStatement(
    'INSERT INTO midi_patch_program_numbers '
    '(id, patch_id, program_number, updated_at) '
    'SELECT id, patch_id, MAX(program_number - 1, 0), updated_at '
    'FROM "midi_patch_program_numbers_v21"',
  );
  await database.customStatement('DROP TABLE "midi_patch_program_numbers_v21"');
}
