import 'package:drift/drift.dart';

/// The Academy: the six tables it is built on, and the four columns a lesson gained
/// once it had to read like an instructor wrote it.
///
/// v14 has no step. The rigs feature went at that version and its seven tables
/// stayed, so there was nothing for the schema to do; the number is kept rather than
/// reused so that a phone which already reported itself as 14 is not asked to run v15
/// twice.
///
/// Run last, after [upgradeThroughV13]. Nothing here reads or writes a table outside
/// the Academy.
Future<void> upgradeThroughV16(GeneratedDatabase database, int from) async {
  if (from < 15) {
    // Nothing existing is touched: six tables that were not there before, in
    // parent-before-child order so each REFERENCES clause names a table that
    // already exists.
    //
    // Character for character what `createAll` writes on a new install,
    // checked against a fresh database by migration_test.dart.
    //
    // No rows are inserted. A migration that seeded the curriculum would
    // freeze the curriculum of the day it shipped into the upgrade path, and
    // the whole point of shipping it as an asset is that it can be corrected.
    // The seeder fills these in on the next launch instead.
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "academy_courses" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"slug" TEXT NOT NULL, '
      '"path" TEXT NOT NULL, '
      '"level" TEXT NOT NULL, '
      '"title" TEXT NOT NULL, '
      '"summary" TEXT NOT NULL, '
      '"position" INTEGER NOT NULL, '
      '"created_at" TEXT NOT NULL, '
      '"updated_at" TEXT NOT NULL, '
      'UNIQUE ("slug"))',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_academy_courses_path_level '
      'ON academy_courses (path, level)',
    );
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "academy_modules" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"course_id" INTEGER NOT NULL '
      'REFERENCES academy_courses (id) ON DELETE CASCADE, '
      '"slug" TEXT NOT NULL, '
      '"title" TEXT NOT NULL, '
      '"summary" TEXT NULL, '
      '"position" INTEGER NOT NULL, '
      '"created_at" TEXT NOT NULL, '
      '"updated_at" TEXT NOT NULL, '
      'UNIQUE ("course_id", "slug"))',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_academy_modules_course '
      'ON academy_modules (course_id, position)',
    );
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "academy_lessons" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"module_id" INTEGER NOT NULL '
      'REFERENCES academy_modules (id) ON DELETE CASCADE, '
      '"slug" TEXT NOT NULL, '
      '"title" TEXT NOT NULL, '
      '"kind" TEXT NOT NULL, '
      '"genre" TEXT NULL, '
      '"body" TEXT NOT NULL, '
      '"estimated_minutes" INTEGER NULL, '
      '"suggested_bpm" INTEGER NULL, '
      '"time_signature" TEXT NULL, '
      '"theory_keys" TEXT NULL, '
      '"position" INTEGER NOT NULL, '
      '"created_at" TEXT NOT NULL, '
      '"updated_at" TEXT NOT NULL, '
      'UNIQUE ("module_id", "slug"))',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_academy_lessons_module '
      'ON academy_lessons (module_id, position)',
    );
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "academy_exercises" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"lesson_id" INTEGER NOT NULL '
      'REFERENCES academy_lessons (id) ON DELETE CASCADE, '
      '"title" TEXT NOT NULL, '
      '"instructions" TEXT NOT NULL, '
      '"start_bpm" INTEGER NOT NULL, '
      '"target_bpm" INTEGER NOT NULL, '
      '"time_signature" TEXT NOT NULL, '
      '"position" INTEGER NOT NULL, '
      '"created_at" TEXT NOT NULL, '
      '"updated_at" TEXT NOT NULL, '
      'UNIQUE ("lesson_id", "title"))',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_academy_exercises_lesson '
      'ON academy_exercises (lesson_id, position)',
    );
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "academy_progress" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"lesson_id" INTEGER NOT NULL '
      'REFERENCES academy_lessons (id) ON DELETE CASCADE, '
      '"state" TEXT NOT NULL, '
      '"last_opened_at" TEXT NOT NULL, '
      '"completed_at" TEXT NULL, '
      '"practice_seconds" INTEGER NOT NULL DEFAULT 0, '
      'UNIQUE ("lesson_id"))',
    );
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "academy_bookmarks" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"target" TEXT NOT NULL, '
      '"target_key" TEXT NOT NULL, '
      '"label" TEXT NOT NULL, '
      '"created_at" TEXT NOT NULL, '
      'UNIQUE ("target", "target_key"))',
    );
  }

  if (from < 16) {
    // The lessons are copied aside, the table is created again with the four
    // new columns, and they are copied back - the same rebuild v10 and v13
    // make, and for the same reason: SQLite adds a column after the UNIQUE
    // constraint, `createAll` writes it before, and an altered table would
    // stop reading the same as a new install's.
    //
    // Ids are carried across, so every exercise and every hour of progress
    // filed against a lesson still finds it. Foreign keys are off while a
    // migration runs, which is what makes dropping the parent safe.
    //
    // The four columns come back null on every row. A lesson written before
    // this version said nothing about any of them, and writing an objective
    // for it here would be putting words in its author's mouth; the shipped
    // curriculum fills its own in when the seeder next runs.
    await database.customStatement(
      'CREATE TABLE "academy_lessons_v15" ('
      '"id" INTEGER NOT NULL, '
      '"module_id" INTEGER NOT NULL, '
      '"slug" TEXT NOT NULL, '
      '"title" TEXT NOT NULL, '
      '"kind" TEXT NOT NULL, '
      '"genre" TEXT NULL, '
      '"body" TEXT NOT NULL, '
      '"estimated_minutes" INTEGER NULL, '
      '"suggested_bpm" INTEGER NULL, '
      '"time_signature" TEXT NULL, '
      '"theory_keys" TEXT NULL, '
      '"position" INTEGER NOT NULL, '
      '"created_at" TEXT NOT NULL, '
      '"updated_at" TEXT NOT NULL)',
    );
    await database.customStatement(
      'INSERT INTO "academy_lessons_v15" '
      'SELECT id, module_id, slug, title, kind, genre, body, '
      'estimated_minutes, suggested_bpm, time_signature, theory_keys, '
      'position, created_at, updated_at FROM academy_lessons',
    );
    await database.customStatement('DROP TABLE academy_lessons');
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "academy_lessons" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"module_id" INTEGER NOT NULL '
      'REFERENCES academy_modules (id) ON DELETE CASCADE, '
      '"slug" TEXT NOT NULL, '
      '"title" TEXT NOT NULL, '
      '"kind" TEXT NOT NULL, '
      '"genre" TEXT NULL, '
      '"body" TEXT NOT NULL, '
      '"objective" TEXT NULL, '
      '"common_mistakes" TEXT NULL, '
      '"practice_tips" TEXT NULL, '
      '"next_skill" TEXT NULL, '
      '"estimated_minutes" INTEGER NULL, '
      '"suggested_bpm" INTEGER NULL, '
      '"time_signature" TEXT NULL, '
      '"theory_keys" TEXT NULL, '
      '"position" INTEGER NOT NULL, '
      '"created_at" TEXT NOT NULL, '
      '"updated_at" TEXT NOT NULL, '
      'UNIQUE ("module_id", "slug"))',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_academy_lessons_module '
      'ON academy_lessons (module_id, position)',
    );
    await database.customStatement(
      'INSERT INTO academy_lessons '
      '(id, module_id, slug, title, kind, genre, body, estimated_minutes, '
      'suggested_bpm, time_signature, theory_keys, position, created_at, '
      'updated_at) '
      'SELECT id, module_id, slug, title, kind, genre, body, '
      'estimated_minutes, suggested_bpm, time_signature, theory_keys, '
      'position, created_at, updated_at FROM "academy_lessons_v15"',
    );
    await database.customStatement('DROP TABLE "academy_lessons_v15"');
  }
}
