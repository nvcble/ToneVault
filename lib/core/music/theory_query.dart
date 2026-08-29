import 'chord.dart';
import 'interval.dart';
import 'nashville.dart';
import 'pitch_class.dart';
import 'progression.dart';
import 'scale.dart';
import 'scale_names.dart';

/// Whatever a lesson pointed at, in a form something can draw.
///
/// A lesson names its theory in the words a player would use - `Am7`, `A minor
/// pentatonic`, `1 5 6 4` - and a fretboard needs notes. This is the join between the
/// two, and it is a sealed type so a screen that handles a chord and forgets a scale
/// does not compile.
sealed class TheoryReference {
  const TheoryReference();

  /// What to call it on screen.
  String get label;
}

final class ChordReference extends TheoryReference {
  const ChordReference(this.chord);

  final Chord chord;

  @override
  String get label => chord.symbol;
}

final class ScaleReference extends TheoryReference {
  const ScaleReference(this.scale);

  final Scale scale;

  @override
  String get label => scale.label;
}

/// Two notes and the distance between them, which is what every shape on the neck is
/// measured in and the one thing a player cannot look up as a chord or a scale.
final class IntervalReference extends TheoryReference {
  const IntervalReference(this.root, this.semitones);

  final PitchClass root;

  /// How far above [root] the other note is.
  final int semitones;

  @override
  String get label =>
      '${root.name(flats: root.prefersFlats)} ${intervalLabel(semitones)}';
}

/// A chord asked about as an arpeggio: the same notes, found one at a time.
///
/// A separate reference rather than a flag on [ChordReference], because it is a
/// different thing to practise and the diagram says so. The notes are the chord's,
/// which is exactly the point - an arpeggio is where a chord's own notes are up and down
/// the neck rather than under one hand.
final class ArpeggioReference extends TheoryReference {
  const ArpeggioReference(this.chord);

  final Chord chord;

  @override
  String get label => '${chord.symbol} arpeggio';
}

final class ProgressionReference extends TheoryReference {
  const ProgressionReference(this.written, this.chords, this.key);

  /// As the lesson wrote it, so a chart can show the numbers it was called by.
  final String written;
  final List<Chord> chords;
  final Scale key;

  @override
  String get label => '$written in ${key.label}';
}

/// Reads one of a lesson's theory keys, or null where it says nothing this engine
/// knows.
///
/// Null rather than a thrown failure: a lesson is still worth reading when one of its
/// diagrams cannot be drawn. The shipped curriculum is held to a higher standard than
/// that by a test, which is the right place for a typo to be caught.
///
/// [key] is the key a progression is read against. Without one, a written progression
/// has no notes to become, so it is left unread.
TheoryReference? resolveTheoryKey(String written, {Scale? key}) {
  final text = written.trim();
  if (text.isEmpty) {
    return null;
  }

  // Before the chord below it, because the words in front of `arpeggio` are a chord and
  // reading them as one on their own would draw a chord box for something else.
  final arpeggio = _asArpeggio(text);
  if (arpeggio != null) {
    return arpeggio;
  }

  final scale = scaleFromName(text);
  if (scale != null) {
    return ScaleReference(scale);
  }

  final interval = _asInterval(text);
  if (interval != null) {
    return interval;
  }

  final progression = _asProgression(text, key);
  if (progression != null) {
    return progression;
  }

  try {
    return ChordReference(Chord.parse(text));
  } on Object {
    return null;
  }
}

/// The readable ones out of a lesson's list, in the order they were written.
List<TheoryReference> resolveTheoryKeys(
  Iterable<String> written, {
  Scale? key,
}) => [for (final entry in written) ?resolveTheoryKey(entry, key: key)];

/// `A perfect 5th`, `C minor 3rd`, `E tritone`: a note, and how far up from it.
///
/// The root is everything up to the first space, the same way a scale reads, so the two
/// cannot disagree about which word is the note.
IntervalReference? _asInterval(String text) {
  final space = text.indexOf(' ');
  if (space < 0) {
    return null;
  }

  final semitones = intervalFromName(text.substring(space + 1));
  if (semitones == null) {
    return null;
  }

  try {
    return IntervalReference(
      PitchClass.parse(text.substring(0, space)),
      semitones,
    );
  } on Object {
    return null;
  }
}

/// `Cmaj7 arpeggio`, `Am arp`: a chord, and the word that says to play it one note at a
/// time.
///
/// The chord in front of the word is written the way a chart writes one, because that is
/// what a chord is everywhere else in the engine. A quality spelled out in words - `C
/// major arpeggio` - is left to whatever is matching typed words against the chord
/// qualities, which knows what those words are called.
ArpeggioReference? _asArpeggio(String text) {
  final lower = text.toLowerCase();
  for (final word in const ['arpeggio', 'arp']) {
    if (!lower.endsWith(word)) {
      continue;
    }
    try {
      return ArpeggioReference(
        Chord.parse(text.substring(0, text.length - word.length)),
      );
    } on Object {
      return null;
    }
  }
  return null;
}

/// `I-V-vi-IV`, `1 5 6 4`, `ii V I`. Read as numbers where the first character is a
/// digit and as numerals otherwise, because those are the two ways it gets written
/// down and nothing else looks like either.
ProgressionReference? _asProgression(String text, Scale? key) {
  if (key == null || !_progressionPattern.hasMatch(text)) {
    return null;
  }

  final numbered = RegExp(r'\d').hasMatch(text);
  try {
    final chords = numbered
        ? nashvilleLine(text, key)
        : romanProgression(text, key);
    return chords.isEmpty ? null : ProgressionReference(text, chords, key);
  } on Object {
    return null;
  }
}

/// Numbers or numerals, separated the way a chart separates them. A single chord
/// symbol never matches, because a root note is not a numeral.
final RegExp _progressionPattern = RegExp(
  r'^[b#]?([1-7]|[ivIV]+)\S*([\s\-,|]+[b#]?([1-7]|[ivIV]+)\S*)+$',
);
