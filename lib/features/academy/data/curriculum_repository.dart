import '../../../core/database/app_database.dart';
import '../../../core/database/daos/academy_course_dao.dart';
import '../../../core/enums/learning_path.dart';
import '../../../core/enums/skill_level.dart';

/// The curriculum, read.
///
/// Read-only on purpose. The curriculum is not something the user writes: it
/// ships with the app and arrives through the importer, which is the only thing
/// that writes these tables and has its own rules about matching a course to one
/// already stored. A repository with a `createCourse` on it would be the first
/// half of the admin screens this app is not going to have.
///
/// There is no validation here for the same reason there is no writing: nothing
/// reaches these tables without going through the importer's schema check first.
class CurriculumRepository {
  const CurriculumRepository(this._dao);

  final AcademyCourseDao _dao;

  Stream<List<AcademyCourse>> watchCourses(
    LearningPath path,
    SkillLevel level,
  ) => _dao.watchCourses(path, level);

  /// Every course of one path, in teaching order: Beginner first, Professional
  /// last, and each level's courses in the order the curriculum puts them.
  ///
  /// Sorted here rather than in SQL because the order of the levels is the order
  /// the enum declares them in, and the column holds their names - which SQL would
  /// sort alphabetically, putting Advanced before Beginner.
  ///
  /// The comparator falls all the way through to the slug rather than leaning on
  /// the order the rows arrived in: `List.sort` is not promised to be stable, so a
  /// tie left to it is a list that can rearrange itself between two reads.
  Stream<List<AcademyCourse>> watchPathCourses(LearningPath path) {
    return _dao.watchPathCourses(path).map((courses) {
      return [...courses]..sort((one, other) {
        if (one.level != other.level) {
          return one.level.index.compareTo(other.level.index);
        }
        if (one.position != other.position) {
          return one.position.compareTo(other.position);
        }
        return one.slug.compareTo(other.slug);
      });
    });
  }

  /// One course. Null where it is not there, which is what a link kept from
  /// before a re-import that dropped it comes back as.
  Stream<AcademyCourse?> watchCourse(int courseId) =>
      _dao.watchCourse(courseId);

  Stream<List<AcademyModule>> watchModules(int courseId) =>
      _dao.watchModules(courseId);

  Stream<List<AcademyLesson>> watchLessons(int moduleId) =>
      _dao.watchLessons(moduleId);

  /// Watched rather than read once, so a lesson replaced by an import while its
  /// screen is open is noticed instead of shown as it used to be.
  Stream<AcademyLesson?> watchLesson(int lessonId) =>
      _dao.watchLesson(lessonId);

  Stream<List<AcademyExercise>> watchExercises(int lessonId) =>
      _dao.watchExercises(lessonId);

  /// The lessons that match what was typed, with the course each sits in.
  ///
  /// Nothing for a query too short to be worth searching on: one letter matches most
  /// of the curriculum, and a list of everything is not an answer.
  Future<List<LessonPlace>> searchLessons(String text) async {
    final query = text.trim();
    return query.length < 2 ? const [] : _dao.searchLessons(query);
  }

  /// Where the lesson a bookmark points at lives, or null where the curriculum no
  /// longer has it - which an import that dropped a course can do to an old bookmark.
  Future<LessonPlace?> findLessonPlace(String slug) =>
      _dao.findLessonPlace(slug);

  /// Whether any curriculum is stored. What the seeder asks before it writes.
  Future<bool> hasAnyCourse() => _dao.hasAnyCourse();
}
