import 'chord.dart';
import 'chord_family.dart';
import 'chord_type.dart';
import 'interval.dart';
import 'pitch_class.dart';
import 'scale.dart';

/// A chord that can stand in for another, and why.
///
/// The reason is not decoration. A substitution offered without one is a trick, and
/// the lessons that use this engine are teaching the reasoning rather than a list of
/// swaps to memorise.
class Substitution {
  const Substitution(this.chord, this.reason);

  final Chord chord;
  final String reason;

  @override
  String toString() => '${chord.symbol} - $reason';
}

/// What could be played instead of [chord] in [key].
///
/// Worked out from what the chord is, not looked up. Each rule below is one sentence
/// of harmony applied to whatever it is handed, which is why a dominant chord in any
/// key gets its tritone substitute without twelve of them being written down.
List<Substitution> substitutionsFor(Chord chord, Scale key) {
  final family = ChordFamily(key);
  final degree = family.degreeOf(chord);

  return [
    if (chord.type.isDominant)
      Substitution(
        Chord(chord.root.transpose(tritone), chord.type),
        'Tritone substitute: it shares the third and seventh with '
        '${chord.symbol}, swapped over, and resolves the same way with the '
        'bass moving down a semitone instead of down a fifth.',
      ),
    if (chord.type.isDominant)
      Substitution(
        Chord(chord.root, ChordType.dominantSeventhSharpNine),
        'The same dominant, altered. Anything that increases the pull to the '
        'chord a fourth above is available here.',
      ),
    if (!chord.type.isDominant)
      Substitution(
        Chord(chord.root.transpose(perfectFifth), ChordType.dominantSeventh),
        'Secondary dominant: the seventh chord a fifth above ${chord.symbol} '
        'leads into it, and any chord can be approached this way.',
      ),
    if (degree == 1) ...[
      Substitution(
        family.chordOn(6)!.triad,
        'The relative minor shares two notes out of three with the tonic, so it '
        'can carry the same melody with the weight taken out from under it.',
      ),
      Substitution(
        Chord(key.root.transpose(minorSeventh), ChordType.dominantSeventh),
        'The backdoor dominant, borrowed from the parallel minor. Softer into '
        'the tonic than the five chord, and everywhere in gospel.',
      ),
    ],
    if (degree == 4)
      Substitution(
        Chord(chord.root, ChordType.minor),
        'The borrowed minor four, taken from the parallel minor key. One note '
        'moves and the chord turns melancholy on the way back to the tonic.',
      ),
    if (degree == 5)
      Substitution(
        Chord(chord.root, ChordType.dominantSeventhSus4),
        'A suspended dominant delays the third, so the chord keeps its pull '
        'without stating whether it is major yet.',
      ),
    if (degree != null && degree != 1)
      Substitution(
        Chord(chord.root.transpose(-minorSecond), ChordType.diminishedSeventh),
        'A diminished seventh a semitone below leads into ${chord.symbol} with '
        'every voice moving by a semitone.',
      ),
  ];
}

/// The dominant that resolves to a chord, whether or not the key has one there. The
/// piece of reasoning behind secondary dominants, tritone substitutes and most of what
/// gospel players do between two chords.
Chord dominantOf(PitchClass root) =>
    Chord(root.transpose(perfectFifth), ChordType.dominantSeventh);

/// The tritone substitute of a dominant chord: same tension, different bass.
Chord tritoneSubstituteOf(Chord dominant) =>
    Chord(dominant.root.transpose(tritone), dominant.type);
