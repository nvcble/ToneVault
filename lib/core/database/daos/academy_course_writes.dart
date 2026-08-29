import 'package:drift/drift.dart';

import '../app_database.dart';

/// What an import writes: the rows of a curriculum put in, corrected, or taken out.
///
/// Mixed into `AcademyCourseDao` from a file of its own, because reading the
/// curriculum and rewriting it are two jobs over one set of tables and the two of
/// them together made a file longer than anything here should be. Everything here
/// runs inside the importer's transaction; nothing here decides what to write.
///
/// The four tables are declared rather than owned: drift's generated accessor
/// mixin supplies them, and asking for them this way is what lets these methods
/// live outside the class that has them.
mixin AcademyCourseWrites on DatabaseAccessor<AppDatabase> {
  $AcademyCoursesTable get academyCourses;
  $AcademyModulesTable get academyModules;
  $AcademyLessonsTable get academyLessons;
  $AcademyExercisesTable get academyExercises;

  Future<int> insertCourse(AcademyCoursesCompanion course) =>
      into(academyCourses).insert(course);

  Future<int> insertModule(AcademyModulesCompanion module) =>
      into(academyModules).insert(module);

  Future<int> insertLesson(AcademyLessonsCompanion lesson) =>
      into(academyLessons).insert(lesson);

  Future<int> insertExercise(AcademyExercisesCompanion exercise) =>
      into(academyExercises).insert(exercise);

  Future<void> updateCourse(int courseId, AcademyCoursesCompanion changes) =>
      (update(
        academyCourses,
      )..where((row) => row.id.equals(courseId))).write(changes);

  Future<void> updateModule(int moduleId, AcademyModulesCompanion changes) =>
      (update(
        academyModules,
      )..where((row) => row.id.equals(moduleId))).write(changes);

  /// Updated in place rather than replaced, because progress cascades from the
  /// lesson: writing a lesson again under a new id would take the practice
  /// recorded against it.
  Future<void> updateLesson(int lessonId, AcademyLessonsCompanion changes) =>
      (update(
        academyLessons,
      )..where((row) => row.id.equals(lessonId))).write(changes);

  Future<void> updateExercise(
    int exerciseId,
    AcademyExercisesCompanion changes,
  ) => (update(
    academyExercises,
  )..where((row) => row.id.equals(exerciseId))).write(changes);

  /// What an import takes out: the modules, lessons and exercises a re-written
  /// curriculum no longer has.
  ///
  /// By id and in one statement each, so a course with thirty lessons is three
  /// deletes rather than thirty. The progress against a lesson goes with the
  /// lesson, which is why the importer matches by slug first and only deletes what
  /// the new curriculum genuinely does not have.
  Future<void> deleteModules(Iterable<int> ids) =>
      (delete(academyModules)..where((row) => row.id.isIn(ids))).go();

  Future<void> deleteLessons(Iterable<int> ids) =>
      (delete(academyLessons)..where((row) => row.id.isIn(ids))).go();

  Future<void> deleteExercises(Iterable<int> ids) =>
      (delete(academyExercises)..where((row) => row.id.isIn(ids))).go();

  /// Returns whether a row matched. Modules, lessons, exercises and the progress
  /// under them go with it, which the foreign keys already cascade.
  Future<bool> deleteCourse(int courseId) async {
    final deletedRows = await (delete(
      academyCourses,
    )..where((row) => row.id.equals(courseId))).go();
    return deletedRows > 0;
  }
}
