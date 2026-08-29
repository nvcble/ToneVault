import 'curriculum_importer.dart';
import 'curriculum_model.dart';

/// How much a curriculum file holds, in the terms the user thinks in.
typedef CurriculumTally = ({int courses, int modules, int lessons});

CurriculumTally tallyCurriculum(List<CourseSpec> courses) {
  var modules = 0;
  var lessons = 0;

  for (final course in courses) {
    modules += course.modules.length;
    for (final module in course.modules) {
      lessons += module.lessons.length;
    }
  }

  return (courses: courses.length, modules: modules, lessons: lessons);
}

/// What a file holds, for the question asked before any of it is written.
///
/// Read and described first, so the user is agreeing to a particular curriculum -
/// this many courses, these ones already here - rather than to the idea of importing
/// one. Modules are left out of the sentence: nobody counts modules, and courses and
/// lessons are what a person can weigh against what they already have.
String describeCurriculum(List<CourseSpec> courses) {
  final tally = tallyCurriculum(courses);

  return 'That file holds ${_count(tally.courses, 'course')} and '
      '${_count(tally.lessons, 'lesson')}.';
}

/// The courses in the file that this app already has, named as the user knows them.
///
/// The whole reason the import is two steps. Bringing a course up to date keeps the
/// practice recorded against its lessons but replaces what they say, and a lesson
/// rewritten under somebody is worse than an import refused.
String describeOverwrite(List<String> titles) {
  final named = titles.length <= 3
      ? titles.map((title) => '"$title"').join(', ')
      : '${titles.take(3).map((title) => '"$title"').join(', ')} and '
            '${titles.length - 3} more';

  return titles.length == 1
      ? 'This app already has $named. Bringing it up to date replaces what its '
            'lessons say. Your practice against them is kept.'
      : 'This app already has $named. Bringing them up to date replaces what '
            'their lessons say. Your practice against them is kept.';
}

/// What a finished import did, for the report afterwards.
///
/// Every number that is not nought is said, because they answer different questions:
/// added is what is new to practise, updated is what changed under the player, and
/// kept is what the file offered and this app already had a version of.
String describeImported(CurriculumImport result) {
  final parts = [
    if (result.added > 0) '${_count(result.added, 'course')} added',
    if (result.updated > 0)
      '${_count(result.updated, 'course')} brought up to date',
    if (result.kept > 0)
      '${_count(result.kept, 'course')} left '
          '${result.kept == 1 ? 'as it was' : 'as they were'}',
  ];

  return parts.isEmpty ? 'Nothing to import.' : '${parts.join(', ')}.';
}

/// "1 course", "12 courses", "no courses" - a file with nothing in it is a real
/// thing to be told about, and "0 courses" reads like a fault.
String _count(int howMany, String thing) => switch (howMany) {
  0 => 'no ${thing}s',
  1 => '1 $thing',
  _ => '$howMany ${thing}s',
};
