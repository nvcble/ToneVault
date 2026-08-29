import 'package:drift/drift.dart';

/// The two tables that say what the player actually did: which exercises they got
/// through, and each sitting of practice that earned the total on their progress row.
///
/// Run last, after [upgradeThroughV16]. Purely additive - two tables that were not
/// there before and one index, no ALTER and no DROP - so a phone upgrading into it
/// keeps every lesson, tick and hour it already had.
Future<void> upgradeThroughV17(GeneratedDatabase database, int from) async {
  if (from < 17) {
    // Nothing is backfilled into either one, and there is nothing that could be.
    // No phone has ever recorded which exercise of a lesson was worked through, and
    // the practice already banked against a lesson is a single number with no dates
    // in it: splitting it into invented sittings would be the app making up evenings
    // the player did not have. An empty table here reads as "not recorded", which is
    // the truth, and the running total is left exactly where it is so nobody's hours
    // go backwards.
    //
    // Character for character what `createAll` writes on a new install, checked
    // against a fresh database by migration_test.dart.
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "academy_exercise_progress" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"exercise_id" INTEGER NOT NULL '
      'REFERENCES academy_exercises (id) ON DELETE CASCADE, '
      '"completed_at" TEXT NOT NULL, '
      'UNIQUE ("exercise_id"))',
    );
    await database.customStatement(
      'CREATE TABLE IF NOT EXISTS "academy_practice_sessions" ('
      '"id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"lesson_id" INTEGER NOT NULL '
      'REFERENCES academy_lessons (id) ON DELETE CASCADE, '
      '"seconds" INTEGER NOT NULL, '
      '"ended_at" TEXT NOT NULL)',
    );
    await database.customStatement(
      'CREATE INDEX IF NOT EXISTS idx_academy_practice_sessions_lesson '
      'ON academy_practice_sessions (lesson_id, ended_at)',
    );
  }
}
