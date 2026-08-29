import 'pitch_class.dart';

/// How the open strings are tuned, lowest string first.
///
/// Held as pitch classes rather than as pitches, because everything a diagram needs to
/// know is which note a fret gives - not which octave it gives it in. That is also why
/// the twelfth fret is the open string again here, which is exactly what a guitarist
/// sees when they look at a neck.
///
/// Lowest first is the order the strings are wired up in, not the order they are drawn
/// in. A diagram puts the high string at the top; whatever draws it turns the list
/// round, so the tuning can stay in the order a player names it.
class Tuning {
  const Tuning(this.name, this.openStrings);

  final String name;

  /// Semitones from C for each open string: 4 is E, 9 is A.
  final List<int> openStrings;

  int get stringCount => openStrings.length;

  List<PitchClass> get notes => [
    for (final semitone in openStrings) PitchClass(semitone),
  ];

  /// The note a fret gives. Fret 0 is the open string.
  PitchClass noteAt(int string, int fret) =>
      PitchClass(openStrings[string] + fret);

  /// What the strings are called, as a tuning is written down: `E A D G B E`.
  String get label => [for (final note in notes) note.name()].join(' ');

  /// The tunings the Academy teaches in. Standard first, because every lesson that
  /// does not say otherwise means standard.
  static const Tuning standard = Tuning('Standard', [4, 9, 2, 7, 11, 4]);
  static const Tuning dropD = Tuning('Drop D', [2, 9, 2, 7, 11, 4]);
  static const Tuning halfStepDown = Tuning('Eb standard', [3, 8, 1, 6, 10, 3]);
  static const Tuning openG = Tuning('Open G', [2, 7, 2, 7, 11, 2]);
  static const Tuning openD = Tuning('Open D', [2, 9, 2, 6, 9, 2]);
  static const Tuning dadgad = Tuning('DADGAD', [2, 9, 2, 7, 9, 2]);

  static const List<Tuning> all = [
    standard,
    dropD,
    halfStepDown,
    openG,
    openD,
    dadgad,
  ];

  @override
  bool operator ==(Object other) =>
      other is Tuning &&
      other.name == name &&
      other.openStrings.length == openStrings.length &&
      other.label == label;

  @override
  int get hashCode => Object.hash(name, label);

  @override
  String toString() => '$name ($label)';
}
