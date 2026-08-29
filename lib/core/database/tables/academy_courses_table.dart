import 'package:drift/drift.dart';

import '../../enums/learning_path.dart';
import '../../enums/skill_level.dart';

/// One course of the Academy: a path, a level, and a title.
///
/// A course carries a [slug] as well as an id. The id is this phone's own, but a
/// course arrives from a file - the curriculum that ships with the app, or one the
/// user imported - and the file has to be able to name the same course again when
/// a newer version of it arrives. The slug is that name, so a re-import updates
/// the course the user has been working through instead of standing a second copy
/// beside it.
@DataClassName('AcademyCourse')
@TableIndex(name: 'idx_academy_courses_path_level', columns: {#path, #level})
class AcademyCourses extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Stable across imports and across phones. Lower case with hyphens by
  /// convention, but nothing enforces the shape: it only has to be the same
  /// string next time.
  TextColumn get slug => text().withLength(min: 1, max: 80)();

  TextColumn get path => textEnum<LearningPath>()();

  TextColumn get level => textEnum<SkillLevel>()();

  TextColumn get title => text().withLength(min: 1, max: 120)();

  TextColumn get summary => text().withLength(min: 1, max: 400)();

  /// Where the course sits among the others at its level. Not unique: two
  /// courses sharing a position is untidy rather than wrong, and refusing an
  /// import over it would be refusing a whole file for a cosmetic clash.
  IntColumn get position => integer()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {slug},
  ];
}
