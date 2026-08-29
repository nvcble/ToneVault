import '../../../core/errors/app_failure.dart';
import '../../../core/music/chord.dart';
import '../../../core/music/nashville.dart';
import '../../../core/music/scale.dart';

/// A line a player has typed, turned into the other way of writing it.
///
/// Both directions live in one function because they are one question asked from either
/// end, and because a screen that could translate a chart but not check its own answer
/// would only teach half of the system.
///
/// Nothing here throws. A half-typed line is not an error - it is a player mid-word - so
/// what comes back is either the reading or what was wrong with it, and the field they
/// are typing in never explodes underneath them.

/// Which way round the line is being read.
enum NashvilleDirection {
  /// `1 5 6m 4` into `C  G  Am  F`.
  numbersToChords,

  /// `C G Am F` into `1 5 6 4`.
  chordsToNumbers;

  String get label => switch (this) {
    NashvilleDirection.numbersToChords => 'Numbers to chords',
    NashvilleDirection.chordsToNumbers => 'Chords to numbers',
  };

  /// What the field is asking for, and an example of it.
  String get prompt => switch (this) {
    NashvilleDirection.numbersToChords => 'A line of numbers',
    NashvilleDirection.chordsToNumbers => 'A line of chords',
  };

  String get example => switch (this) {
    NashvilleDirection.numbersToChords => '1 5 6m 4',
    NashvilleDirection.chordsToNumbers => 'C G Am F',
  };
}

/// The reading, or what was wrong with the line. Never both.
class NashvilleReading {
  const NashvilleReading.read(String this.answer) : problem = null;

  const NashvilleReading.problem(String this.problem) : answer = null;

  final String? answer;

  /// Phrased for the player, because it is by the engine that raised it.
  final String? problem;

  bool get isRead => answer != null;
}

/// Reads [written] in [key], whichever way [direction] says, or null where nothing has
/// been typed yet.
NashvilleReading? readNashville(
  String written,
  Scale key,
  NashvilleDirection direction,
) {
  final text = written.trim();
  if (text.isEmpty) {
    return null;
  }

  try {
    return NashvilleReading.read(switch (direction) {
      NashvilleDirection.numbersToChords => _chordsOf(text, key),
      NashvilleDirection.chordsToNumbers => _numbersOf(text, key),
    });
  } on AppFailure catch (failure) {
    return NashvilleReading.problem(failure.message);
  }
}

/// Spelled the way the key spells its notes, so a 4 in Eb is Ab and not G#.
String _chordsOf(String line, Scale key) => [
  for (final chord in nashvilleLine(line, key))
    chord.spell(flats: key.prefersFlats),
].join('   ');

String _numbersOf(String line, Scale key) => [
  for (final word in _words(line)) nashvilleNumber(Chord.parse(word), key),
].join(' ');

/// Split the way a chart is written: spaces, dashes, commas or bar lines.
Iterable<String> _words(String line) => [
  for (final word in line.split(RegExp(r'[\s\-,|]+')))
    if (word.isNotEmpty) word,
];
