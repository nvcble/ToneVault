import 'chord.dart';
import 'chord_type.dart';
import 'pitch_class.dart';
import 'scale.dart';

/// One chord of a key, with the number and the numeral a player would call it by.
class DiatonicChord {
  const DiatonicChord({
    required this.degree,
    required this.triad,
    required this.seventh,
  });

  /// 1 to 7, counting the tonic as 1.
  final int degree;
  final Chord triad;
  final Chord seventh;

  /// `I`, `ii`, `V`, `vii°` - upper case where the chord is major, lower where it is
  /// minor, and marked where it is neither.
  String get roman => _roman(degree, triad.type);

  /// The same numeral with the seventh's quality on it, as a chart writes it:
  /// `Imaj7`, `ii7`, `V7`.
  String get romanSeventh => _roman(degree, seventh.type);
}

/// The chords a key is built from, worked out from its scale.
///
/// Stacked rather than tabulated: every third note of the scale, three of them for a
/// triad and four for a seventh. That is where the familiar pattern of a major key -
/// major, minor, minor, major, major, minor, diminished - comes from, and deriving it
/// means a minor key, a mode or harmonic minor gives its own pattern for free rather
/// than needing a table of its own.
class ChordFamily {
  ChordFamily(this.key);

  final Scale key;

  /// The seven chords, in scale order. A pentatonic or blues scale has no seventh
  /// degree to stack on, so it has no family - the list is empty rather than wrong.
  List<DiatonicChord> get chords {
    final notes = key.notes;
    if (notes.length != 7) {
      return const [];
    }

    return [
      for (var degree = 1; degree <= 7; degree++)
        DiatonicChord(
          degree: degree,
          triad: _stack(notes, degree, 3),
          seventh: _stack(notes, degree, 4),
        ),
    ];
  }

  /// The chord on one degree, counting the tonic as 1. Numbers past 7 wrap, so 9 is
  /// the chord on the second degree - which is how a progression is often called.
  DiatonicChord? chordOn(int degree) {
    final all = chords;
    if (all.isEmpty) {
      return null;
    }
    return all[(degree - 1) % 7];
  }

  /// Which degree a chord sits on, or null where it is borrowed from somewhere else.
  /// Matched by root and by whether the third agrees, so a ii played as a ii7 is
  /// still the ii.
  int? degreeOf(Chord chord) {
    for (final diatonic in chords) {
      if (diatonic.triad.root == chord.root &&
          diatonic.triad.type.isMinor == chord.type.isMinor) {
        return diatonic.degree;
      }
    }
    return null;
  }

  /// Every third note from [degree], [size] of them, named as a chord.
  ///
  /// Where the stack spells something this app has no name for - which happens in
  /// harmonic minor, whose third degree is an augmented major seventh - the chord
  /// falls back to the plain triad rather than inventing a symbol.
  Chord _stack(List<PitchClass> notes, int degree, int size) {
    final root = notes[degree - 1];
    final intervals = [
      for (var step = 0; step < size; step++)
        root.intervalTo(notes[(degree - 1 + step * 2) % 7]),
    ];

    final type = chordTypeFor(intervals) ?? chordTypeFor(intervals.take(3));
    return Chord(root, type ?? ChordType.major);
  }
}

const List<String> _numerals = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII'];

String _roman(int degree, ChordType type) {
  final numeral = _numerals[(degree - 1) % 7];
  final quality = switch (type) {
    ChordType.major || ChordType.minor => '',
    ChordType.diminished => '°',
    ChordType.augmented => '+',
    ChordType.halfDiminished => 'ø7',
    ChordType.diminishedSeventh => '°7',
    ChordType.majorSeventh || ChordType.minorMajorSeventh => 'maj7',
    ChordType.minorSeventh || ChordType.dominantSeventh => '7',
    // A numeral says the quality already, so what is left is the extension: a
    // ii played as a m9 is `ii9`, not `iim9`.
    _ => type.symbol.startsWith('m') ? type.symbol.substring(1) : type.symbol,
  };
  return (type.isMinor ? numeral.toLowerCase() : numeral) + quality;
}
