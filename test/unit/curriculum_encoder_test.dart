import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/music_genre.dart';
import 'package:tone_vault/core/enums/time_signature.dart';
import 'package:tone_vault/features/academy/data/curriculum_document.dart';
import 'package:tone_vault/features/academy/data/curriculum_encoder.dart';
import 'package:tone_vault/features/academy/data/curriculum_model.dart';
import '../support/curriculum_document_fixture.dart';

/// A curriculum written back out, and read again as the same curriculum.
///
/// The encoder and the decoder are tested against each other rather than each
/// against a blob of expected JSON: what matters is that a course exported from one
/// phone arrives on another as the course it was, and a field the encoder forgets is
/// a field the export silently loses.
void main() {
  List<CourseSpec> roundTrip(List<CourseSpec> courses) =>
      decodeCurriculum(encodeCurriculum(courses));

  test('a course survives being written and read again', () {
    final before = decodeCurriculum(curriculumJson());
    final after = roundTrip(before);

    final course = after.single;
    expect(course.slug, before.single.slug);
    expect(course.path, before.single.path);
    expect(course.level, before.single.level);
    expect(course.title, 'First Chords');
    expect(course.summary, before.single.summary);
    expect(course.modules.single.slug, 'open-chords');
    expect(course.modules.single.summary, 'The first six.');
  });

  test('and so does everything a lesson says', () {
    final before = decodeCurriculum(
      curriculumJson(
        courses: [
          courseMap(
            modules: [
              moduleMap(lessons: [lessonMap(genre: 'blues')]),
            ],
          ),
        ],
      ),
    );

    final lesson = roundTrip(before).single.modules.single.lessons.single;

    expect(lesson.slug, 'em-and-am');
    expect(lesson.title, 'Em and Am');
    expect(lesson.kind, before.single.modules.single.lessons.single.kind);
    expect(lesson.body, 'Two fingers, moved across one string.');
    expect(lesson.genre, MusicGenre.blues);
    expect(lesson.estimatedMinutes, 15);
    expect(lesson.suggestedBpm, 60);
    expect(lesson.timeSignature, TimeSignature.fourFour);
    // The theory a lesson points at is the diagram it shows, so losing these would
    // be losing the fretboards out of the lesson.
    expect(lesson.theoryKeys, ['Em', 'Am']);
    // And the teaching around the text: an exported course that arrived without
    // its objective, its warnings and its tips would arrive as notes on a page.
    expect(lesson.objective, 'Change between Em and Am without stopping.');
    expect(lesson.commonMistakes, ['Placing each finger separately.']);
    expect(lesson.practiceTips, ['Move the pair as one block.']);
    expect(lesson.nextSkill, 'C and G');
  });

  test('an exercise keeps both of its tempos and its meter', () {
    final before = decodeCurriculum(curriculumJson());

    final exercise = roundTrip(
      before,
    ).single.modules.single.lessons.single.exercises.single;

    expect(exercise.title, 'One chord a bar');
    expect(exercise.instructions, isNotEmpty);
    expect(exercise.startBpm, 60);
    expect(exercise.targetBpm, 100);
    expect(exercise.timeSignature, TimeSignature.fourFour);
  });

  test('order is kept, because order is what teaches', () {
    final before = decodeCurriculum(
      curriculumJson(
        courses: [
          courseMap(
            modules: [
              moduleMap(
                lessons: [
                  lessonMap(slug: 'first', title: 'First'),
                  lessonMap(slug: 'second', title: 'Second'),
                  lessonMap(slug: 'third', title: 'Third'),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    final lessons = roundTrip(before).single.modules.single.lessons;

    // Nothing in the file carries a position: the order they are written in is the
    // order they are taught in, so a writer that sorted them would re-teach the
    // course backwards.
    expect(lessons.map((lesson) => lesson.title), ['First', 'Second', 'Third']);
  });

  test('what the curriculum did not say is not written down', () {
    final courses = decodeCurriculum(
      curriculumJson(
        courses: [
          courseMap(
            modules: [
              moduleMap(
                lessons: [
                  // A lesson that names no genre, no tempo, no meter, no theory and
                  // sets no exercises: everything optional, left unsaid.
                  lessonMap(
                    objective: null,
                    commonMistakes: const [],
                    practiceTips: const [],
                    nextSkill: null,
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

    final written = encodeCurriculum(courses);

    // Absent rather than null. The reader treats them alike, so the shorter of the
    // two spellings is the one to write.
    expect(written, isNot(contains('genre')));
    expect(written, isNot(contains('suggestedBpm')));
    expect(written, isNot(contains('timeSignature')));
    expect(written, isNot(contains('theoryKeys')));
    expect(written, isNot(contains('exercises')));
    expect(written, isNot(contains('objective')));
    expect(written, isNot(contains('commonMistakes')));
    expect(written, isNot(contains('practiceTips')));
    expect(written, isNot(contains('nextSkill')));
  });

  test('and what it did say is written by name rather than by number', () {
    final courses = decodeCurriculum(
      curriculumJson(
        courses: [
          courseMap(
            modules: [
              moduleMap(lessons: [lessonMap(genre: 'reggae')]),
            ],
          ),
        ],
      ),
    );

    // Enum names, not indexes: a file with `"genre": 3` in it is a file nobody can
    // check by eye, and one that breaks the day an enum gains a member.
    expect(encodeCurriculum(courses), contains('"genre": "reggae"'));
    expect(encodeCurriculum(courses), contains('"path": "rhythm"'));
  });

  test('the file says which format it is in', () {
    final written = json.decode(
      encodeCurriculum(decodeCurriculum(curriculumJson())),
    );

    expect(
      (written as Map<String, dynamic>)['formatVersion'],
      curriculumFormatVersion,
    );
  });

  test('and is laid out to be read, not just parsed', () {
    final written = encodeCurriculum(decodeCurriculum(curriculumJson()));

    // Indented, like a backup. It is the user's own copy of a course and they may
    // well open it.
    expect(written, contains('\n  "courses"'));
  });

  group('the name of an exported file', () {
    final exportedAt = DateTime(2026, 8, 28, 14, 30);

    test('says when it was taken', () {
      expect(curriculumFileName(exportedAt), contains('2026'));
      expect(curriculumFileName(exportedAt), endsWith('.json'));
      expect(
        curriculumFileName(exportedAt),
        startsWith('tonevault-curriculum-'),
      );
    });

    test('and names the course where it is only one', () {
      final name = curriculumFileName(
        exportedAt,
        slug: 'rhythm-beginner-first-chords',
      );

      // So a course sent to a student is not filed beside an export of the whole
      // Academy under a name that cannot tell them apart.
      expect(
        name,
        startsWith('tonevault-course-rhythm-beginner-first-chords-'),
      );
    });
  });
}
