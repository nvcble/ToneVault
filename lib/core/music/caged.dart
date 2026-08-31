import 'chord.dart';
import 'chord_shape_library.dart';
import 'chord_type.dart';
import 'chord_voicing.dart';
import 'fretboard.dart';

/// The CAGED system: one chord held five ways, in the five shapes the neck is learned by.
///
/// C, A, G, E and D are the five open major chords, and the observation the system is
/// built on is that they are also the only five - move any of them up the neck until its
/// root is under the right finger and it is that chord. Nothing here is a new fact about
/// harmony. It is the shape library read in the order the shapes climb the neck, which is
/// the order a player learns them in.
const List<String> cagedShapes = [
  'C shape',
  'A shape',
  'G shape',
  'E shape',
  'D shape',
];

/// The neck a rotation needs.
///
/// Twelve frets is the app's usual window and it is a few short here: the last shape of
/// any root sits past the octave - the D shape of C starts at the tenth fret and reaches
/// the thirteenth - so a twelve-fret neck would drop whichever shape wrapped round and
/// leave the system looking like four. Every guitar has fifteen.
const Fretboard cagedNeck = Fretboard(fretCount: 15);

/// [chord] in each CAGED shape that can hold it, lowest on the neck first.
///
/// The order rotates with the root rather than always starting at C, because a shape lands
/// where its root is: C gives C-A-G-E-D and A gives A-G-E-D-C. Sorting by where each one
/// falls *is* that rotation, which is why a player only has to learn the word once.
List<ChordVoicing> cagedVoicings(
  Chord chord, {
  Fretboard fretboard = cagedNeck,
}) => [
  for (final voicing in voicingsFor(chord, fretboard: fretboard))
    if (cagedShapes.contains(voicing.name)) voicing,
];

/// The shapes of CAGED that cannot spell [type].
///
/// Most qualities have gaps, and saying which is better than a player counting three
/// diagrams and wondering where the other two went. A quality only gets a shape here when
/// it is one somebody actually holds.
List<String> cagedGaps(ChordType type) {
  final held = {for (final shape in shapesFor(type)) shape.name};

  return [
    for (final name in cagedShapes)
      if (!held.contains(name)) name,
  ];
}
