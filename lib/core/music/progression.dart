import '../errors/app_failure.dart';
import 'chord.dart';
import 'chord_family.dart';
import 'chord_type.dart';
import 'scale.dart';

/// Progressions written in roman numerals, resolved into chords in a key.
///
/// Numerals rather than numbers here, because that is how theory is written down
/// where Nashville numbers are how it is called out. `ii-V-I` and `2m7 57 1maj7` are
/// the same progression in two trades' handwriting, and the engine reads both.

/// Reads one numeral in [key]: `I`, `ii`, `V7`, `bVII`, `IVmaj7`, `vii°`.
///
/// Case decides the quality where nothing else says: `IV` is major, `iv` is minor.
/// Anything after the numeral is read as a chord symbol, so `V7` and `iim7b5` work.
Chord romanChord(String numeral, Scale key) {
  final text = numeral.trim();
  final accidental = switch (text.isEmpty ? '' : text[0]) {
    'b' => -1,
    '#' => 1,
    _ => 0,
  };

  final body = accidental == 0 ? text : text.substring(1);
  final match = RegExp(
    r'^(iv|vi{0,3}|i{1,3}|v|IV|VI{0,3}|I{1,3}|V)',
  ).firstMatch(body);
  if (match == null) {
    throw AppFailure('"$numeral" is not a chord numeral.');
  }

  final roman = match.group(0)!;
  final degree = _degrees[roman.toUpperCase()];
  if (degree == null) {
    throw AppFailure('"$numeral" is not a chord numeral.');
  }

  final diatonic = ChordFamily(key).chordOn(degree);
  if (diatonic == null) {
    throw AppFailure('${key.label} has no numbered chords.');
  }

  final root = diatonic.triad.root.transpose(accidental);
  final quality = _quality(body.substring(roman.length), roman);
  return Chord.parse('${root.name(flats: key.prefersFlats)}$quality');
}

/// Reads a whole progression: `I-V-vi-IV`, `ii V I`, `I | IV | V7 | I`.
List<Chord> romanProgression(String written, Scale key) => [
  for (final numeral in written.split(RegExp(r'[\s\-,|]+')))
    if (numeral.isNotEmpty) romanChord(numeral, key),
];

/// The progressions worth knowing by name, as numerals so they work in any key.
///
/// A short list on purpose. These are the ones the curriculum refers to by name; the
/// engine can resolve any progression a lesson writes out, so this is a convenience
/// and not a catalogue anybody has to maintain.
///
/// Numerals are read against whichever key they are given, so the minor ones are
/// spelled as a minor key spells them - `VII` in A minor is already G, and writing
/// `bVII` there would ask for a chord a semitone lower than the one meant.
const Map<String, String> namedProgressions = {
  'Three chords': 'I-IV-V',
  'Pop': 'I-V-vi-IV',
  'Fifties': 'I-vi-IV-V',
  'Ballad': 'vi-IV-I-V',
  'Two five one': 'ii-V-I',
  'Minor two five one': 'iiø7-V7-i',
  'Twelve bar blues': 'I7-I7-I7-I7-IV7-IV7-I7-I7-V7-IV7-I7-V7',
  'Andalusian': 'i-VII-VI-V',
  'Backdoor': 'IV-bVII7-I',
  'Circle': 'vi-ii-V-I',
};

const Map<String, int> _degrees = {
  'I': 1,
  'II': 2,
  'III': 3,
  'IV': 4,
  'V': 5,
  'VI': 6,
  'VII': 7,
};

/// The symbol to build the chord from: what was written after the numeral, or the
/// quality the numeral's case implies where nothing was.
String _quality(String written, String roman) {
  final lower = roman == roman.toLowerCase();
  final symbol = written
      .replaceAll('°7', ChordType.diminishedSeventh.symbol)
      .replaceAll('°', ChordType.diminished.symbol)
      .replaceAll('ø7', ChordType.halfDiminished.symbol)
      .replaceAll('ø', ChordType.halfDiminished.symbol)
      .replaceAll('+', ChordType.augmented.symbol);

  if (symbol.isEmpty) {
    return lower ? ChordType.minor.symbol : '';
  }
  if (lower && symbol == ChordType.majorSeventh.symbol) {
    return ChordType.minorMajorSeventh.symbol;
  }
  // `iim7` and `ii7` both mean a minor seventh: the numeral already said minor, so
  // an extension written after a lower-case numeral does not have to repeat it.
  if (lower && !symbol.startsWith('m') && !symbol.startsWith('dim')) {
    return 'm$symbol';
  }
  return symbol;
}
