import 'package:drift/drift.dart';

import 'academy_exercises_table.dart';

/// One exercise the player has worked through.
///
/// A row means done, which is why there is no state column: an exercise is either
/// something they have got through or something they have not, and a lesson's
/// exercises are half a dozen lines rather than a course's worth of stages. The
/// lesson keeps its own three states because a lesson can be open and unfinished for
/// a fortnight; an exercise cannot be half ticked.
///
/// Cascading from the exercise, and the exercise is matched by title on import, so a
/// corrected instruction keeps the tick and a renamed exercise loses it. That is the
/// right way round: a renamed exercise is a different thing to play.
@DataClassName('AcademyExerciseProgressRow')
class AcademyExerciseProgress extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get exerciseId => integer().references(
    AcademyExercises,
    #id,
    onDelete: KeyAction.cascade,
  )();

  DateTimeColumn get completedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {exerciseId},
  ];
}
