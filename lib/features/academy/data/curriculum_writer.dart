import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/academy_course_dao.dart';
import '../../../core/values/lesson_notes.dart';
import '../../../core/values/theory_keys.dart';
import 'curriculum_model.dart';

/// Writes one course into the tables, matching whatever is already there.
///
/// Matched by slug at every level, never by id and never by position. A lesson kept
/// under the id it already had is a lesson the player's practice still points at;
/// clearing the course and writing it again would be simpler code and would take
/// every hour they have put in.
///
/// What the new curriculum does not have is removed, because a lesson left behind is
/// a lesson in the app that the curriculum no longer teaches. That does take the
/// progress against it, which is unavoidable: there is nothing left for it to be
/// progress on.
///
/// Positions come from the order things are written in the file, so re-ordering a
/// module in the file re-orders it in the app without any position being typed out.
class CurriculumWriter {
  const CurriculumWriter(this._dao, this._now);

  final AcademyCourseDao _dao;

  /// One moment for the whole import, passed in rather than read here, so every row
  /// of one file says it arrived together.
  final DateTime _now;

  /// Returns the id of the course, whether it was written or found.
  Future<int> writeCourse(CourseSpec spec, {required int position}) async {
    final existing = await _dao.findCourseBySlug(spec.slug);
    final courseId = existing?.id ?? await _insertCourse(spec, position);

    if (existing != null) {
      await _dao.updateCourse(
        courseId,
        AcademyCoursesCompanion(
          path: Value(spec.path),
          level: Value(spec.level),
          title: Value(spec.title),
          summary: Value(spec.summary),
          position: Value(position),
          updatedAt: Value(_now),
        ),
      );
    }

    await _writeModules(courseId, spec.modules);
    return courseId;
  }

  Future<int> _insertCourse(CourseSpec spec, int position) {
    return _dao.insertCourse(
      AcademyCoursesCompanion.insert(
        slug: spec.slug,
        path: spec.path,
        level: spec.level,
        title: spec.title,
        summary: spec.summary,
        position: position,
        createdAt: _now,
        updatedAt: _now,
      ),
    );
  }

  Future<void> _writeModules(int courseId, List<ModuleSpec> specs) async {
    final existing = {
      for (final module in await _dao.modulesOf(courseId)) module.slug: module,
    };

    for (final (position, spec) in specs.indexed) {
      final found = existing.remove(spec.slug);
      final moduleId =
          found?.id ??
          await _dao.insertModule(
            AcademyModulesCompanion.insert(
              courseId: courseId,
              slug: spec.slug,
              title: spec.title,
              summary: Value(spec.summary),
              position: position,
              createdAt: _now,
              updatedAt: _now,
            ),
          );

      if (found != null) {
        await _dao.updateModule(
          moduleId,
          AcademyModulesCompanion(
            title: Value(spec.title),
            summary: Value(spec.summary),
            position: Value(position),
            updatedAt: Value(_now),
          ),
        );
      }
      await _writeLessons(moduleId, spec.lessons);
    }

    await _dao.deleteModules(existing.values.map((module) => module.id));
  }

  Future<void> _writeLessons(int moduleId, List<LessonSpec> specs) async {
    final existing = {
      for (final lesson in await _dao.lessonsOf(moduleId)) lesson.slug: lesson,
    };

    for (final (position, spec) in specs.indexed) {
      final found = existing.remove(spec.slug);
      final lessonId =
          found?.id ??
          await _dao.insertLesson(
            AcademyLessonsCompanion.insert(
              moduleId: moduleId,
              slug: spec.slug,
              title: spec.title,
              kind: spec.kind,
              genre: Value(spec.genre),
              body: spec.body,
              objective: Value(spec.objective),
              commonMistakes: Value(encodeLessonNotes(spec.commonMistakes)),
              practiceTips: Value(encodeLessonNotes(spec.practiceTips)),
              nextSkill: Value(spec.nextSkill),
              estimatedMinutes: Value(spec.estimatedMinutes),
              suggestedBpm: Value(spec.suggestedBpm),
              timeSignature: Value(spec.timeSignature),
              theoryKeys: Value(encodeTheoryKeys(spec.theoryKeys)),
              position: position,
              createdAt: _now,
              updatedAt: _now,
            ),
          );

      if (found != null) {
        // In place, keeping the id: this is the write the player's practice hangs
        // off.
        await _dao.updateLesson(
          lessonId,
          AcademyLessonsCompanion(
            title: Value(spec.title),
            kind: Value(spec.kind),
            genre: Value(spec.genre),
            body: Value(spec.body),
            objective: Value(spec.objective),
            commonMistakes: Value(encodeLessonNotes(spec.commonMistakes)),
            practiceTips: Value(encodeLessonNotes(spec.practiceTips)),
            nextSkill: Value(spec.nextSkill),
            estimatedMinutes: Value(spec.estimatedMinutes),
            suggestedBpm: Value(spec.suggestedBpm),
            timeSignature: Value(spec.timeSignature),
            theoryKeys: Value(encodeTheoryKeys(spec.theoryKeys)),
            position: Value(position),
            updatedAt: Value(_now),
          ),
        );
      }
      await _writeExercises(lessonId, spec.exercises);
    }

    await _dao.deleteLessons(existing.values.map((lesson) => lesson.id));
  }

  /// Exercises are matched by title, because that is what makes one the same
  /// exercise: they have no slug of their own, and matching by position would make
  /// re-ordering two exercises look like re-writing both.
  Future<void> _writeExercises(int lessonId, List<ExerciseSpec> specs) async {
    final existing = {
      for (final exercise in await _dao.exercisesOf(lessonId))
        exercise.title: exercise,
    };

    for (final (position, spec) in specs.indexed) {
      final found = existing.remove(spec.title);
      if (found == null) {
        await _dao.insertExercise(
          AcademyExercisesCompanion.insert(
            lessonId: lessonId,
            title: spec.title,
            instructions: spec.instructions,
            startBpm: spec.startBpm,
            targetBpm: spec.targetBpm,
            timeSignature: spec.timeSignature,
            position: position,
            createdAt: _now,
            updatedAt: _now,
          ),
        );
        continue;
      }

      await _dao.updateExercise(
        found.id,
        AcademyExercisesCompanion(
          instructions: Value(spec.instructions),
          startBpm: Value(spec.startBpm),
          targetBpm: Value(spec.targetBpm),
          timeSignature: Value(spec.timeSignature),
          position: Value(position),
          updatedAt: Value(_now),
        ),
      );
    }

    await _dao.deleteExercises(existing.values.map((exercise) => exercise.id));
  }
}
