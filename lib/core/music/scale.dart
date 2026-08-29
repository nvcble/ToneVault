import 'pitch_class.dart';
import 'scale_type.dart';

/// A scale in a key: a root and a formula, resolved to notes on demand.
///
/// Nothing is precomputed. There are twelve roots and seventeen scale types, and a
/// table of the two hundred and four results would be two hundred and four chances to
/// be wrong about something the formula already knows.
class Scale {
  const Scale(this.root, this.type);

  final PitchClass root;
  final ScaleType type;

  /// The notes, from the root upwards.
  List<PitchClass> get notes => [
    for (final semitones in type.semitones) root.transpose(semitones),
  ];

  /// Whether a note belongs to the scale. This is the question a fretboard asks
  /// about every fret it draws, so it stays a lookup and not a search through
  /// spelled names.
  bool contains(PitchClass note) =>
      type.semitones.contains(root.intervalTo(note));

  /// The nth note counting the root as 1, wrapping past the top so `degree(9)` is
  /// the second an octave up - which is how an extension is named.
  PitchClass degree(int number) {
    final degrees = type.semitones;
    final index = (number - 1) % degrees.length;
    return root.transpose(degrees[index]);
  }

  /// Which degree a note is, or null where the note is not in the scale. Used for
  /// labelling a fretboard with numbers rather than names, which is how a player
  /// learns to move a shape between keys.
  int? degreeOf(PitchClass note) {
    final index = type.semitones.indexOf(root.intervalTo(note));
    return index < 0 ? null : index + 1;
  }

  /// Flats where the key is usually written with them. A guitarist reading a chart
  /// in Eb wants Ab, not G#, and this is the one place that decision can be made
  /// once for a whole scale.
  ///
  /// Which spelling is usual depends on the third as well as on the root: the same
  /// note is Db as a major key and C# as a minor one, and the two sets below are the
  /// keys as they are actually written on charts.
  bool get prefersFlats => type.isMinorSounding
      ? const {0, 2, 3, 5, 7, 10}.contains(root.semitone)
      : const {1, 3, 5, 8, 10}.contains(root.semitone);

  String get label => '${root.name(flats: prefersFlats)} ${type.label}';

  @override
  bool operator ==(Object other) =>
      other is Scale && other.root == root && other.type == type;

  @override
  int get hashCode => Object.hash(root, type);

  @override
  String toString() => label;
}
