import '../errors/app_failure.dart';
import 'chord_type.dart';
import 'interval.dart';
import 'pitch_class.dart';

/// A chord: a root, a quality, and sometimes a bass note that is not the root.
///
/// Notes are worked out from the quality's intervals every time they are asked for.
/// A chord has no voicing here and no strings - which fingering to show is a
/// fretboard's decision, made from these notes and the position it is drawing.
class Chord {
  const Chord(this.root, this.type, {this.bass});

  /// Reads a chord symbol: `C`, `Am7`, `F#m7b5`, `Bb13`, `C/E`.
  ///
  /// Refuses anything it does not understand rather than guessing, because a chord
  /// this engine cannot read is a lesson pointing at something that will not be
  /// drawn, and that is worth finding out in a test rather than on a screen.
  factory Chord.parse(String written) {
    final text = written.trim();
    final slash = text.indexOf('/');
    final bass = slash < 0 ? null : PitchClass.parse(text.substring(slash + 1));
    final body = slash < 0 ? text : text.substring(0, slash);

    final rootLength = body.length > 1 && (body[1] == '#' || body[1] == 'b')
        ? 2
        : 1;
    final root = PitchClass.parse(body.substring(0, rootLength));
    final symbol = body.substring(rootLength);

    final type = _typeOf(symbol);
    if (type == null) {
      throw AppFailure('"$written" is not a chord this app can read.');
    }
    return Chord(root, type, bass: bass);
  }

  final PitchClass root;
  final ChordType type;

  /// The note underneath, where a chart asks for one. Null means the root is at the
  /// bottom, which is nearly always.
  final PitchClass? bass;

  /// The notes of the chord, root first, with the bass note in front of it where
  /// that is a note the chord does not already contain.
  List<PitchClass> get notes {
    final stacked = [
      for (final interval in type.intervals) root.transpose(interval),
    ];
    final under = bass;
    if (under == null || stacked.contains(under)) {
      return stacked;
    }
    return [under, ...stacked];
  }

  bool contains(PitchClass note) => notes.contains(note);

  /// The note that decides whether the chord is major or minor, which is the one a
  /// soloist aims at to make a change audible.
  PitchClass? get third {
    for (final interval in const [3, 4]) {
      if (type.intervals.contains(interval)) {
        return root.transpose(interval);
      }
    }
    return null;
  }

  Chord transpose(int semitones) =>
      Chord(root.transpose(semitones), type, bass: bass?.transpose(semitones));

  /// Flats where the chord is usually written with them, which is decided by its root:
  /// Bb and Eb rather than A# and D#.
  bool get prefersFlats => root.prefersFlats;

  /// Whether the chord's own notes read better with flats, which is not the same
  /// question as how its root is spelled.
  ///
  /// Every book spells C minor C Eb G and none of them spell it C D# G, though the root
  /// is a C either way: a lowered third, fifth or seventh is written as a flat whatever
  /// key it turns up in. The sharp ninth is the exception the rule has to allow for - a
  /// chord that already has a major third has spent its third, so the note three
  /// semitones up is a raised ninth and takes a sharp.
  ///
  /// Only note names turn on this. The symbol does not, because a chord's name follows
  /// its root and C#m7 is not Dbm7.
  bool get notesPreferFlats {
    final intervals = type.intervals;
    final loweredThird =
        intervals.contains(minorThird) && !intervals.contains(majorThird);
    return prefersFlats ||
        loweredThird ||
        intervals.contains(tritone) ||
        intervals.contains(minorSeventh);
  }

  String get symbol => spell(flats: prefersFlats);

  /// The symbol spelled the way a given key spells its notes.
  ///
  /// A chord has no key of its own, and that shows: the seventh chord of A harmonic
  /// minor is G#dim7, not the Abdim7 the chord would call itself left alone. Whatever
  /// knows which key the chord is being read in says which spelling to use.
  String spell({required bool flats}) {
    final name = '${root.name(flats: flats)}${type.symbol}';
    final under = bass;
    return under == null ? name : '$name/${under.name(flats: flats)}';
  }

  @override
  bool operator ==(Object other) =>
      other is Chord &&
      other.root == root &&
      other.type == type &&
      other.bass == bass;

  @override
  int get hashCode => Object.hash(root, type, bass);

  @override
  String toString() => symbol;
}

/// Symbols a player might write for the same quality. The enum's own symbol is
/// always accepted; these are the spellings that turn up on charts beside it.
const Map<String, ChordType> _aliases = {
  '': ChordType.major,
  'maj': ChordType.major,
  'M': ChordType.major,
  'min': ChordType.minor,
  '-': ChordType.minor,
  'm7-5': ChordType.halfDiminished,
  'ø': ChordType.halfDiminished,
  '°': ChordType.diminished,
  '°7': ChordType.diminishedSeventh,
  '+': ChordType.augmented,
  'M7': ChordType.majorSeventh,
  'min7': ChordType.minorSeventh,
  'min9': ChordType.minorNinth,
  '9sus4': ChordType.dominantSeventhSus4,
  '7sus': ChordType.dominantSeventhSus4,
  'alt': ChordType.dominantSeventhSharpNine,
  '7alt': ChordType.dominantSeventhSharpNine,
};

ChordType? _typeOf(String symbol) {
  for (final type in ChordType.values) {
    if (type.symbol == symbol) {
      return type;
    }
  }
  return _aliases[symbol];
}
