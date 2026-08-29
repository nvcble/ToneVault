import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/learning_path.dart';
import 'package:tone_vault/core/enums/skill_level.dart';
import 'package:tone_vault/features/academy/data/curriculum_repository.dart';
import 'package:tone_vault/features/academy/data/curriculum_seeder.dart';
import '../support/curriculum_document_fixture.dart';
import '../support/repositories.dart';

/// Seeding: what happens at every launch, and what must not happen at the second
/// one.
void main() {
  late AppDatabase database;
  late CurriculumRepository curriculum;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    curriculum = curriculumRepository(database);
  });

  tearDown(() => database.close());

  CurriculumSeeder seederOf(Map<String, String> files) {
    return CurriculumSeeder(
      curriculumImporter(database),
      bundle: _FixedBundle(files),
      assets: files.keys.toList(),
    );
  }

  test('the first launch fills an empty Academy', () async {
    final added = await seederOf({'rhythm.json': curriculumJson()}).seed();

    expect(added, 1);
    expect(await curriculum.hasAnyCourse(), isTrue);
  });

  test('every launch after that writes nothing', () async {
    final seeder = seederOf({'rhythm.json': curriculumJson()});

    expect(await seeder.seed(), 1);
    expect(await seeder.seed(), 0);
    expect(await seeder.seed(), 0);
    expect(
      await curriculum
          .watchCourses(LearningPath.rhythm, SkillLevel.beginner)
          .first,
      hasLength(1),
    );
  });

  test(
    'a course added by a later version of the app arrives on its own',
    () async {
      // What an app update looks like: the file it ships has a course the installed
      // one never had, and the ones the player is working through are untouched.
      await seederOf({'rhythm.json': curriculumJson()}).seed();

      final added = await seederOf({
        'rhythm.json': curriculumJson(
          courses: [
            courseMap(),
            courseMap(slug: 'the-new-one', title: 'New'),
          ],
        ),
      }).seed();

      expect(added, 1);
      expect(
        (await curriculum
                .watchCourses(LearningPath.rhythm, SkillLevel.beginner)
                .first)
            .map((course) => course.title),
        ['First Chords', 'New'],
      );
    },
  );

  test(
    'a course the player has practised is left alone by the next launch',
    () async {
      // The reason the seeder keeps rather than updates. A phone that has been
      // through fifty launches has been through fifty of these.
      final seeder = seederOf({'rhythm.json': curriculumJson()});
      await seeder.seed();

      final progress = progressRepository(database);
      final course =
          (await curriculum
                  .watchCourses(LearningPath.rhythm, SkillLevel.beginner)
                  .first)
              .single;
      final module = (await curriculum.watchModules(course.id).first).single;
      final lesson = (await curriculum.watchLessons(module.id).first).single;
      await progress.addPracticeSeconds(lesson.id, 600);

      await seeder.seed();

      expect(
        (await curriculum.watchLessons(module.id).first).single.id,
        lesson.id,
      );
      expect(
        (await progress.watchProgress(lesson.id).first)?.practiceSeconds,
        600,
      );
    },
  );

  test('every path in the file is written, not just the first', () async {
    final added = await seederOf({
      'rhythm.json': curriculumJson(),
      'lead.json': curriculumJson(
        courses: [
          courseMap(slug: 'lead-beginner', path: 'lead', title: 'Lead'),
        ],
      ),
    }).seed();

    expect(added, 2);
    expect(
      await curriculum
          .watchCourses(LearningPath.lead, SkillLevel.beginner)
          .first,
      hasLength(1),
    );
  });

  test('the curriculum the app actually ships reads and imports', () async {
    // The one test that would catch a typo in a JSON file nobody compiles. The
    // real bundle is used, so this is the shipped content and not a stand-in,
    // which is what the binding is needed for.
    TestWidgetsFlutterBinding.ensureInitialized();
    final seeder = CurriculumSeeder(curriculumImporter(database));

    expect(await seeder.seed(), greaterThan(0));

    for (final path in LearningPath.values) {
      expect(
        await curriculum.watchPathCourses(path).first,
        isNotEmpty,
        reason: '${path.label} ships with no courses',
      );
    }
  });
}

/// An asset bundle of exactly what a test hands it.
///
/// The seeder takes a bundle so a test can give it a curriculum without that
/// curriculum having to be a declared asset of the app, and so a test about a
/// broken file does not need a broken file shipped in the build.
class _FixedBundle extends CachingAssetBundle {
  _FixedBundle(this._files);

  final Map<String, String> _files;

  @override
  Future<ByteData> load(String key) async {
    final contents = _files[key];
    if (contents == null) {
      throw StateError('No asset called $key');
    }
    return ByteData.sublistView(utf8.encode(contents));
  }
}
