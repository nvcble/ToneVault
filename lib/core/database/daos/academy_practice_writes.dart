import 'package:drift/drift.dart';

import '../app_database.dart';

/// What the player did: the exercises they got through, and each sitting of practice.
///
/// Mixed into `AcademyProgressDao` from a file of its own, the same way
/// `AcademyCourseWrites` is mixed into the course DAO - one player's doings over four
/// tables is more than one file's worth of queries.
///
/// The tables and [saveProgress] are declared rather than owned: drift's generated
/// accessor mixin supplies the first three, the DAO itself supplies the last, and
/// asking for them this way is what lets these methods live outside the class that
/// has them.
mixin AcademyPracticeWrites on DatabaseAccessor<AppDatabase> {
  $AcademyExercisesTable get academyExercises;
  $AcademyExerciseProgressTable get academyExerciseProgress;
  $AcademyPracticeSessionsTable get academyPracticeSessions;

  Future<void> saveProgress(AcademyProgressCompanion progress);

  /// The ticked exercises of one lesson.
  ///
  /// Joined through the exercises rather than filtered on a lesson id of its own: a
  /// tick belongs to an exercise, and storing the lesson beside it would be a second
  /// answer to the same question that could disagree with the first.
  Stream<List<AcademyExerciseProgressRow>> watchExerciseProgress(int lessonId) {
    final exerciseIds = selectOnly(academyExercises)
      ..addColumns([academyExercises.id])
      ..where(academyExercises.lessonId.equals(lessonId));

    return (select(
      academyExerciseProgress,
    )..where((row) => row.exerciseId.isInQuery(exerciseIds))).watch();
  }

  /// Ticks an exercise, or leaves the date it was first ticked on alone.
  ///
  /// Upsert on the exercise rather than insert: a double tap on a slow phone would
  /// otherwise race to write the same row and one of them would be refused by the
  /// unique key.
  Future<void> saveExerciseDone(AcademyExerciseProgressCompanion done) {
    return into(academyExerciseProgress).insert(
      done,
      onConflict: DoNothing(target: [academyExerciseProgress.exerciseId]),
    );
  }

  /// Unticks one. Returns whether there was a tick to take away.
  Future<bool> clearExerciseDone(int exerciseId) async {
    final deletedRows = await (delete(
      academyExerciseProgress,
    )..where((row) => row.exerciseId.equals(exerciseId))).go();
    return deletedRows > 0;
  }

  /// The sittings of one lesson, most recent first.
  Stream<List<AcademyPracticeSessionRow>> watchPracticeSessions(int lessonId) {
    return (select(academyPracticeSessions)
          ..where((row) => row.lessonId.equals(lessonId))
          ..orderBy([(row) => OrderingTerm.desc(row.endedAt)]))
        .watch();
  }

  /// Files one sitting and adds it to the lesson's running total, together or not at
  /// all.
  ///
  /// One transaction because the two are the same fact written twice - the total is
  /// what the screens show, the sitting is how it was earned - and a total that had
  /// moved without a sitting behind it would be a number nothing accounted for.
  Future<void> recordPractice(
    AcademyProgressCompanion progress,
    AcademyPracticeSessionsCompanion session,
  ) {
    return transaction(() async {
      await saveProgress(progress);
      await into(academyPracticeSessions).insert(session);
    });
  }

  /// Forgets the sittings of one lesson and the ticks on its exercises.
  ///
  /// What "clear my progress" means for everything that does not live on the progress
  /// row. Deleting that row leaves both behind - the sittings hang off the lesson and
  /// the ticks off its exercises - and a lesson that says not-started while three of
  /// its exercises are still ticked is the app disagreeing with itself.
  Future<void> clearPractice(int lessonId) async {
    final exerciseIds = selectOnly(academyExercises)
      ..addColumns([academyExercises.id])
      ..where(academyExercises.lessonId.equals(lessonId));

    await (delete(
      academyExerciseProgress,
    )..where((row) => row.exerciseId.isInQuery(exerciseIds))).go();
    await (delete(
      academyPracticeSessions,
    )..where((row) => row.lessonId.equals(lessonId))).go();
  }
}
