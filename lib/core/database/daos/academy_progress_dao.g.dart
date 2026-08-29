// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academy_progress_dao.dart';

// ignore_for_file: type=lint
mixin _$AcademyProgressDaoMixin on DatabaseAccessor<AppDatabase> {
  $AcademyCoursesTable get academyCourses => attachedDatabase.academyCourses;
  $AcademyModulesTable get academyModules => attachedDatabase.academyModules;
  $AcademyLessonsTable get academyLessons => attachedDatabase.academyLessons;
  $AcademyProgressTable get academyProgress => attachedDatabase.academyProgress;
  $AcademyExercisesTable get academyExercises =>
      attachedDatabase.academyExercises;
  $AcademyExerciseProgressTable get academyExerciseProgress =>
      attachedDatabase.academyExerciseProgress;
  $AcademyPracticeSessionsTable get academyPracticeSessions =>
      attachedDatabase.academyPracticeSessions;
  AcademyProgressDaoManager get managers => AcademyProgressDaoManager(this);
}

class AcademyProgressDaoManager {
  final _$AcademyProgressDaoMixin _db;
  AcademyProgressDaoManager(this._db);
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
  $$AcademyProgressTableTableManager get academyProgress =>
      $$AcademyProgressTableTableManager(
        _db.attachedDatabase,
        _db.academyProgress,
      );
  $$AcademyExercisesTableTableManager get academyExercises =>
      $$AcademyExercisesTableTableManager(
        _db.attachedDatabase,
        _db.academyExercises,
      );
  $$AcademyExerciseProgressTableTableManager get academyExerciseProgress =>
      $$AcademyExerciseProgressTableTableManager(
        _db.attachedDatabase,
        _db.academyExerciseProgress,
      );
  $$AcademyPracticeSessionsTableTableManager get academyPracticeSessions =>
      $$AcademyPracticeSessionsTableTableManager(
        _db.attachedDatabase,
        _db.academyPracticeSessions,
      );
}
