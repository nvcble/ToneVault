import 'dart:math';

import '../../../core/audio/pitch_frequency.dart';
import '../../../core/music/chord.dart';
import '../../../core/music/chord_family.dart';
import '../../../core/music/chord_type.dart';
import '../../../core/music/interval.dart';
import '../../../core/music/progression.dart';
import '../../../core/music/scale.dart';
import '../../../core/music/scale_type.dart';
import '../../../core/music/substitution.dart';
import 'ear_question.dart';
import 'ear_random.dart';

/// The drills that ask about more than one chord at a time.
///
/// Kept apart from the chord drills because these ones are questions about movement -
/// where the harmony went, not what was sounding - and they are built differently: the
/// sound is bars rather than a strum, and the answers are numbers and distances rather
/// than chord symbols.

/// Four bars in a key, answered as numerals.
///
/// Numerals rather than chord names on purpose: a progression heard as `I-V-vi-IV` is
/// heard in every key at once, which is the whole reason the numbers exist. The key is
/// chosen at random each time so the answer cannot be memorised as a set of chords.
EarQuestion progressionQuestion(Random random) {
  final key = Scale(anyRoot(random), ScaleType.major);
  final names = someOf(random, _progressionNames, 4);
  final answer = random.nextInt(names.length);

  final name = names[answer];
  final numerals = namedProgressions[name]!;
  final chords = romanProgression(numerals, key);

  return EarQuestion(
    prompt: 'In ${key.label}, which progression did you hear?',
    choices: [for (final each in names) namedProgressions[each]!],
    answer: answer,
    explanation:
        '$name: $numerals in ${key.label}\n'
        '${chords.map((chord) => chord.symbol).join(' - ')}',
    sound: EarSound.sequence([
      for (final chord in chords) voicingOf(chord, from: middleC - 12),
    ]),
  );
}

/// The named progressions that are four bars or fewer and written for a major key.
///
/// The twelve bar blues is left out for length - a player would sit through fourteen
/// seconds of it before answering - and the minor ones because they are numbered
/// against a minor key, which is not the key this drill plays in.
const List<String> _progressionNames = [
  'Three chords',
  'Pop',
  'Fifties',
  'Ballad',
  'Two five one',
  'Circle',
  'Backdoor',
];

/// How far the root moved between two chords.
///
/// The second chord is voiced up from the first rather than from the bottom of the
/// neck, so a movement up a minor seventh is heard going up. Left to itself the voicing
/// would find the nearest place to play the second chord, which could be below the
/// first and would make the answer wrong by an octave.
EarQuestion rootMovementQuestion(Random random) {
  final root = anyRoot(random);
  final moves = someOf(random, const [
    majorSecond,
    minorThird,
    majorThird,
    perfectFourth,
    perfectFifth,
    majorSixth,
    minorSeventh,
  ], 4);

  final answer = random.nextInt(moves.length);
  final from = Chord(root, ChordType.major);
  final to = Chord(root.transpose(moves[answer]), ChordType.major);
  final bass = midiAtOrAbove(root, guitarLowE);

  return EarQuestion(
    prompt: 'How far did the root move up?',
    choices: [for (final move in moves) intervalLabel(move)],
    answer: answer,
    explanation:
        '${from.symbol} to ${to.symbol}\n'
        'Up a ${intervalLabel(moves[answer])}.',
    sound: EarSound.sequence([
      voicingOf(from, from: bass),
      voicingOf(to, from: bass),
    ]),
  );
}

/// Which dominant was played where the key expects its own.
///
/// The choices are what the engine offers as substitutes for that dominant, so this
/// drill and the substitutions in the lessons are the same harmony: what is being
/// trained is hearing a tritone substitute rather than reading about one.
EarQuestion substitutionQuestion(Random random) {
  final key = Scale(anyRoot(random), ScaleType.major);
  final dominant = ChordFamily(key).chordOn(5)!.seventh;
  final substitutes = substitutionsFor(dominant, key);

  final options = [
    dominant,
    ...someOf(random, substitutes, 3).map((each) => each.chord),
  ]..shuffle(random);

  final answer = random.nextInt(options.length);
  final chord = options[answer];
  final reason = substitutes
      .where((each) => each.chord == chord)
      .map((each) => each.reason)
      .join();

  return EarQuestion(
    prompt: 'In ${key.label}, which dominant did you hear?',
    choices: [for (final option in options) option.symbol],
    answer: answer,
    explanation:
        '${explainChord(chord)}\n\n'
        '${reason.isEmpty ? 'The dominant of ${key.label} itself, unaltered.' : reason}',
    sound: EarSound.chord(voicingOf(chord)),
  );
}
