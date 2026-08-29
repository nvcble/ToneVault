import '../errors/app_failure.dart';
import 'chord.dart';
import 'chord_family.dart';
import 'chord_type.dart';
import 'scale.dart';

/// The Nashville Number System: a chord called by where it sits in the key.
///
/// `1 5 6 4` is a song in any key, which is the whole point - a number is what gets
/// called on a stand, and a name is only what it turns into once somebody says which
/// key. Both directions are here, because a chart is read in numbers and a fretboard
/// is drawn from notes.
///
/// A bare number means the chord the key already has there: `2` in C major is Dm,
/// because that is what the second degree of C major is. A quality written after the
/// number overrides that - `2` is Dm and `27` is D7 - and a flat or sharp in front of
/// it moves the root outside the key.

/// Reads one number as a chord in [key]: `1`, `4`, `6m`, `57`, `b7`, `2m7`, `5sus4`.
Chord nashvilleChord(String number, Scale key) {
  final text = number.trim();
  final accidental = switch (text.isEmpty ? '' : text[0]) {
    'b' => -1,
    '#' => 1,
    _ => 0,
  };

  final body = accidental == 0 ? text : text.substring(1);
  final degree = int.tryParse(body.isEmpty ? '' : body[0]);
  if (degree == null || degree < 1 || degree > 7) {
    throw AppFailure('"$number" is not a chord number in a key.');
  }

  final diatonic = ChordFamily(key).chordOn(degree);
  if (diatonic == null) {
    throw AppFailure('${key.label} has no numbered chords.');
  }

  final quality = body.substring(1);
  final root = diatonic.triad.root.transpose(accidental);

  // Outside the key, there is no chord already there to inherit a quality from, so
  // an unqualified flat or sharp number is read as major - which is what a chart
  // means by bVII or bIII.
  if (quality.isEmpty) {
    return accidental == 0 ? diatonic.triad : Chord(root, ChordType.major);
  }
  return Chord.parse('${root.name(flats: key.prefersFlats)}$quality');
}

/// Reads a whole line of numbers: `1 5 6 4`, `1-5-6m-4`, `2m7 57 1maj7`.
List<Chord> nashvilleLine(String line, Scale key) => [
  for (final number in line.split(RegExp(r'[\s\-,|]+')))
    if (number.isNotEmpty) nashvilleChord(number, key),
];

/// What to call a chord in [key]. The reverse of [nashvilleChord], so a progression
/// read off a record can be written down in a form that survives a change of key.
///
/// A chord whose root is not in the key comes back with a flat or a sharp on it. A
/// chord whose quality is not the one the key has there keeps its own symbol.
String nashvilleNumber(Chord chord, Scale key) {
  final family = ChordFamily(key);
  final offset = key.root.intervalTo(chord.root);

  // In the key first, then a semitone below a degree, then above. Order matters: Eb
  // in C is the flat third every chart writes, not the sharp second it also is.
  for (final distance in const [0, 11, 1]) {
    for (var degree = 1; degree <= 7; degree++) {
      final diatonic = family.chordOn(degree);
      if (diatonic == null) {
        return chord.symbol;
      }

      final natural = key.root.intervalTo(diatonic.triad.root);
      if ((offset - natural) % 12 != distance) {
        continue;
      }

      if (distance == 0) {
        if (chord.type == diatonic.triad.type) {
          return '$degree';
        }
        // A bare number is read as the quality the key has there, so a major chord on
        // a degree the key spells minor has to say so: a `2` in C is Dm, and D major
        // written as `2` would come back as the wrong chord.
        final quality = chord.type.symbol;
        return '$degree${quality.isEmpty ? 'maj' : quality}';
      }

      // Outside the key there is nothing to inherit, and an unqualified number is
      // read as major, so a major chord needs no symbol here.
      return '${distance == 11 ? 'b' : '#'}$degree${chord.type.symbol}';
    }
  }
  return chord.symbol;
}
