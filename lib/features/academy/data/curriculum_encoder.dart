import 'dart:convert';

import '../../../shared/formatting/app_date_format.dart';
import 'curriculum_document.dart';
import 'curriculum_model.dart';

/// A curriculum written back out as the file the importer reads.
///
/// The inverse of `decodeCurriculum`, and kept that way deliberately: a course
/// exported from one phone has to arrive on another as the same course, so the two
/// halves are tested against each other rather than each against a fixture of its
/// own. A field added to the reader and forgotten here is a field an export loses.
///
/// Anything the curriculum did not say is left out rather than written as null. A
/// lesson with no genre has no genre, and `"genre": null` is the same statement at
/// greater length - the reader treats absent and null alike, so the shorter one wins.
///
/// Indented, like a backup. This is a file the user keeps, and one they can open and
/// read is worth more than one that saves a few bytes.
String encodeCurriculum(List<CourseSpec> courses) {
  return const JsonEncoder.withIndent('  ').convert({
    'formatVersion': curriculumFormatVersion,
    'courses': [for (final course in courses) _course(course)],
  });
}

/// What an exported file is called.
///
/// Dated, because a curriculum is exported again after being changed and two files
/// of the same name in one folder is a tangle the user has to unpick. A single
/// course carries its slug as well, so an export of one course cannot be mistaken
/// for an export of the lot.
String curriculumFileName(DateTime exportedAt, {String? slug}) {
  final at = formatDate(exportedAt.toLocal());
  return slug == null
      ? 'tonevault-curriculum-$at.json'
      : 'tonevault-course-$slug-$at.json';
}

Map<String, dynamic> _course(CourseSpec course) => {
  'slug': course.slug,
  'path': course.path.name,
  'level': course.level.name,
  'title': course.title,
  'summary': course.summary,
  'modules': [for (final module in course.modules) _module(module)],
};

Map<String, dynamic> _module(ModuleSpec module) => {
  'slug': module.slug,
  'title': module.title,
  if (module.summary != null) 'summary': module.summary,
  'lessons': [for (final lesson in module.lessons) _lesson(lesson)],
};

Map<String, dynamic> _lesson(LessonSpec lesson) => {
  'slug': lesson.slug,
  'title': lesson.title,
  'kind': lesson.kind.name,
  'body': lesson.body,
  if (lesson.objective != null) 'objective': lesson.objective,
  if (lesson.commonMistakes.isNotEmpty) 'commonMistakes': lesson.commonMistakes,
  if (lesson.practiceTips.isNotEmpty) 'practiceTips': lesson.practiceTips,
  if (lesson.nextSkill != null) 'nextSkill': lesson.nextSkill,
  if (lesson.genre != null) 'genre': lesson.genre!.name,
  if (lesson.estimatedMinutes != null)
    'estimatedMinutes': lesson.estimatedMinutes,
  if (lesson.suggestedBpm != null) 'suggestedBpm': lesson.suggestedBpm,
  if (lesson.timeSignature != null) 'timeSignature': lesson.timeSignature!.name,
  if (lesson.theoryKeys.isNotEmpty) 'theoryKeys': lesson.theoryKeys,
  if (lesson.exercises.isNotEmpty)
    'exercises': [for (final exercise in lesson.exercises) _exercise(exercise)],
};

Map<String, dynamic> _exercise(ExerciseSpec exercise) => {
  'title': exercise.title,
  'instructions': exercise.instructions,
  'startBpm': exercise.startBpm,
  'targetBpm': exercise.targetBpm,
  'timeSignature': exercise.timeSignature.name,
};
