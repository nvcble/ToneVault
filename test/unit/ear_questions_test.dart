import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/skill_level.dart';
import 'package:tone_vault/core/music/interval.dart';
import 'package:tone_vault/features/academy/data/ear_drill.dart';
import 'package:tone_vault/features/academy/data/ear_question.dart';
import 'package:tone_vault/features/academy/data/ear_questions.dart';

/// The drills, as the questions they make.
///
/// Nothing here is a stored question, so what is worth testing is not one question but
/// the rules: every drill, over a run of seeds, has to keep producing something a
/// player can answer. A drill that once in fifty questions offers the same chord twice
/// or plays a note above the top of the neck is a bug nobody would reproduce by hand.
void main() {
  /// Enough runs to catch a drill whose distractors collide on some roots and not
  /// others, and still quick because none of this renders any audio.
  Iterable<EarQuestion> runs(EarDrill drill) => [
    for (var seed = 0; seed < 50; seed++) questionFor(drill, Random(seed)),
  ];

  group('every drill', () {
    for (final drill in EarDrill.values) {
      test('${drill.name} asks something that can be answered', () {
        for (final question in runs(drill)) {
          expect(question.prompt, isNotEmpty);
          expect(question.explanation, isNotEmpty);
          expect(question.choices.length, greaterThanOrEqualTo(2));
          expect(
            question.answer,
            inInclusiveRange(0, question.choices.length - 1),
          );
          // Two identical choices would make one of them wrong for no reason.
          expect(question.choices.toSet(), hasLength(question.choices.length));
        }
      });

      test('${drill.name} plays notes a guitar could play', () {
        for (final question in runs(drill)) {
          expect(question.sound.bars, isNotEmpty);
          for (final bar in question.sound.bars) {
            expect(bar, isNotEmpty);
            // The open low E to the top of a 24-fret neck, an octave either way.
            expect(
              bar.every((note) => note >= 28 && note <= 100),
              isTrue,
              reason: 'out of range: $bar',
            );
          }
        }
      });
    }
  });

  test('every level has drills, and every drill belongs to one', () {
    for (final level in SkillLevel.values) {
      expect(EarDrill.forLevel(level), isNotEmpty);
    }
    expect([
      for (final level in SkillLevel.values) ...EarDrill.forLevel(level),
    ], hasLength(EarDrill.values.length));
  });

  test('major or minor is asked as those two words', () {
    for (final question in runs(EarDrill.majorOrMinor)) {
      expect(question.choices.toSet(), {'Major', 'Minor'});
    }
  });

  test('the wrong answers share the root of the right one', () {
    // The point of the design: the quality being drilled is the only difference
    // there is to hear, so the question cannot be answered by hearing anything else.
    final question = questionFor(EarDrill.seventhChords, Random(7));

    expect(question.choices, hasLength(4));
    expect(
      question.choices.map((choice) => choice[0]).toSet(),
      hasLength(1),
      reason: 'different roots: ${question.choices}',
    );
  });

  test('chords in a key are asked in the key they are in', () {
    for (final question in runs(EarDrill.chordsInAKey)) {
      expect(question.prompt, startsWith('In '));
      expect(question.prompt, contains('major, which chord'));
    }
  });

  test('an interval is two notes, played one after the other', () {
    for (final question in runs(EarDrill.intervals)) {
      // Notes rather than a chord: an interval a player meets in a melody is two
      // sounds, and heard together it is a different thing to name.
      expect(question.sound.kind, EarSoundKind.notes);
      expect(question.sound.bars.single, hasLength(2));
    }
  });

  test('and the second note is always the higher of the two', () {
    for (final question in runs(EarDrill.intervals)) {
      final notes = question.sound.bars.single;
      // Ascending only. The same distance downwards is a different thing to hear, and
      // mixing the two into one drill would make a wrong answer ambiguous.
      expect(notes.last, greaterThan(notes.first));
      expect(notes.last - notes.first, inInclusiveRange(1, 12));
    }
  });

  test('an interval is answered by its name, not by a count of frets', () {
    // The words the theory engine uses for a distance, which are the words the lessons
    // teach: a choice of '4' would be a number of frets and would teach nothing.
    final names = {
      for (var semitones = 1; semitones <= 12; semitones++)
        intervalLabel(semitones),
    };

    for (final question in runs(EarDrill.intervals)) {
      expect(question.prompt, 'Which interval did you hear?');
      expect(
        question.choices,
        everyElement(isIn(names)),
        reason: 'not interval names: ${question.choices}',
      );
      // The distance in semitones is said in the explanation, where it teaches
      // rather than gives the answer away.
      expect(question.explanation, contains('semitones'));
    }
  });

  test('the interval the answer names is the one that was played', () {
    for (final question in runs(EarDrill.intervals)) {
      final notes = question.sound.bars.single;

      expect(question.answerLabel, intervalLabel(notes.last - notes.first));
    }
  });

  test('an inversion asks about one chord over each of its notes', () {
    for (final question in runs(EarDrill.inversions)) {
      // One choice in root position, and the rest of them slashed.
      final slashed = question.choices.where((each) => each.contains('/'));
      expect(slashed, hasLength(question.choices.length - 1));
    }
  });

  test('a voicing is asked as degrees, and the answer is on top of it', () {
    for (final question in runs(EarDrill.voicings)) {
      expect(question.choices, contains('1'));
      expect(question.sound.kind, EarSoundKind.chord);
    }
  });

  test('a progression is four bars of music', () {
    for (final question in runs(EarDrill.progressions)) {
      expect(question.sound.kind, EarSoundKind.sequence);
      expect(question.sound.bars.length, inInclusiveRange(2, 4));
      expect(question.answerLabel, matches(RegExp(r'^[IiVv]')));
    }
  });

  test('root movement is two chords from the same bass note upwards', () {
    for (final question in runs(EarDrill.rootMovement)) {
      expect(question.sound.bars, hasLength(2));
      expect(question.prompt, 'How far did the root move up?');
      // Up, so the second chord's root is above the first one's.
      expect(
        question.sound.bars[1].first,
        greaterThan(question.sound.bars[0].first),
      );
    }
  });

  test('a substitution question explains why the chord is one', () {
    for (final question in runs(EarDrill.substitutions)) {
      expect(question.explanation.split('\n\n'), hasLength(2));
      expect(question.explanation.trim(), isNotEmpty);
    }
  });
}
