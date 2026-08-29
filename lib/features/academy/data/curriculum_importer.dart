import '../../../core/database/daos/academy_course_dao.dart';
import '../../../core/errors/app_failure.dart';
import 'curriculum_document.dart';
import 'curriculum_model.dart';
import 'curriculum_writer.dart';

/// What to do about a course that is already stored under the same slug.
enum CurriculumConflict {
  /// Refuse the whole file and change nothing. The default, because an import is
  /// usually meant to add something and a course quietly rewritten is a course the
  /// user did not know they had lost.
  refuse,

  /// Leave the stored course exactly as it is and go on to the next one. What the
  /// seeder uses: it runs at every launch, and the course a player is half-way
  /// through is not to be touched just because the app started again.
  keep,

  /// Bring the stored course up to what the file says, keeping the lessons the
  /// player has practised against. What a user gets after being told plainly what
  /// will be replaced.
  update,
}

/// What an import did, for the message the user reads afterwards.
typedef CurriculumImport = ({int added, int updated, int kept});

/// Puts a curriculum into the Academy: the one the app ships, and any the user
/// imports.
///
/// One path in, on purpose. The curriculum the app ships is not privileged - it goes
/// through the same decoding, the same validation and the same writing as a file off
/// the user's phone, so the format cannot rot in the one place it is never tested.
///
/// The whole file is one transaction. A curriculum half written is worse than one not
/// written at all: the modules of a course would be there and its lessons would not,
/// and nothing in the app could tell that from a course that is simply short.
class CurriculumImporter {
  CurriculumImporter(this._dao, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AcademyCourseDao _dao;

  /// Injectable so tests can assert on exact timestamps.
  final DateTime Function() _clock;

  /// Reads [source] and writes what it says.
  ///
  /// Decoded before the transaction is opened, so a file that is not a curriculum at
  /// all is refused without the database being touched.
  Future<CurriculumImport> importFile(
    String source, {
    CurriculumConflict onConflict = CurriculumConflict.refuse,
  }) => importCourses(decodeCurriculum(source), onConflict: onConflict);

  Future<CurriculumImport> importCourses(
    List<CourseSpec> courses, {
    CurriculumConflict onConflict = CurriculumConflict.refuse,
  }) async {
    final writer = CurriculumWriter(_dao, _clock());

    return guardFailure(
      () => _dao.transaction(() async {
        var added = 0;
        var updated = 0;
        var kept = 0;

        // The position is the course's index in the file it was written in, not its
        // index among the ones being written. A course skipped or added later keeps
        // the place the curriculum gave it.
        for (final (position, course) in courses.indexed) {
          final existing = await _dao.findCourseBySlug(course.slug);
          if (existing != null) {
            switch (onConflict) {
              case CurriculumConflict.refuse:
                throw AppFailure(
                  'This app already has a course called "${existing.title}". '
                  'Nothing was imported.',
                );
              case CurriculumConflict.keep:
                kept++;
                continue;
              case CurriculumConflict.update:
                updated++;
            }
          } else {
            added++;
          }

          await writer.writeCourse(course, position: position);
        }

        return (added: added, updated: updated, kept: kept);
      }),
      'Could not import that curriculum.',
    );
  }

  /// The courses a file would replace, so the user can be asked before anything is
  /// written rather than told afterwards.
  ///
  /// Titles rather than slugs: the user knows this course as "First Chords", not as
  /// `rhythm-beginner-first-chords`.
  Future<List<String>> coursesAlreadyStored(List<CourseSpec> courses) async {
    final titles = <String>[];
    for (final course in courses) {
      final existing = await _dao.findCourseBySlug(course.slug);
      if (existing != null) {
        titles.add(existing.title);
      }
    }
    return titles;
  }
}
