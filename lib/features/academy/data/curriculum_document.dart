import 'dart:convert';

import '../../../core/enums/learning_path.dart';
import '../../../core/enums/lesson_kind.dart';
import '../../../core/enums/music_genre.dart';
import '../../../core/enums/skill_level.dart';
import '../../../core/enums/time_signature.dart';
import '../../../core/errors/app_failure.dart';
import 'curriculum_model.dart';
import 'curriculum_reader.dart';

/// The version of a curriculum file's own layout: the keys and the nesting, not
/// the schema of the tables the courses end up in.
///
/// It moves only if that layout changes, so a file always says plainly whether this
/// app knows how to read it. Separate from the database's schema version on
/// purpose - a course written today has to keep importing after the tables under it
/// have moved on.
const int curriculumFormatVersion = 1;

/// The longest a slug, a title and a summary may be, matching the columns they are
/// written into. Checked here rather than left to the driver, because "value too
/// long for column" is not something a user can act on.
const int _maxSlug = 80;
const int _maxTitle = 120;
const int _maxSummary = 400;

/// The same, for what a lesson says around its text. A mistake and a tip are each
/// one sentence by design - a paragraph belongs in the body, where it can be read
/// in order.
const int _maxObjective = 240;
const int _maxNote = 200;
const int _maxNextSkill = 160;

/// Reads a curriculum file, or refuses it in words the user can act on.
///
/// Nothing is written anywhere: this turns text into [CourseSpec]s, so a file that
/// turns out to be a photo, a half-downloaded document or a curriculum with two
/// courses under one slug is found out before the Academy is touched.
///
/// Every refusal names where the problem is. A curriculum is a long file, and
/// "that file is not valid" would leave whoever wrote it nowhere to start.
List<CourseSpec> decodeCurriculum(String source) {
  final document = _document(source);
  final version = document['formatVersion'];

  if (version is! int) {
    throw const AppFailure('That file is not a ToneVault curriculum.');
  }
  if (version > curriculumFormatVersion) {
    throw const AppFailure(
      'That curriculum was made for a newer version of ToneVault. Update the '
      'app, then try again.',
    );
  }

  final courses = document['courses'];
  if (courses is! List || courses.isEmpty) {
    throw const AppFailure('That curriculum has no courses in it.');
  }

  final specs = [
    for (final course in courses)
      _course(CurriculumReader.of(course, 'course')),
  ];
  _refuseRepeats(specs.map((course) => course.slug), 'course');
  return specs;
}

CourseSpec _course(CurriculumReader reader) {
  final slug = reader.slug('slug', max: _maxSlug);
  final at = 'course "$slug"';
  final modules = reader.list('modules', at: at, minimum: 1);

  final specs = [
    for (final module in modules)
      _module(CurriculumReader.of(module, 'module of $at'), at),
  ];
  _refuseRepeats(specs.map((module) => module.slug), 'module', within: at);

  return CourseSpec(
    slug: slug,
    path: reader.oneOf('path', LearningPath.values, at: at),
    level: reader.oneOf('level', SkillLevel.values, at: at),
    title: reader.text('title', at: at, max: _maxTitle),
    summary: reader.text('summary', at: at, max: _maxSummary),
    modules: specs,
  );
}

ModuleSpec _module(CurriculumReader reader, String courseAt) {
  final slug = reader.slug('slug', max: _maxSlug);
  final at = 'module "$slug" of $courseAt';
  final lessons = reader.list('lessons', at: at, minimum: 1);

  final specs = [
    for (final lesson in lessons)
      _lesson(CurriculumReader.of(lesson, 'lesson of $at'), at),
  ];
  _refuseRepeats(specs.map((lesson) => lesson.slug), 'lesson', within: at);

  return ModuleSpec(
    slug: slug,
    title: reader.text('title', at: at, max: _maxTitle),
    summary: reader.optionalText('summary', at: at, max: _maxSummary),
    lessons: specs,
  );
}

LessonSpec _lesson(CurriculumReader reader, String moduleAt) {
  final slug = reader.slug('slug', max: _maxSlug);
  final at = 'lesson "$slug" of $moduleAt';

  final exercises = [
    for (final exercise in reader.list('exercises', at: at))
      _exercise(CurriculumReader.of(exercise, 'exercise of $at'), at),
  ];
  _refuseRepeats(
    exercises.map((exercise) => exercise.title),
    'exercise',
    within: at,
  );

  return LessonSpec(
    slug: slug,
    title: reader.text('title', at: at, max: _maxTitle),
    kind: reader.oneOf('kind', LessonKind.values, at: at),
    // Unbounded, because a lesson is prose and a limit here would be a limit on
    // how well something can be explained.
    body: reader.text('body', at: at),
    objective: reader.optionalText('objective', at: at, max: _maxObjective),
    commonMistakes: reader.textList('commonMistakes', at: at, max: _maxNote),
    practiceTips: reader.textList('practiceTips', at: at, max: _maxNote),
    nextSkill: reader.optionalText('nextSkill', at: at, max: _maxNextSkill),
    genre: reader.optionalOneOf('genre', MusicGenre.values, at: at),
    estimatedMinutes: reader.optionalCount(
      'estimatedMinutes',
      at: at,
      max: 240,
    ),
    suggestedBpm: reader.optionalBpm('suggestedBpm', at: at),
    timeSignature: reader.optionalOneOf(
      'timeSignature',
      TimeSignature.values,
      at: at,
    ),
    theoryKeys: reader.textList('theoryKeys', at: at, max: _maxTitle),
    exercises: exercises,
  );
}

ExerciseSpec _exercise(CurriculumReader reader, String lessonAt) {
  final title = reader.text('title', at: lessonAt, max: _maxTitle);
  final at = 'exercise "$title" of $lessonAt';
  final startBpm = reader.bpm('startBpm', at: at);
  final targetBpm = reader.bpm('targetBpm', at: at);

  // Working up to a tempo slower than the one it starts at is not an exercise
  // anybody wrote on purpose, so it is a mistake in the file rather than a
  // curiosity to store.
  if (targetBpm < startBpm) {
    throw AppFailure(
      'The $at works up to a slower tempo than it starts at.',
      cause: 'startBpm $startBpm, targetBpm $targetBpm',
    );
  }

  return ExerciseSpec(
    title: title,
    instructions: reader.text('instructions', at: at),
    startBpm: startBpm,
    targetBpm: targetBpm,
    timeSignature: reader.oneOf('timeSignature', TimeSignature.values, at: at),
  );
}

/// Refuses a file that names the same thing twice.
///
/// The unique keys on the tables would catch it, but only as a failed write
/// half-way through an import. A file that says the same slug twice has one of them
/// wrong, and which one it is cannot be guessed at here.
void _refuseRepeats(Iterable<String> keys, String what, {String? within}) {
  final seen = <String>{};
  for (final key in keys) {
    if (!seen.add(key)) {
      throw AppFailure(
        within == null
            ? 'That curriculum has two ${what}s called "$key".'
            : 'The $within has two ${what}s called "$key".',
      );
    }
  }
}

Map<String, dynamic> _document(String source) {
  try {
    final decoded = json.decode(source);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
  } on FormatException {
    throw const AppFailure('That file is not a ToneVault curriculum.');
  }
  throw const AppFailure('That file is not a ToneVault curriculum.');
}
