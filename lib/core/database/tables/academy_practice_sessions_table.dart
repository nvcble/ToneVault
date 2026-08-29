import 'package:drift/drift.dart';

import 'academy_lessons_table.dart';

/// One sitting at a lesson with the metronome running.
///
/// The running total on the progress row says how long the player has practised
/// altogether; this says how that total was earned. Both are kept rather than one
/// derived from the other, because the total was already being recorded before there
/// were sessions to add up, and a phone upgrading into this table would otherwise
/// have its hours reset to nought by a sum over an empty table.
///
/// One row per sitting, never edited. A session is a thing that happened, so the way
/// to correct it is to clear the lesson's progress, which takes the sittings with it.
@DataClassName('AcademyPracticeSessionRow')
@TableIndex(
  name: 'idx_academy_practice_sessions_lesson',
  columns: {#lessonId, #endedAt},
)
class AcademyPracticeSessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get lessonId =>
      integer().references(AcademyLessons, #id, onDelete: KeyAction.cascade)();

  /// How long the metronome was counting for, in seconds.
  IntColumn get seconds => integer()();

  /// When the player left the metronome, which is when the count was taken.
  DateTimeColumn get endedAt => dateTime()();
}
