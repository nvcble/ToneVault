import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/academy_course_dao.dart' show LessonPlace;
import '../../../core/database/daos/academy_progress_dao.dart';
import '../../../core/enums/learning_path.dart';
import '../../../core/enums/progress_state.dart';
import '../../../core/errors/app_failure.dart';
import 'lesson_tally.dart';

/// What the player has done, and the only place that decides it.
///
/// The state is never passed in from a screen. A lesson opened is in progress, a
/// lesson finished is completed, and practice adds to the seconds already there -
/// so a widget cannot write a lesson back to not-started by rebuilding with a
/// value it read a moment ago.
///
/// Nothing here is history. The change log records what the user did to their gear;
/// a lesson opened twice is not an event worth a line in it.
class ProgressRepository {
  ProgressRepository(this._dao, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AcademyProgressDao _dao;

  /// Injectable so tests can assert on exact timestamps.
  final DateTime Function() _clock;

  Stream<AcademyProgressRow?> watchProgress(int lessonId) =>
      _dao.watchProgress(lessonId);

  Stream<List<AcademyProgressRow>> watchCourseProgress(int courseId) =>
      _dao.watchCourseProgress(courseId);

  /// How far through every course of one path the player is, keyed by course id.
  ///
  /// The DAO returns the shape without the name, so this is where it becomes a
  /// [LessonTally]. A course the query says nothing about has no lessons in it, and
  /// the caller reads a missing key as [emptyTally].
  Stream<Map<int, LessonTally>> watchPathTallies(LearningPath path) =>
      _dao.watchPathTallies(path);

  Stream<LessonTally> watchCourseTally(int courseId) =>
      _dao.watchCourseTally(courseId);

  /// The lesson to carry on with, or null where there is not one.
  ///
  /// Null covers two different things that come to the same answer: a player who
  /// has never opened a lesson, and one who has finished everything they started.
  /// Neither has anything to be taken back to.
  Stream<LessonPlace?> watchUnfinished() => _dao.watchUnfinished();

  /// Called when a lesson is opened.
  ///
  /// A completed lesson stays completed: reading it again is revision, not a
  /// reset, and a player who has finished a lesson should not lose the tick for
  /// going back to check something.
  Future<void> markOpened(int lessonId) => _save(
    lessonId,
    'Could not record that this lesson was opened.',
    (existing, now) => (
      state: existing?.state == ProgressState.completed
          ? ProgressState.completed
          : ProgressState.inProgress,
      completedAt: existing?.completedAt,
      practiceSeconds: existing?.practiceSeconds ?? 0,
    ),
  );

  /// Marks a lesson done, keeping the practice already recorded against it.
  ///
  /// [AcademyProgressRow.completedAt] is written once: a player who ticks a lesson
  /// and then re-opens it keeps the date they finished it on.
  Future<void> markCompleted(int lessonId) => _save(
    lessonId,
    'Could not mark this lesson as done.',
    (existing, now) => (
      state: ProgressState.completed,
      completedAt: existing?.completedAt ?? now,
      practiceSeconds: existing?.practiceSeconds ?? 0,
    ),
  );

  /// Adds time spent practising to whatever is already recorded, and files the
  /// sitting that earned it.
  ///
  /// Added rather than set, because practice comes in sittings: a screen that
  /// wrote the length of the current one would erase every earlier one. Zero and
  /// less are refused rather than ignored - a caller passing them has a bug, and
  /// silently writing nothing would hide it.
  ///
  /// The total and the sitting are written together. The total is what a screen
  /// shows and what an upgrading phone already had; the sitting is how it was
  /// earned, and it is the row that lets the lesson say how many evenings that was.
  Future<void> addPracticeSeconds(int lessonId, int seconds) async {
    if (seconds <= 0) {
      throw const AppFailure('Practice time has to be more than nothing.');
    }

    final existing = await _dao.findProgress(lessonId);
    final now = _clock();

    await guardFailure(
      () => _dao.recordPractice(
        AcademyProgressCompanion.insert(
          lessonId: lessonId,
          state: existing?.state ?? ProgressState.inProgress,
          lastOpenedAt: now,
          completedAt: Value(existing?.completedAt),
          practiceSeconds: Value((existing?.practiceSeconds ?? 0) + seconds),
        ),
        AcademyPracticeSessionsCompanion.insert(
          lessonId: lessonId,
          seconds: seconds,
          endedAt: now,
        ),
      ),
      'Could not record this practice.',
    );
  }

  /// The sittings recorded against one lesson, most recent first.
  ///
  /// Empty is a real answer twice over: a lesson nobody has practised, and one
  /// practised before there were sittings to record. The total on the progress row
  /// is what tells those two apart.
  Stream<List<AcademyPracticeSessionRow>> watchPracticeSessions(int lessonId) =>
      _dao.watchPracticeSessions(lessonId);

  /// Which of a lesson's exercises the player has worked through, by exercise id.
  Stream<Set<int>> watchExercisesDone(int lessonId) => _dao
      .watchExerciseProgress(lessonId)
      .map((rows) => {for (final row in rows) row.exerciseId});

  /// Ticks or unticks one exercise.
  ///
  /// The date is written once: an exercise ticked, unticked and ticked again is
  /// dated the day it was last ticked, because the tick that was taken away is not
  /// a thing the app keeps.
  Future<void> setExerciseDone(int exerciseId, {required bool done}) async {
    await guardFailure(
      () => done
          ? _dao.saveExerciseDone(
              AcademyExerciseProgressCompanion.insert(
                exerciseId: exerciseId,
                completedAt: _clock(),
              ),
            )
          : _dao.clearExerciseDone(exerciseId),
      done
          ? 'Could not tick this exercise off.'
          : 'Could not untick this exercise.',
    );
  }

  /// Forgets a lesson entirely: its state, its sittings and the ticks on its
  /// exercises.
  ///
  /// The row goes rather than being set back to not-started, because that is what
  /// not-started is: no row. Returns whether there was anything to forget.
  Future<bool> clearProgress(int lessonId) => guardFailure(
    () => _dao.clearProgress(lessonId),
    'Could not clear the progress on this lesson.',
  );

  /// Reads the row, works out what it becomes, and writes it back.
  ///
  /// The three ways progress moves differ only in that middle step, so they share
  /// this rather than each spelling out the same read and the same companion.
  /// `lastOpenedAt` is always now: every one of them is the player at the lesson.
  Future<void> _save(
    int lessonId,
    String failureMessage,
    ({ProgressState state, DateTime? completedAt, int practiceSeconds})
    Function(AcademyProgressRow? existing, DateTime now)
    next,
  ) async {
    final existing = await _dao.findProgress(lessonId);
    final now = _clock();
    final moved = next(existing, now);

    await guardFailure(
      () => _dao.saveProgress(
        AcademyProgressCompanion.insert(
          lessonId: lessonId,
          state: moved.state,
          lastOpenedAt: now,
          completedAt: Value(moved.completedAt),
          practiceSeconds: Value(moved.practiceSeconds),
        ),
      ),
      failureMessage,
    );
  }
}
