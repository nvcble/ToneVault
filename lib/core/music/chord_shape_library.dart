import 'chord_shape.dart';
import 'chord_type.dart';

/// The shapes the app can offer a fingering for.
///
/// A table, and it is meant to look like one: the shape family, the quality, the fret of
/// each string counted from the root, and the finger on each. `x` is a string not played,
/// as it is under a chord box.
///
/// Every shape here is checked by a test against the quality it claims to spell, so a
/// wrong number is a failing test rather than a chord diagram that quietly lies. The
/// check allows a voicing to leave notes out - a ninth with no fifth and an eleventh with
/// no third are what players actually hold - but never to add one the chord has not got.
///
/// Every quality in [ChordType] has at least one shape. Where a quality has several they
/// are written low to high, so a chord read out of this list reads up the neck.
const List<ChordShape> chordShapes = [
  // Major: all five of the shapes a guitarist knows the neck by.
  ChordShape.c(ChordType.major, [x, 0, -1, -3, -2, -3], [x, 4, 3, 1, 2, 1]),
  ChordShape.a(ChordType.major, [x, 0, 2, 2, 2, 0], [x, 1, 3, 3, 3, 1]),
  ChordShape.g(ChordType.major, [0, -1, -3, -3, -3, 0], [4, 2, 1, 1, 1, 4]),
  ChordShape.e(ChordType.major, [0, 2, 2, 1, 0, 0], [1, 3, 4, 2, 1, 1]),
  ChordShape.d(ChordType.major, [x, x, 0, 2, 3, 2], [x, x, 1, 2, 4, 3]),

  // Minor.
  ChordShape.e(ChordType.minor, [0, 2, 2, 0, 0, 0], [1, 3, 4, 1, 1, 1]),
  ChordShape.a(ChordType.minor, [x, 0, 2, 2, 1, 0], [x, 1, 3, 4, 2, 1]),
  ChordShape.d(ChordType.minor, [x, x, 0, 2, 3, 1], [x, x, 1, 3, 4, 2]),

  // The triads that are neither: one apiece, which is as many as either turns up as.
  ChordShape.a(ChordType.diminished, [x, 0, 1, 2, 1, x], [x, 1, 2, 4, 3, x]),
  ChordShape.e(ChordType.augmented, [0, 3, 2, 1, 1, x], [1, 4, 3, 2, 2, x]),

  // A third taken out, or everything but the fifth.
  ChordShape.a(ChordType.sus2, [x, 0, 2, 2, 0, 0], [x, 1, 3, 4, 1, 1]),
  ChordShape.d(ChordType.sus2, [x, x, 0, 2, 3, 0], [x, x, 1, 2, 3, 1]),
  ChordShape.e(ChordType.sus4, [0, 2, 2, 2, 0, 0], [1, 2, 3, 4, 1, 1]),
  ChordShape.a(ChordType.sus4, [x, 0, 0, 2, 3, 0], [x, 1, 1, 3, 4, 1]),
  ChordShape.e(ChordType.fifth, [0, 2, 2, x, x, x], [1, 3, 4, x, x, x]),
  ChordShape.a(ChordType.fifth, [x, 0, 2, 2, x, x], [x, 1, 3, 4, x, x]),

  // A note put on top of a triad rather than stacked on a seventh, which is why these
  // are here and not with the sevenths.
  ChordShape.a(ChordType.sixth, [x, 0, 2, 2, 2, 2], [x, 1, 3, 3, 3, 3]),
  ChordShape.e(ChordType.minorSixth, [0, 2, 2, 0, 2, 0], [1, 2, 3, 1, 4, 1]),
  ChordShape.a(ChordType.add9, [x, 0, 2, 4, 2, x], [x, 1, 2, 4, 3, x]),

  // The sevenths: three shapes each for the three a player meets constantly.
  ChordShape.e(
    ChordType.dominantSeventh,
    [0, 2, 0, 1, 0, 0],
    [1, 3, 1, 2, 1, 1],
  ),
  ChordShape.a(
    ChordType.dominantSeventh,
    [x, 0, 2, 0, 2, 0],
    [x, 1, 3, 1, 4, 1],
  ),
  ChordShape.d(
    ChordType.dominantSeventh,
    [x, x, 0, 2, 1, 2],
    [x, x, 1, 3, 2, 4],
  ),
  ChordShape.e(ChordType.majorSeventh, [0, 2, 1, 1, 0, 0], [1, 4, 2, 3, 1, 1]),
  ChordShape.a(ChordType.majorSeventh, [x, 0, 2, 1, 2, 0], [x, 1, 3, 2, 4, 1]),
  ChordShape.d(ChordType.majorSeventh, [x, x, 0, 2, 2, 2], [x, x, 1, 2, 3, 4]),
  ChordShape.e(ChordType.minorSeventh, [0, 2, 0, 0, 0, 0], [1, 3, 1, 1, 1, 1]),
  ChordShape.a(ChordType.minorSeventh, [x, 0, 2, 0, 1, 0], [x, 1, 3, 1, 2, 1]),
  ChordShape.d(ChordType.minorSeventh, [x, x, 0, 2, 1, 1], [x, x, 1, 3, 1, 2]),
  ChordShape.a(
    ChordType.minorMajorSeventh,
    [x, 0, 2, 1, 1, x],
    [x, 1, 4, 2, 3, x],
  ),
  ChordShape.a(
    ChordType.halfDiminished,
    [x, 0, 1, 0, 1, x],
    [x, 1, 3, 2, 4, x],
  ),
  ChordShape.d(
    ChordType.diminishedSeventh,
    [x, x, 0, 1, 0, 1],
    [x, x, 1, 3, 2, 4],
  ),

  // The extensions, which is where the fifth starts being dropped: five fingers are all
  // anybody has, and the ninth says more about the chord than the fifth does.
  ChordShape.c(
    ChordType.dominantNinth,
    [x, 0, -1, 0, 0, 0],
    [x, 2, 1, 3, 3, 3],
  ),
  ChordShape.c(ChordType.majorNinth, [x, 0, -1, 1, 0, x], [x, 2, 1, 4, 3, x]),
  ChordShape.c(ChordType.minorNinth, [x, 0, -2, 0, 0, x], [x, 2, 1, 3, 4, x]),
  ChordShape.a(ChordType.minorEleventh, [x, 0, 0, 0, 0, x], [x, 1, 1, 1, 1, x]),
  ChordShape.e(
    ChordType.dominantThirteenth,
    [0, x, 0, 1, 2, x],
    [1, x, 1, 2, 4, x],
  ),
  ChordShape.a(
    ChordType.dominantSeventhSus4,
    [x, 0, 2, 0, 3, 3],
    [x, 1, 3, 1, 4, 4],
  ),

  // The altered dominants: the same grip with one note moved, which is worth more than
  // variety here.
  ChordShape.c(
    ChordType.dominantSeventhFlatNine,
    [x, 0, -1, 0, -1, x],
    [x, 3, 1, 4, 2, x],
  ),
  ChordShape.c(
    ChordType.dominantSeventhSharpNine,
    [x, 0, -1, 0, 1, x],
    [x, 2, 1, 3, 4, x],
  ),
  ChordShape.a(
    ChordType.dominantSeventhFlatFive,
    [x, 0, 1, 0, 2, x],
    [x, 1, 2, 1, 4, x],
  ),
  ChordShape.a(
    ChordType.dominantSeventhSharpFive,
    [x, 0, 3, 0, 2, x],
    [x, 1, 4, 1, 3, x],
  ),
];

/// The shapes that spell [type], lowest on the neck first.
List<ChordShape> shapesFor(ChordType type) => [
  for (final shape in chordShapes)
    if (shape.type == type) shape,
];
