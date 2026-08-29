import 'dart:math';

import '../../../core/audio/pitch_frequency.dart';
import '../../../core/music/interval.dart';
import 'ear_question.dart';
import 'ear_random.dart';

/// The drill that asks about two notes rather than a chord.
///
/// Its own file for the reason the harmony drills have theirs: this one is not built
/// from chords at all. There is nothing to voice and no quality to compare - two notes
/// are played one after the other and the answer is the distance between them, which
/// is the one thing every scale, chord and lick in the app is measured in.
///
/// Played in turn rather than together, because that is how a player meets an interval:
/// as two notes of a melody. Ascending only, so "a minor 6th" means one sound and not
/// two - a descending major 3rd covers the same distance and is a different thing to
/// hear, and mixing them into one drill would make a wrong answer ambiguous.
EarQuestion intervalQuestion(Random random) {
  final root = anyRoot(random);
  final options = someOf(random, _intervals, 4);
  final answer = random.nextInt(options.length);
  final heard = options[answer];

  // From the octave above the low E, so the top note of the widest interval is still
  // somewhere a guitar plays rather than up in a whistle.
  final low = midiAtOrAbove(root, guitarLowE + 12);
  final upper = root.transpose(heard);

  return EarQuestion(
    prompt: 'Which interval did you hear?',
    choices: [for (final option in options) intervalLabel(option)],
    answer: answer,
    explanation:
        '${root.name()} up to ${upper.name()}\n'
        'Up $heard semitones: ${intervalLabel(heard)}.',
    sound: EarSound.notes([low, low + heard]),
  );
}

/// Every interval inside one octave, and the octave itself.
///
/// The unison is left out: two notes at the same pitch is not a distance a player is
/// asked to name. The octave is kept, because hearing it against a major 7th is exactly
/// the ear this drill is for.
const List<int> _intervals = [
  minorSecond,
  majorSecond,
  minorThird,
  majorThird,
  perfectFourth,
  tritone,
  perfectFifth,
  minorSixth,
  majorSixth,
  minorSeventh,
  majorSeventh,
  octave,
];
