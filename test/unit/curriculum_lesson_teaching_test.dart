import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/academy/data/curriculum_document.dart';
import 'package:tone_vault/features/academy/data/curriculum_model.dart';
import '../support/curriculum_document_fixture.dart';

/// The parts of a lesson an instructor would have written down: what it is for,
/// what usually goes wrong, what to do about it, and what to learn next.
///
/// They are read here rather than in the main document test because they are the
/// difference between a page of text and a lesson, and a file that quietly loses
/// them would still import as a valid curriculum.
void main() {
  test('what a lesson is for, and what goes wrong in it, are read', () {
    final lesson = _lesson(
      lessonMap(
        objective: 'Play Em and Am with every string sounding.',
        commonMistakes: const [
          'Placing each finger separately.',
          'Strumming six strings on Am.',
        ],
        practiceTips: const [
          'Move the pair as one block.',
          'Change without strumming, twenty times.',
        ],
        nextSkill: 'C and G, and the Long Way Round',
      ),
    );

    expect(lesson.objective, 'Play Em and Am with every string sounding.');
    expect(lesson.commonMistakes, [
      'Placing each finger separately.',
      'Strumming six strings on Am.',
    ]);
    expect(lesson.practiceTips, [
      'Move the pair as one block.',
      'Change without strumming, twenty times.',
    ]);
    expect(lesson.nextSkill, 'C and G, and the Long Way Round');
  });

  test('a lesson that says none of it is still a lesson', () {
    // The four of them are what a good lesson has, not what a valid file has: a
    // course shared from another phone predates them, and refusing it would make
    // the app's own taste a compatibility rule.
    final lesson = _lesson(
      lessonMap(
        objective: null,
        commonMistakes: const [],
        practiceTips: const [],
        nextSkill: null,
      ),
    );

    expect(lesson.objective, isNull);
    expect(lesson.commonMistakes, isEmpty);
    expect(lesson.practiceTips, isEmpty);
    expect(lesson.nextSkill, isNull);
  });

  test('and neither is a field left out altogether', () {
    var map = without(lessonMap(), 'objective');
    map = without(map, 'commonMistakes');
    map = without(map, 'practiceTips');
    final lesson = _lesson(without(map, 'nextSkill'));

    expect(lesson.objective, isNull);
    expect(lesson.commonMistakes, isEmpty);
    expect(lesson.practiceTips, isEmpty);
    expect(lesson.nextSkill, isNull);
  });

  test('a note the column cannot hold is refused, and the lesson named', () {
    expect(
      () => _decode(lessonMap(objective: 'o' * 241)),
      _failsWith('objective'),
    );
    expect(
      () => _decode(lessonMap(objective: 'o' * 241)),
      _failsWith('lesson "em-and-am"'),
    );
    expect(
      () => _decode(lessonMap(commonMistakes: ['m' * 201])),
      _failsWith('commonMistakes'),
    );
    expect(
      () => _decode(lessonMap(practiceTips: ['t' * 201])),
      _failsWith('practiceTips'),
    );
    expect(
      () => _decode(lessonMap(nextSkill: 's' * 161)),
      _failsWith('nextSkill'),
    );
  });

  test('a mistake written as something other than a sentence is refused', () {
    // A number or an object here is an author's mistake, and storing it as its
    // own text would put "42" on the lesson as advice.
    expect(
      () => _decode(replacing(lessonMap(), 'practiceTips', [42])),
      _failsWith('practiceTips'),
    );
    expect(
      () => _decode(replacing(lessonMap(), 'commonMistakes', 'one long line')),
      _failsWith('commonMistakes'),
    );
  });
}

/// The single lesson of a one-course curriculum, read back out of it.
LessonSpec _lesson(Map<String, dynamic> lesson) =>
    _decode(lesson).single.modules.single.lessons.single;

List<CourseSpec> _decode(Map<String, dynamic> lesson) => decodeCurriculum(
  curriculumJson(
    courses: [
      courseMap(
        modules: [
          moduleMap(lessons: [lesson]),
        ],
      ),
    ],
  ),
);

Matcher _failsWith(String fragment) => throwsA(
  isA<AppFailure>().having(
    (failure) => failure.message,
    'message',
    contains(fragment),
  ),
);
