import 'chord.dart';
import 'chord_shape.dart';
import 'chord_shape_library.dart';
import 'fretboard.dart';
import 'pitch_class.dart';

/// A shape put somewhere on a neck: an actual chord, at actual frets.
///
/// The shape says what the hand does and this says where. Keeping them apart is what
/// makes one E shape into twelve chords, and it means a voicing has no notes of its own
/// to be wrong about - it asks the fretboard what each fret gives.
class ChordVoicing {
  const ChordVoicing({
    required this.shape,
    required this.chord,
    required this.rootFret,
    this.fretboard = const Fretboard(),
  });

  final ChordShape shape;

  final Chord chord;

  /// The fret the shape's root sits at on its own string.
  final int rootFret;

  final Fretboard fretboard;

  String get name => shape.name;

  int get stringCount => shape.frets.length;

  /// The fret to hold on a string, 0 being open, or null where the string is not played.
  int? fretOn(int string) {
    final relative = shape.frets[string];
    return relative == null ? null : relative + rootFret;
  }

  /// The finger to hold it with, or null for an open string as well as for one not
  /// played: an open string is held by nothing, whatever the shape says about it further
  /// up the neck.
  int? fingerOn(int string) =>
      (fretOn(string) ?? 0) == 0 ? null : shape.fingers[string];

  PitchClass? noteOn(int string) {
    final fret = fretOn(string);
    return fret == null ? null : fretboard.noteAt(string, fret);
  }

  /// The strings that are played, lowest first.
  List<int> get soundingStrings => [
    for (var string = 0; string < stringCount; string++)
      if (shape.frets[string] != null) string,
  ];

  List<int> get mutedStrings => [
    for (var string = 0; string < stringCount; string++)
      if (shape.frets[string] == null) string,
  ];

  /// The notes it actually sounds, in the order the strings are strummed.
  List<FretNote> get notes => [
    for (final string in soundingStrings)
      FretNote(string: string, fret: fretOn(string)!, note: noteOn(string)!),
  ];

  /// The lowest and highest fret a finger has to reach, open strings aside. Both are
  /// [rootFret] where nothing is held at all, which only happens on an open shape whose
  /// every sounding string rings.
  int get lowestHeldFret =>
      _heldFrets.fold<int?>(null, (a, b) => a == null || b < a ? b : a) ??
      rootFret;

  int get highestHeldFret =>
      _heldFrets.fold<int?>(null, (a, b) => a == null || b > a ? b : a) ??
      rootFret;

  /// How many frets the hand has to cover, which is what decides whether a shape is
  /// comfortable or a stretch.
  int get span => highestHeldFret - lowestHeldFret + 1;

  /// Whether any string rings open, which is what a player means by an open chord.
  bool get isOpen => soundingStrings.any((string) => fretOn(string) == 0);

  Iterable<int> get _heldFrets => [
    for (final string in soundingStrings)
      if (fretOn(string)! > 0) fretOn(string)!,
  ];
}

/// Every way this app knows to hold [chord], lowest on the neck first.
///
/// One placement per shape: the lowest one that fits the window. A shape repeats every
/// twelve frets and the higher copies are the same fingering further along, so offering
/// them would be padding a list rather than teaching anything.
///
/// A slash chord is voiced as the chord itself. The shapes carry their own bass note, and
/// there is no honest way to bend one into putting a different note underneath.
List<ChordVoicing> voicingsFor(
  Chord chord, {
  Fretboard fretboard = const Fretboard(),
}) {
  final found = <ChordVoicing>[];

  for (final shape in shapesFor(chord.type)) {
    final rootFret = _lowestRootFret(shape, chord.root, fretboard);
    if (rootFret != null) {
      found.add(
        ChordVoicing(
          shape: shape,
          chord: chord,
          rootFret: rootFret,
          fretboard: fretboard,
        ),
      );
    }
  }

  found.sort((one, other) => one.rootFret.compareTo(other.rootFret));
  return found;
}

/// The lowest fret where [shape] can carry [root] and still fit on the neck, or null
/// where it cannot.
int? _lowestRootFret(ChordShape shape, PitchClass root, Fretboard fretboard) {
  final from = fretboard.firstFret + shape.reachBelowRoot;

  for (var fret = from; fret <= fretboard.lastFret; fret++) {
    if (fretboard.noteAt(shape.rootString, fret) != root) {
      continue;
    }
    final fits = shape.frets.every(
      (relative) => relative == null || relative + fret <= fretboard.lastFret,
    );
    if (fits) {
      return fret;
    }
  }
  return null;
}
