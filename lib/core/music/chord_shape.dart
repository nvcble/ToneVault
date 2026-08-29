import 'chord_type.dart';

/// A chord shape as the hand holds it, before it is put anywhere on the neck.
///
/// Frets are counted from the root's own fret rather than from the nut, so one shape is
/// every chord of its quality: the E shape is E at the nut, G at the third fret and A at
/// the fifth. That is how a guitarist learns the neck, and it is why the library beside
/// this file is forty shapes rather than a table of five hundred chords.
///
/// [rootString] is what pins a shape to a key: whichever string carries the root has to
/// give the chord's root note, and working out where on the neck that happens is
/// arithmetic. Nothing here knows a fret number.
class ChordShape {
  const ChordShape(
    this.name,
    this.type,
    this.rootString,
    this.frets,
    this.fingers,
  );

  /// The five families, each named for the open chord whose geometry it is and each
  /// carrying its root on its own string. Written as constructors because the name and
  /// the root string are not two facts - `E shape` *means* the root is on the low E, and
  /// a table that stated both could disagree with itself.
  const ChordShape.e(ChordType type, List<int?> frets, List<int?> fingers)
    : this('E shape', type, 0, frets, fingers);

  const ChordShape.a(ChordType type, List<int?> frets, List<int?> fingers)
    : this('A shape', type, 1, frets, fingers);

  const ChordShape.d(ChordType type, List<int?> frets, List<int?> fingers)
    : this('D shape', type, 2, frets, fingers);

  /// The two that reach below their root: the C shape carries its root on the A string
  /// and the G shape on the low E, like the A and E shapes, but both stretch backwards
  /// down the neck instead of forwards.
  const ChordShape.c(ChordType type, List<int?> frets, List<int?> fingers)
    : this('C shape', type, 1, frets, fingers);

  const ChordShape.g(ChordType type, List<int?> frets, List<int?> fingers)
    : this('G shape', type, 0, frets, fingers);

  /// What a player calls it: `E shape`, `A shape`.
  final String name;

  final ChordType type;

  /// The string carrying the root, 0 being the lowest-sounding one.
  final int rootString;

  /// One entry per string, lowest first, counted from the root's fret. Null is a string
  /// not played.
  ///
  /// Negative is allowed and is not a mistake: the C and G shapes reach below their
  /// root, and a library that could not say so would be a library without them.
  final List<int?> frets;

  /// Which finger holds each fret, 1 being the index. Null where the string is not
  /// played, and the same number twice is a barre.
  ///
  /// Part of the shape rather than worked out from it: which finger goes where is what
  /// makes one fingering of the same notes playable and another not, and no amount of
  /// arithmetic over pitch classes can decide it.
  ///
  /// A finger on a string that turns out open is dropped when the shape is placed, so
  /// these can be written once for the shape wherever it lands.
  final List<int?> fingers;

  /// How far below its root the shape reaches, which is how far up the neck it has to
  /// start before it can be played at all.
  int get reachBelowRoot {
    var lowest = 0;
    for (final fret in frets) {
      if (fret != null && fret < lowest) {
        lowest = fret;
      }
    }
    return -lowest;
  }
}

/// A string not played, written as it is written under a chord box.
const int? x = null;
