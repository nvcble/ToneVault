import 'package:drift/drift.dart';

import '../../enums/progress_state.dart';
import 'academy_lessons_table.dart';

/// What the player has done with one lesson.
///
/// One row per lesson, written the first time they open it. A lesson with no row
/// has not been started, which is why the row is not created up front: seeding a
/// row for every lesson in the curriculum would make an untouched app look like a
/// half-finished one, and would mean the progress the user has earned could not be
/// told apart from the rows that were there before they began.
///
/// Cascading from the lesson, which puts a duty on the importer: a re-import must
/// match lessons by slug and update them in place. Clearing a course and writing it
/// again would be correct as far as the curriculum goes and would take every hour
/// of practice with it.
@DataClassName('AcademyProgressRow')
class AcademyProgress extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get lessonId =>
      integer().references(AcademyLessons, #id, onDelete: KeyAction.cascade)();

  TextColumn get state => textEnum<ProgressState>()();

  DateTimeColumn get lastOpenedAt => dateTime()();

  DateTimeColumn get completedAt => dateTime().nullable()();

  /// Time spent with the metronome running on this lesson, in seconds. What turns
  /// a list of ticks into a practice record.
  IntColumn get practiceSeconds => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {lessonId},
  ];
}
