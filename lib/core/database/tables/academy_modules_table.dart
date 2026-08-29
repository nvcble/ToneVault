import 'package:drift/drift.dart';

import 'academy_courses_table.dart';

/// A group of lessons within one course.
///
/// Cascading, unlike a course: a module has no meaning apart from the course it
/// is a part of, so removing the course removes its modules.
///
/// The slug is unique within its course rather than across the app, so two courses
/// can each have a module called `chord-shapes` without either having to know what
/// the other named its own.
@DataClassName('AcademyModule')
@TableIndex(name: 'idx_academy_modules_course', columns: {#courseId, #position})
class AcademyModules extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get courseId =>
      integer().references(AcademyCourses, #id, onDelete: KeyAction.cascade)();

  TextColumn get slug => text().withLength(min: 1, max: 80)();

  TextColumn get title => text().withLength(min: 1, max: 120)();

  TextColumn get summary => text().withLength(max: 400).nullable()();

  IntColumn get position => integer()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {courseId, slug},
  ];
}
