import 'package:drift/drift.dart';

import '../../enums/time_signature.dart';
import 'academy_lessons_table.dart';

/// A thing to play, attached to the lesson that explains it.
///
/// [startBpm] and [targetBpm] are the point of the row: an exercise worth
/// practising is practised from a tempo the player can already manage up to one
/// they cannot yet, and an exercise that only named one tempo would be telling
/// them to start where they are meant to finish.
@DataClassName('AcademyExercise')
@TableIndex(
  name: 'idx_academy_exercises_lesson',
  columns: {#lessonId, #position},
)
class AcademyExercises extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get lessonId =>
      integer().references(AcademyLessons, #id, onDelete: KeyAction.cascade)();

  TextColumn get title => text().withLength(min: 1, max: 120)();

  TextColumn get instructions => text()();

  IntColumn get startBpm => integer()();

  IntColumn get targetBpm => integer()();

  TextColumn get timeSignature => textEnum<TimeSignature>()();

  IntColumn get position => integer()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  /// By title within the lesson rather than by position: a reordered exercise is
  /// still the same exercise, and an import that renumbers them should not have to
  /// clear the table first.
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {lessonId, title},
  ];
}
