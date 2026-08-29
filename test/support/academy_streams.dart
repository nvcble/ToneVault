import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/academy_course_dao.dart'
    show LessonPlace;
import 'package:tone_vault/features/academy/data/lesson_tally.dart';
import 'package:tone_vault/features/academy/providers/academy_providers.dart';
import 'package:tone_vault/features/academy/providers/progress_providers.dart';

/// What the Academy reads, as plain values.
///
/// Opening a level seeds the curriculum and lists the courses in it, and both of
/// those reach for the database file on disk, which never resolves under the test
/// binding. A test about the way around the Academy stands them in and gets the
/// screens a fresh install shows before anything is loaded.
///
/// The progress streams are stood in too, and for the same reason: every path card
/// and every level row now says how far through it the player is, so a screen that
/// used to read one table reads two.
List<Override> academyStreamOverrides({
  List<AcademyCourse> courses = const [],
  LessonPlace? unfinished,
}) => [
  curriculumSeedProvider.overrideWith((ref) async => 0),
  courseListProvider.overrideWith((ref, at) => Stream.value(courses)),
  pathCourseListProvider.overrideWith((ref, path) => Stream.value(courses)),
  pathTallyProvider.overrideWith(
    (ref, path) => Stream.value(const <int, LessonTally>{}),
  ),
  courseTallyProvider.overrideWith((ref, courseId) => Stream.value(emptyTally)),
  unfinishedLessonProvider.overrideWith((ref) => Stream.value(unfinished)),
];
