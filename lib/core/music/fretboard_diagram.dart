import 'chord.dart';
import 'interval.dart';
import 'pitch_class.dart';
import 'scale.dart';
import 'theory_query.dart';

/// What a fretboard is being asked to show: a name, a root, and which notes carry
/// which degree.
///
/// The widget that draws a fretboard reads nothing else. That is the point of this
/// class - a scale, a chord and one bar of a progression all arrive as the same three
/// things, so there is one fretboard in the app rather than one per kind of diagram.
class FretboardDiagram {
  const FretboardDiagram({
    required this.title,
    required this.root,
    required this.degrees,
    required this.prefersFlats,
  });

  /// What the diagram is of: `A minor pentatonic`, `Cmaj7`.
  final String title;

  final PitchClass root;

  /// The notes to mark, each with the degree a player counts it as: `1`, `b3`, `5`.
  final Map<PitchClass, String> degrees;

  /// Whether the notes are spelled with flats, decided by the scale or chord this came
  /// from rather than by each note on its own.
  final bool prefersFlats;

  List<PitchClass> get notes => degrees.keys.toList();

  /// The degree of a note, or null where the note is not in the diagram.
  String? degreeOf(PitchClass note) => degrees[note];

  String nameOf(PitchClass note) => note.name(flats: prefersFlats);

  /// The same notes under another name, for when what is being practised is not what the
  /// notes were worked out from: an arpeggio is a chord's notes, asked about as a shape
  /// to run rather than a shape to hold.
  FretboardDiagram retitled(String title) => FretboardDiagram(
    title: title,
    root: root,
    degrees: degrees,
    prefersFlats: prefersFlats,
  );
}

/// The diagram for a scale: every note, numbered as the scale is taught.
FretboardDiagram diagramOfScale(Scale scale) => FretboardDiagram(
  title: scale.label,
  root: scale.root,
  prefersFlats: scale.prefersFlats,
  degrees: {
    for (final semitones in scale.type.semitones)
      scale.root.transpose(semitones): degreeLabel(semitones),
  },
);

/// The diagram for a chord: the notes of the chord, numbered as its extensions are.
///
/// A sharp ninth is spelled as one rather than as the flat tenth the semitones alone
/// would suggest, because the chord already knows it has a major third and that is
/// what settles the question.
FretboardDiagram diagramOfChord(Chord chord) {
  final degrees = {
    for (final interval in chord.type.intervals)
      chord.root.transpose(interval): _degreeInChord(chord, interval),
  };

  // A slash chord can ask for a bass note the chord does not contain, and a player
  // still has to find it, so it is marked by whatever interval it is from the root.
  final bass = chord.bass;
  if (bass != null) {
    degrees.putIfAbsent(bass, () => degreeLabel(chord.root.intervalTo(bass)));
  }

  return FretboardDiagram(
    title: chord.symbol,
    root: chord.root,
    // The notes, not the name: a diagram of Cm marks an Eb, and calling it a D# would
    // be the neck disagreeing with every chart the player has ever read.
    prefersFlats: chord.notesPreferFlats,
    degrees: degrees,
  );
}

/// The diagram for an interval: the note it is measured from, and the note it lands on.
///
/// Two degrees and no more. Every one of the root's octaves is marked and so is every one
/// of the other note's, which is what makes the shape worth looking at - the same
/// distance turns up in five places within a hand's reach, and finding them is the point
/// of practising it.
FretboardDiagram diagramOfInterval(
  PitchClass root,
  int semitones,
) => FretboardDiagram(
  title: '${root.name(flats: root.prefersFlats)} ${intervalLabel(semitones)}',
  root: root,
  prefersFlats: root.prefersFlats,
  // The root is written last so that it wins: an octave lands back on the note it
  // started from, and that note is a 1 rather than an 8 wherever it is played.
  degrees: {
    root.transpose(semitones): degreeLabel(semitones),
    root: degreeLabel(unison),
  },
);

/// The diagram for an arpeggio, which is the chord's own notes under the chord's own
/// numbers.
///
/// The same diagram a chord draws, and deliberately so: an arpeggio is not other notes,
/// it is these ones one at a time. Only the title says which is being practised.
FretboardDiagram diagramOfArpeggio(Chord chord) =>
    diagramOfChord(chord).retitled('${chord.symbol} arpeggio');

/// One diagram for a chord or a scale, and one per chord for a progression.
///
/// A progression is a row of diagrams because that is how it is practised: the shapes
/// side by side, in the order they are played.
List<FretboardDiagram> diagramsFor(TheoryReference reference) =>
    switch (reference) {
      ChordReference(:final chord) => [diagramOfChord(chord)],
      ScaleReference(:final scale) => [diagramOfScale(scale)],
      IntervalReference(:final root, :final semitones) => [
        diagramOfInterval(root, semitones),
      ],
      ArpeggioReference(:final chord) => [diagramOfArpeggio(chord)],
      ProgressionReference(:final chords) => [
        for (final chord in chords) diagramOfChord(chord),
      ],
    };

/// The diagrams a lesson's theory keys ask for, in the order they were written.
///
/// A lesson names its key by naming a scale, so the first scale in the list is what a
/// progression in the same list is read against: `G major` followed by `1 5 6 4` is one
/// lesson's worth of theory rather than two unrelated things. Anything the engine
/// cannot read is left out, because a lesson is still worth reading without it.
List<FretboardDiagram> diagramsForKeys(Iterable<String> keys) {
  final written = keys.toList();

  Scale? key;
  for (final reference in resolveTheoryKeys(written)) {
    if (reference is ScaleReference) {
      key = reference.scale;
      break;
    }
  }

  return [
    for (final reference in resolveTheoryKeys(written, key: key))
      ...diagramsFor(reference),
  ];
}

String _degreeInChord(Chord chord, int interval) {
  final hasMajorThird = chord.type.intervals.contains(majorThird);
  if (hasMajorThird && interval % 12 == minorThird) {
    return '#9';
  }
  return degreeLabel(interval);
}
