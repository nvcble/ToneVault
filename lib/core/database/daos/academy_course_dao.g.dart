// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academy_course_dao.dart';

// ignore_for_file: type=lint
mixin _$AcademyCourseDaoMixin on DatabaseAccessor<AppDatabase> {
  $AcademyCoursesTable get academyCourses => attachedDatabase.academyCourses;
  $AcademyModulesTable get academyModules => attachedDatabase.academyModules;
  $AcademyLessonsTable get academyLessons => attachedDatabase.academyLessons;
  $AcademyExercisesTable get academyExercises =>
      attachedDatabase.academyExercises;
  AcademyCourseDaoManager get managers => AcademyCourseDaoManager(this);
}

class AcademyCourseDaoManager {
  final _$AcademyCourseDaoMixin _db;
  AcademyCourseDaoManager(this._db);
  $$AcademyCoursesTableTableManager get academyCourses =>
      $$AcademyCoursesTableTableManager(
        _db.attachedDatabase,
        _db.academyCourses,
      );
  $$AcademyModulesTableTableManager get academyModules =>
      $$AcademyModulesTableTableManager(
        _db.attachedDatabase,
        _db.academyModules,
      );
  $$AcademyLessonsTableTableManager get academyLessons =>
      $$AcademyLessonsTableTableManager(
        _db.attachedDatabase,
        _db.academyLessons,
      );
  $$AcademyExercisesTableTableManager get academyExercises =>
      $$AcademyExercisesTableTableManager(
        _db.attachedDatabase,
        _db.academyExercises,
      );
}
