import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/learning_path.dart';
import 'package:tone_vault/core/enums/lesson_kind.dart';
import 'package:tone_vault/core/enums/music_genre.dart';
import 'package:tone_vault/core/enums/skill_level.dart';
import 'package:tone_vault/core/enums/time_signature.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/academy/data/curriculum_document.dart';
import '../support/curriculum_document_fixture.dart';

/// Reading a curriculum file, and refusing one in words its author can act on.
void main() {
  test('a whole course is read as it was written', () {
    final courses = decodeCurriculum(curriculumJson());

    final course = courses.single;
    expect(course.slug, 'rhythm-beginner-first-chords');
    expect(course.path, LearningPath.rhythm);
    expect(course.level, SkillLevel.beginner);
    expect(course.title, 'First Chords');

    final lesson = course.modules.single.lessons.single;
    expect(lesson.kind, LessonKind.technique);
    expect(lesson.timeSignature, TimeSignature.fourFour);
    expect(lesson.suggestedBpm, 60);
    expect(lesson.theoryKeys, ['Em', 'Am']);
    expect(lesson.genre, isNull);

    final exercise = lesson.exercises.single;
    expect(exercise.startBpm, 60);
    expect(exercise.targetBpm, 100);
  });

  test('a genre is read where a lesson names one', () {
    final courses = decodeCurriculum(
      curriculumJson(
        courses: [
          courseMap(
            modules: [
              moduleMap(lessons: [lessonMap(genre: 'worship')]),
            ],
          ),
        ],
      ),
    );

    expect(
      courses.single.modules.single.lessons.single.genre,
      MusicGenre.worship,
    );
  });

  test('what is not there is left null rather than guessed at', () {
    final courses = decodeCurriculum(
      curriculumJson(
        courses: [
          courseMap(
            modules: [
              moduleMap(
                lessons: [
                  lessonMap(
                    suggestedBpm: null,
                    timeSignature: null,
                    theoryKeys: const [],
                    exercises: const [],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    final lesson = courses.single.modules.single.lessons.single;
    expect(lesson.suggestedBpm, isNull);
    expect(lesson.timeSignature, isNull);
    expect(lesson.theoryKeys, isEmpty);
    expect(lesson.exercises, isEmpty);
  });

  test('something that is not a curriculum at all is refused', () {
    expect(
      () => decodeCurriculum('this is a photo, not a course'),
      _failsWith('not a ToneVault curriculum'),
    );
    expect(() => decodeCurriculum('[]'), _failsWith('not a ToneVault'));
    expect(() => decodeCurriculum('{}'), _failsWith('not a ToneVault'));
  });

  test('a file from a newer version says so instead of being half read', () {
    // The point of the version: a file written by an app that knows more keys
    // than this one has to be turned away whole, because reading the keys it does
    // recognise would store a course missing whatever the new ones said.
    expect(
      () => decodeCurriculum(curriculumJson(formatVersion: 2)),
      _failsWith('newer version'),
    );
  });

  test('a curriculum with no courses in it is refused', () {
    expect(
      () => decodeCurriculum(curriculumJson(courses: const [])),
      _failsWith('no courses'),
    );
  });

  test('a course with nothing to teach is refused', () {
    expect(
      () => decodeCurriculum(
        curriculumJson(courses: [courseMap(modules: const [])]),
      ),
      _failsWith('no modules'),
    );
    expect(
      () => decodeCurriculum(
        curriculumJson(
          courses: [
            courseMap(modules: [moduleMap(lessons: const [])]),
          ],
        ),
      ),
      _failsWith('no lessons'),
    );
  });

  test('a missing field is named, and so is where it is missing from', () {
    expect(
      () => decodeCurriculum(
        curriculumJson(courses: [without(courseMap(), 'title')]),
      ),
      _failsWith('has no title'),
    );
    expect(
      () => decodeCurriculum(
        curriculumJson(
          courses: [
            courseMap(
              modules: [
                moduleMap(lessons: [without(lessonMap(), 'body')]),
              ],
            ),
          ],
        ),
      ),
      _failsWith('lesson "em-and-am"'),
    );
  });

  test('a word this app does not know is refused by name', () {
    expect(
      () => decodeCurriculum(
        curriculumJson(courses: [courseMap(level: 'expert')]),
      ),
      _failsWith('"expert"'),
    );
    expect(
      () => decodeCurriculum(
        curriculumJson(
          courses: [
            courseMap(
              modules: [
                moduleMap(lessons: [lessonMap(kind: 'lecture')]),
              ],
            ),
          ],
        ),
      ),
      _failsWith('"lecture"'),
    );
  });

  test('a slug with a capital or a space in it is refused', () {
    expect(
      () => decodeCurriculum(
        curriculumJson(courses: [courseMap(slug: 'Rhythm-Beginner')]),
      ),
      _failsWith('lower case'),
    );
    expect(
      () => decodeCurriculum(
        curriculumJson(courses: [courseMap(slug: 'first chords')]),
      ),
      _failsWith('lower case'),
    );
  });

  test('the same slug twice is refused, at every level', () {
    expect(
      () => decodeCurriculum(
        curriculumJson(
          courses: [
            courseMap(),
            courseMap(title: 'Again'),
          ],
        ),
      ),
      _failsWith('two courses'),
    );
    expect(
      () => decodeCurriculum(
        curriculumJson(
          courses: [
            courseMap(
              modules: [
                moduleMap(),
                moduleMap(title: 'Again'),
              ],
            ),
          ],
        ),
      ),
      _failsWith('two modules'),
    );
    expect(
      () => decodeCurriculum(
        curriculumJson(
          courses: [
            courseMap(
              modules: [
                moduleMap(
                  lessons: [
                    lessonMap(),
                    lessonMap(title: 'Again'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      _failsWith('two lessons'),
    );
  });

  test('two exercises of one lesson cannot share a title', () {
    // They are matched by title on the way in, so two of them under one name is
    // a file whose author meant two different things and wrote one.
    expect(
      () => decodeCurriculum(
        curriculumJson(
          courses: [
            courseMap(
              modules: [
                moduleMap(
                  lessons: [
                    lessonMap(exercises: [exerciseMap(), exerciseMap()]),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      _failsWith('two exercises'),
    );
  });

  test('a tempo the metronome cannot play is refused', () {
    expect(
      () => decodeCurriculum(
        curriculumJson(
          courses: [
            courseMap(
              modules: [
                moduleMap(
                  lessons: [
                    lessonMap(exercises: [exerciseMap(targetBpm: 400)]),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      _failsWith('30 to 300'),
    );
  });

  test('an exercise that works down to a slower tempo is refused', () {
    expect(
      () => decodeCurriculum(
        curriculumJson(
          courses: [
            courseMap(
              modules: [
                moduleMap(
                  lessons: [
                    lessonMap(
                      exercises: [exerciseMap(startBpm: 120, targetBpm: 80)],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      _failsWith('slower tempo'),
    );
  });

  test('a number written as text is refused rather than parsed', () {
    // A file that says "sixty" means it, and guessing at it would store a tempo
    // nobody chose.
    expect(
      () => decodeCurriculum(
        curriculumJson(
          courses: [
            courseMap(
              modules: [
                moduleMap(
                  lessons: [
                    lessonMap(exercises: [exerciseMap(startBpm: '60')]),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      _failsWith('whole number'),
    );
  });
}

/// Every refusal is an [AppFailure], because every one of them is something the
/// person holding the file can fix.
Matcher _failsWith(String fragment) => throwsA(
  isA<AppFailure>().having(
    (failure) => failure.message,
    'message',
    contains(fragment),
  ),
);
