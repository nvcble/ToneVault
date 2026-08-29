import 'dart:math';

import '../../../core/audio/pitch_frequency.dart';
import '../../../core/music/chord.dart';
import '../../../core/music/chord_family.dart';
import '../../../core/music/chord_type.dart';
import '../../../core/music/interval.dart';
import '../../../core/music/pitch_class.dart';
import '../../../core/music/scale.dart';
import '../../../core/music/scale_type.dart';
import 'ear_drill.dart';
import 'ear_harmony_questions.dart';
import 'ear_interval_questions.dart';
import 'ear_question.dart';
import 'ear_random.dart';

/// Where a drill turns into a question.
///
/// Everything here is worked out from the theory engine and a source of randomness.
/// Nothing is written down twice: the seventh chord drill knows the four qualities to
/// compare and the engine knows what a half diminished chord is, so between them any
/// root in any octave is a question, and there is no list of hundreds of them to keep
/// in step with itself.
///
/// The distractors are the point of the design. A question whose wrong answers are
/// random chords is answered by hearing anything at all; these ones put the same root
/// under every choice, so the only thing left to hear is the quality being drilled.
EarQuestion questionFor(EarDrill drill, Random random) => switch (drill) {
  EarDrill.majorOrMinor => _quality(
    random,
    const [ChordType.major, ChordType.minor],
    prompt: 'Major or minor?',
    label: (chord) => chord.type.isMinor ? 'Minor' : 'Major',
  ),
  EarDrill.openChords => _chordChoice(
    random,
    someOf(random, _openChords, 4),
    prompt: 'Which open chord did you hear?',
  ),
  EarDrill.chordsInAKey => _inKey(random),
  EarDrill.intervals => intervalQuestion(random),
  EarDrill.seventhChords => _quality(random, const [
    ChordType.dominantSeventh,
    ChordType.majorSeventh,
    ChordType.minorSeventh,
    ChordType.halfDiminished,
  ], prompt: 'Which seventh chord did you hear?'),
  EarDrill.susChords => _quality(random, const [
    ChordType.sus2,
    ChordType.sus4,
    ChordType.major,
    ChordType.minor,
  ], prompt: 'Suspended, and which way?'),
  EarDrill.extendedChords => _quality(
    random,
    someOf(random, _extended, 4),
    prompt: 'Which extension did you hear?',
  ),
  EarDrill.inversions => _inversion(random),
  EarDrill.alteredChords => _quality(
    random,
    someOf(random, _altered, 4),
    prompt: 'Which altered dominant did you hear?',
  ),
  EarDrill.voicings => _voicing(random),
  EarDrill.progressions => progressionQuestion(random),
  EarDrill.rootMovement => rootMovementQuestion(random),
  EarDrill.substitutions => substitutionQuestion(random),
};

/// The chords a beginner meets first, which are the ones that sound like a guitar
/// because they use the open strings.
final List<Chord> _openChords = [
  for (final symbol in const ['C', 'A', 'G', 'E', 'D', 'Am', 'Em', 'Dm'])
    Chord.parse(symbol),
];

const List<ChordType> _extended = [
  ChordType.dominantNinth,
  ChordType.majorNinth,
  ChordType.minorNinth,
  ChordType.minorEleventh,
  ChordType.dominantThirteenth,
  ChordType.add9,
  ChordType.sixth,
];

const List<ChordType> _altered = [
  ChordType.dominantSeventh,
  ChordType.dominantSeventhFlatNine,
  ChordType.dominantSeventhSharpNine,
  ChordType.dominantSeventhFlatFive,
  ChordType.dominantSeventhSharpFive,
  ChordType.dominantSeventhSus4,
];

/// One quality against others on the same root.
EarQuestion _quality(
  Random random,
  List<ChordType> types, {
  required String prompt,
  String Function(Chord chord)? label,
}) {
  final root = anyRoot(random);
  return _chordChoice(
    random,
    [for (final type in types) Chord(root, type)],
    prompt: prompt,
    label: label,
  );
}

/// Which chord of a key was played, in one of the keys a beginner plays in.
EarQuestion _inKey(Random random) {
  final key = Scale(oneOf(random, _easyKeys), ScaleType.major);
  final family = ChordFamily(key);
  final degrees = someOf(random, const [1, 2, 4, 5, 6], 4);

  return _chordChoice(random, [
    for (final degree in degrees) family.chordOn(degree)!.triad,
  ], prompt: 'In ${key.label}, which chord did you hear?');
}

/// The same chord over each of its own notes.
EarQuestion _inversion(Random random) {
  final root = anyRoot(random);
  final type = oneOf(random, const [
    ChordType.major,
    ChordType.minor,
    ChordType.dominantSeventh,
  ]);

  final chord = Chord(root, type);
  return _chordChoice(random, [
    chord,
    for (final note in chord.notes.skip(1)) Chord(root, type, bass: note),
  ], prompt: 'Which note was underneath the chord?');
}

/// One chord, voiced four ways, asking which note was on top.
EarQuestion _voicing(Random random) {
  final chord = Chord(
    anyRoot(random),
    oneOf(random, const [
      ChordType.majorSeventh,
      ChordType.minorSeventh,
      ChordType.dominantSeventh,
    ]),
  );

  final intervals = chord.type.intervals;
  final answer = random.nextInt(intervals.length);

  return EarQuestion(
    prompt: 'In ${chord.symbol}, which note was on top?',
    choices: [for (final interval in intervals) degreeLabel(interval)],
    answer: answer,
    explanation:
        '${chord.symbol} with the ${degreeLabel(intervals[answer])} on top\n'
        '${explainChord(chord)}',
    sound: EarSound.chord(voicingTopped(chord, intervals[answer])),
  );
}

/// A question built from chords, with one of them chosen as the answer.
///
/// The shuffle happens before the answer is picked rather than after, so the answer is
/// as likely to be in one place as another and a player cannot get a run right by
/// always tapping the second button.
EarQuestion _chordChoice(
  Random random,
  List<Chord> options, {
  required String prompt,
  String Function(Chord chord)? label,
}) {
  final shuffled = [...options]..shuffle(random);
  final answer = random.nextInt(shuffled.length);
  final chord = shuffled[answer];

  return EarQuestion(
    prompt: prompt,
    choices: [
      for (final option in shuffled) label?.call(option) ?? option.symbol,
    ],
    answer: answer,
    explanation: explainChord(chord),
    sound: EarSound.chord(voicingOf(chord)),
  );
}

/// The keys a beginner is asked to hear chords in: the ones their open chords are in.
final List<PitchClass> _easyKeys = [
  for (final semitone in const [0, 7, 2, 9, 4, 5]) PitchClass(semitone),
];
