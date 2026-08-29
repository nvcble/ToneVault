import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/learning_path.dart';
import 'package:tone_vault/core/enums/music_genre.dart';
import 'package:tone_vault/core/music/theory_query.dart';
import 'package:tone_vault/features/academy/data/curriculum_assets.dart';
import 'package:tone_vault/features/academy/data/curriculum_document.dart';
import 'package:tone_vault/features/academy/data/curriculum_model.dart';

/// The curriculum the app ships, checked as content rather than as code.
///
/// Nothing compiles these files, so a mistake in one of them - a level that does not
/// match the file it is in, a slug reused across two files, a genre nobody ever got
/// round to writing a lesson for - would otherwise only be found by a person opening
/// the Academy and noticing something absent.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<CourseSpec> shipped;
  late Map<String, List<CourseSpec>> byAsset;

  setUpAll(() async {
    byAsset = {
      for (final asset in curriculumAssets)
        asset: decodeCurriculum(await rootBundle.loadString(asset)),
    };
    shipped = byAsset.values.expand((courses) => courses).toList();
  });

  test('every file named in the app is there and can be read', () {
    expect(byAsset, hasLength(curriculumAssets.length));
    for (final entry in byAsset.entries) {
      expect(entry.value, isNotEmpty, reason: '${entry.key} has no courses');
    }
  });

  test('a file only holds the path and level its name claims', () {
    // The file name is what decides which courses are numbered against each other,
    // so a course in the wrong file is a course in an arbitrary place in its level.
    for (final entry in byAsset.entries) {
      final name = entry.key.split('/').last.replaceAll('.json', '');
      for (final course in entry.value) {
        expect(
          '${course.path.name}_${course.level.name}',
          name,
          reason: '${course.slug} is in $name',
        );
      }
    }
  });

  test('every path has all four levels taught', () {
    final taught = {for (final course in shipped) (course.path, course.level)};

    expect(taught, hasLength(curriculumAssets.length));
  });

  test('no two files use the same slug for anything', () {
    // A file is validated on its own, so a slug reused across two of them is only
    // caught here. The second one would be kept out by the seeder and never seen.
    final courses = shipped.map((course) => course.slug);
    final modules = shipped
        .expand((course) => course.modules)
        .map((module) => module.slug);
    final lessons = shipped
        .expand((course) => course.modules)
        .expand((module) => module.lessons)
        .map((lesson) => lesson.slug);

    expect(courses.toSet(), hasLength(courses.length));
    expect(modules.toSet(), hasLength(modules.length));
    expect(lessons.toSet(), hasLength(lessons.length));
  });

  test('every genre the app knows is taught somewhere', () {
    final taught = shipped
        .expand((course) => course.modules)
        .expand((module) => module.lessons)
        .map((lesson) => lesson.genre)
        .nonNulls
        .toSet();

    expect(
      MusicGenre.values.where((genre) => !taught.contains(genre)),
      isEmpty,
      reason: 'these genres have no lesson anywhere in the curriculum',
    );
  });

  test('every piece of theory a lesson points at can be worked out', () {
    // A theory key is a string in a JSON file, and the fretboard is drawn from what
    // the engine makes of it. One that resolves to nothing is a lesson with a blank
    // space where its diagram should be, which is worth knowing here.
    final unreadable = <String>[];
    for (final lesson
        in shipped
            .expand((course) => course.modules)
            .expand((module) => module.lessons)) {
      for (final key in lesson.theoryKeys) {
        if (resolveTheoryKey(key) == null) {
          unreadable.add('${lesson.slug}: $key');
        }
      }
    }

    expect(unreadable, isEmpty);
  });

  test('and on both paths, because a style is two jobs', () {
    // What makes a reggae rhythm player is not what makes a reggae lead player, and a
    // genre taught on one path only is half a style.
    final paths = <MusicGenre, Set<LearningPath>>{};
    for (final course in shipped) {
      for (final lesson in course.modules.expand((module) => module.lessons)) {
        final genre = lesson.genre;
        if (genre != null) {
          (paths[genre] ??= {}).add(course.path);
        }
      }
    }

    expect(
      MusicGenre.values.where(
        (genre) =>
            (paths[genre] ?? const {}).length < LearningPath.values.length,
      ),
      isEmpty,
      reason: 'these genres are taught on one path only',
    );
  });

  test('every lesson is written the way an instructor would write one', () {
    // The teaching around the body: what the lesson is for, what usually goes
    // wrong, what to do about it, and where to go next. The file format allows a
    // lesson without them, because an imported course may predate them - the
    // curriculum this app ships does not get to.
    final thin = <String>[];
    for (final lesson in _lessonsOf(shipped)) {
      if ((lesson.objective ?? '').isEmpty) {
        thin.add('${lesson.slug}: no objective');
      }
      if (lesson.commonMistakes.length < 2) {
        thin.add('${lesson.slug}: ${lesson.commonMistakes.length} mistakes');
      }
      if (lesson.practiceTips.length < 2) {
        thin.add('${lesson.slug}: ${lesson.practiceTips.length} tips');
      }
      if ((lesson.nextSkill ?? '').isEmpty) {
        thin.add('${lesson.slug}: no next skill');
      }
    }

    expect(thin, isEmpty);
  });

  test('and hands the player on to the lesson that follows it', () {
    // The next skill is searched for rather than linked by slug, so a title it
    // does not match exactly would send someone to a page of near misses. Only
    // the last lesson of a course points somewhere else: at the idea the level
    // above picks up.
    final adrift = <String>[];
    for (final course in shipped) {
      final lessons = _lessonsOf([course]).toList();
      for (var index = 0; index < lessons.length - 1; index++) {
        final next = lessons[index].nextSkill;
        if (next != lessons[index + 1].title) {
          adrift.add('${lessons[index].slug} -> "$next"');
        }
      }
    }

    expect(adrift, isEmpty);
  });

  test('a genre is taught in more than one place', () {
    // The point of hanging style on a lesson rather than on a path: a style comes
    // back at each level saying more, so one lesson in the whole curriculum called
    // "Funk" would be the thing this design exists to avoid.
    final levels = <MusicGenre, Set<String>>{};
    for (final course in shipped) {
      for (final lesson in course.modules.expand((module) => module.lessons)) {
        final genre = lesson.genre;
        if (genre != null) {
          (levels[genre] ??= {}).add(
            '${course.path.name} ${course.level.name}',
          );
        }
      }
    }

    expect(
      levels.entries
          .where((entry) => entry.value.length < 2)
          .map((entry) => entry.key.label),
      isEmpty,
      reason: 'these genres are taught in only one place',
    );
  });
}

/// Every lesson of the given courses, in the order they are taught in.
Iterable<LessonSpec> _lessonsOf(List<CourseSpec> courses) => courses
    .expand((course) => course.modules)
    .expand((module) => module.lessons);
