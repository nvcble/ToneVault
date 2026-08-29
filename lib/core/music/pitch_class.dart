import '../errors/app_failure.dart';

/// One of the twelve notes, with no octave attached.
///
/// A pitch class rather than a pitch, because everything this engine is asked is
/// about relationships - the third of a chord, the fifth of a key, the note two
/// frets up - and none of those questions care which octave the answer is in. The
/// fretboard puts them in octaves later, from a shape and a string.
///
/// Stored as a semitone from C, so all arithmetic is addition modulo twelve. That
/// is the whole trick: there is no table of note names in here to get out of step
/// with itself.
class PitchClass {
  const PitchClass._(this.semitone);

  /// Wraps, so `PitchClass(14)` is D and `PitchClass(-1)` is B. Callers doing
  /// interval arithmetic should not have to think about the edge of the octave.
  factory PitchClass(int semitone) => PitchClass._(semitone % 12);

  /// Reads a written note: `C`, `F#`, `Bb`, `Cb`, `A##`. Case matters for the
  /// letter and not for the accidental, because `bb` has to keep meaning B flat.
  factory PitchClass.parse(String written) {
    final text = written.trim();
    final letter = _letters.indexOf(text.isEmpty ? '' : text[0].toUpperCase());
    if (letter < 0) {
      throw AppFailure('"$written" is not a note name.');
    }

    var semitone = _letterSemitones[letter];
    for (final accidental in text.substring(1).split('')) {
      switch (accidental) {
        case '#':
          semitone++;
        case 'b':
        case 'B':
          semitone--;
        default:
          throw AppFailure('"$written" is not a note name.');
      }
    }
    return PitchClass(semitone);
  }

  /// 0 is C, 1 is C#, 11 is B.
  final int semitone;

  static const List<String> _letters = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
  static const List<int> _letterSemitones = [0, 2, 4, 5, 7, 9, 11];
  static const List<String> _sharpNames = [
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B',
  ];
  static const List<String> _flatNames = [
    'C',
    'Db',
    'D',
    'Eb',
    'E',
    'F',
    'Gb',
    'G',
    'Ab',
    'A',
    'Bb',
    'B',
  ];

  /// The name to show. Which spelling is right depends on the key the note is being
  /// read in - Eb and D# are the same fret and not the same note on a chart - so
  /// the caller says, and the default is what a guitarist reads most often.
  String name({bool flats = false}) =>
      (flats ? _flatNames : _sharpNames)[semitone];

  /// Flats where the note is usually written with them: Bb, Eb and Ab rather than A#,
  /// D# and G#.
  ///
  /// A default rather than an answer. Anything that knows the key it is reading in
  /// should say so instead, because that key is what settles the spelling; this is for
  /// a note being shown on its own, where there is no key to ask.
  bool get prefersFlats => const {1, 3, 5, 8, 10}.contains(semitone);

  PitchClass transpose(int semitones) => PitchClass(semitone + semitones);

  /// Upwards, so C to A is 9 and A to C is 3. Intervals in music are directed and
  /// a plain difference would give one of them a negative answer.
  int intervalTo(PitchClass other) => (other.semitone - semitone) % 12;

  @override
  bool operator ==(Object other) =>
      other is PitchClass && other.semitone == semitone;

  @override
  int get hashCode => semitone.hashCode;

  @override
  String toString() => name();
}
