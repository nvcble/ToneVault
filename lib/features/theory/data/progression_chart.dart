import '../../../core/music/chord.dart';
import '../../../core/music/nashville.dart';
import '../../../core/music/progression.dart';
import '../../../core/music/scale.dart';
import '../../../core/music/scale_type.dart';

/// One named progression, in a key, in all three of the ways it gets written down.
///
/// The numerals are how theory writes it, the numbers are how a band calls it, and the
/// symbols are what a guitarist plays. A player who has only ever seen one of the three
/// is the reason all three are on the row.
class ProgressionChart {
  const ProgressionChart({
    required this.name,
    required this.numerals,
    required this.key,
    required this.chords,
  });

  final String name;

  /// As the engine was given it: `I-V-vi-IV`.
  final String numerals;

  final Scale key;
  final List<Chord> chords;

  /// The chords as they are spelled in this key, so a chart in Eb reads Ab and not G#.
  String get symbols =>
      chords.map((chord) => chord.spell(flats: key.prefersFlats)).join('  ');

  /// The same chords as Nashville numbers, which is the form that survives the singer
  /// asking for it a tone lower.
  String get numbers =>
      chords.map((chord) => nashvilleNumber(chord, key)).join(' ');
}

/// Every named progression, read in the key the player has chosen.
///
/// A progression whose tonic is written in lower case belongs to a minor key, so it is
/// read in the minor key of the same root rather than in the major one: an Andalusian
/// cadence read in C major would spell its chords outside the key it lives in. Anything
/// the engine cannot read is left out rather than shown broken, which in practice means
/// nothing - a test holds this list to being readable in all twelve keys.
List<ProgressionChart> chartsIn(Scale chosen) {
  return [
    for (final entry in namedProgressions.entries)
      ?_chart(entry.key, entry.value, _keyFor(entry.value, chosen)),
  ];
}

Scale _keyFor(String numerals, Scale chosen) {
  final wanted = numerals.startsWith('i') ? ScaleType.minor : ScaleType.major;
  return chosen.type == wanted ? chosen : Scale(chosen.root, wanted);
}

ProgressionChart? _chart(String name, String numerals, Scale key) {
  try {
    return ProgressionChart(
      name: name,
      numerals: numerals,
      key: key,
      chords: romanProgression(numerals, key),
    );
  } on Object {
    return null;
  }
}
