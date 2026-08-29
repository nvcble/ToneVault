import '../../../core/database/app_database.dart';
import '../../../core/database/daos/academy_course_dao.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/values/lesson_notes.dart';
import '../../../core/values/theory_keys.dart';
import 'curriculum_encoder.dart';
import 'curriculum_model.dart';

/// A curriculum file waiting to be saved somewhere.
typedef CurriculumExport = ({String fileName, String contents});

/// Reads the Academy back out of the tables as a curriculum file.
///
/// The mirror of the importer, and the reason the Academy has no course editor and
/// still lets a teacher pass a course on: a course is written in a file, imported,
/// and can be exported again as the same file.
///
/// Rows become [CourseSpec]s first rather than JSON directly, so what leaves the app
/// goes through the same shape the importer reads. Ids, positions and timestamps are
/// dropped on the way out: they belong to this phone's copy of the course, and the
/// order things are written in the file is what carries the ordering.
class CurriculumExporter {
  CurriculumExporter(this._dao, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AcademyCourseDao _dao;

  /// Injectable so tests can assert on the name of the file.
  final DateTime Function() _clock;

  /// Every course stored, as one file.
  Future<CurriculumExport> exportEverything() async {
    final courses = await _read(_dao.allCourses);

    // A file with no courses in it is one the importer refuses, so writing one and
    // letting the user find that out on the other phone would be the app handing
    // them something broken.
    if (courses.isEmpty) {
      throw const AppFailure('There is no curriculum here to export yet.');
    }

    return _file(await _specs(courses));
  }

  /// One course, for passing a single course on rather than the whole Academy.
  Future<CurriculumExport> exportCourse(int courseId) async {
    final course = await _read(() => _dao.findCourse(courseId));
    if (course == null) {
      throw const AppFailure('That course is no longer here to export.');
    }

    final specs = await _specs([course]);
    return _file(specs, slug: course.slug);
  }

  CurriculumExport _file(List<CourseSpec> specs, {String? slug}) {
    final exportedAt = _clock();
    return (
      fileName: curriculumFileName(exportedAt, slug: slug),
      contents: encodeCurriculum(specs),
    );
  }

  Future<List<CourseSpec>> _specs(List<AcademyCourse> courses) {
    return _read(() async {
      return [
        for (final course in courses)
          CourseSpec(
            slug: course.slug,
            path: course.path,
            level: course.level,
            title: course.title,
            summary: course.summary,
            modules: await _modules(course.id),
          ),
      ];
    });
  }

  Future<List<ModuleSpec>> _modules(int courseId) async {
    return [
      for (final module in await _dao.modulesOf(courseId))
        ModuleSpec(
          slug: module.slug,
          title: module.title,
          summary: module.summary,
          lessons: await _lessons(module.id),
        ),
    ];
  }

  Future<List<LessonSpec>> _lessons(int moduleId) async {
    return [
      for (final lesson in await _dao.lessonsOf(moduleId))
        LessonSpec(
          slug: lesson.slug,
          title: lesson.title,
          kind: lesson.kind,
          body: lesson.body,
          objective: lesson.objective,
          commonMistakes: decodeLessonNotes(lesson.commonMistakes),
          practiceTips: decodeLessonNotes(lesson.practiceTips),
          nextSkill: lesson.nextSkill,
          genre: lesson.genre,
          estimatedMinutes: lesson.estimatedMinutes,
          suggestedBpm: lesson.suggestedBpm,
          timeSignature: lesson.timeSignature,
          theoryKeys: decodeTheoryKeys(lesson.theoryKeys),
          exercises: await _exercises(lesson.id),
        ),
    ];
  }

  Future<List<ExerciseSpec>> _exercises(int lessonId) async {
    return [
      for (final exercise in await _dao.exercisesOf(lessonId))
        ExerciseSpec(
          title: exercise.title,
          instructions: exercise.instructions,
          startBpm: exercise.startBpm,
          targetBpm: exercise.targetBpm,
          timeSignature: exercise.timeSignature,
        ),
    ];
  }

  Future<T> _read<T>(Future<T> Function() operation) =>
      guardFailure(operation, 'Could not read the curriculum to export it.');
}
