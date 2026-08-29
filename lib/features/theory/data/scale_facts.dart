import '../../../core/music/chord.dart';
import '../../../core/music/chord_type.dart';
import '../../../core/music/scale.dart';
import '../../../core/music/scale_type.dart';

/// What there is to say about a scale beyond the notes in it: where it comes from, the
/// note that gives it its sound, and the chords it can be played over.
///
/// Worked out from the formula rather than tabulated, the way a key's facts are worked
/// out from the circle, so a scale added to the engine arrives here explained. The only part
/// that cannot be derived is what a player does with it, and that lives next door in
/// `scale_uses.dart` as prose.
class ScaleFacts {
  const ScaleFacts({
    required this.scale,
    required this.parent,
    required this.characteristicTones,
    required this.chords,
  });

  factory ScaleFacts.of(Scale scale) => ScaleFacts(
    scale: scale,
    parent: _parentOf(scale),
    characteristicTones: _characteristicTonesOf(scale.type),
    chords: _chordsOver(scale),
  );

  final Scale scale;

  /// The scale this one is made out of, or null where it is made out of nothing else.
  ///
  /// For a mode that is the scale it is a rotation of - D Dorian is C major started on
  /// its second degree. For a pentatonic it is the seven-note scale it has notes taken
  /// out of. Harmonic minor, melodic minor and the symmetrical scales have no parent:
  /// they are their own formula.
  final Scale? parent;

  /// The degrees that make this scale sound unlike the ordinary major or minor scale on
  /// the same root: `#4` for Lydian, `b2` for Phrygian, `natural 6` for Dorian.
  ///
  /// One or two notes, not the whole formula. A player learning Lydian is learning to
  /// lean on one note, and this is that note.
  final List<String> characteristicTones;

  /// Chords on the scale's own root that the scale spells every note of, so a player
  /// can see what it may be played over rather than being told to work it out.
  final List<Chord> chords;

  /// Whether [parent] has the same notes rather than merely containing them, which is
  /// the difference between a mode and a scale with notes left out.
  bool get isRotationOfParent =>
      parent != null &&
      parent!.type.semitones.length == scale.type.semitones.length;
}

/// Which scale each one is a rotation or a subset of, and how far below its root the
/// parent's root sits.
///
/// The distance is the parent's own degree that the child starts on: Dorian starts on
/// the major scale's second degree, two semitones up, so D Dorian is C major.
const Map<ScaleType, (ScaleType, int)> _parents = {
  ScaleType.dorian: (ScaleType.major, 2),
  ScaleType.phrygian: (ScaleType.major, 4),
  ScaleType.lydian: (ScaleType.major, 5),
  ScaleType.mixolydian: (ScaleType.major, 7),
  ScaleType.minor: (ScaleType.major, 9),
  ScaleType.locrian: (ScaleType.major, 11),
  ScaleType.lydianDominant: (ScaleType.melodicMinor, 5),
  ScaleType.altered: (ScaleType.melodicMinor, 11),
  // Not rotations but reductions: five of the seven notes, on the same root.
  ScaleType.majorPentatonic: (ScaleType.major, 0),
  ScaleType.minorPentatonic: (ScaleType.minor, 0),
  // The blues scale is deliberately absent. A player learns it as the minor pentatonic
  // with a flat five added, and adding a note is the opposite relationship to the one
  // this table describes - every scale here has all of its child's notes. Its own
  // description says where it comes from instead.
};

Scale? _parentOf(Scale scale) {
  final parent = _parents[scale.type];
  if (parent == null) {
    return null;
  }

  final (type, below) = parent;
  return Scale(scale.root.transpose(-below), type);
}

/// The degrees where this scale disagrees with the plain major or minor scale on the
/// same root, named by position rather than by semitone.
///
/// Position is what makes `#4` come out of Lydian instead of the `b5` the semitone on
/// its own would suggest - the note is the fourth degree, raised, and a player who calls
/// it a flat fifth is describing a different scale. A raised degree that lands where the
/// major scale has it is said as natural, because "natural 6" is what a Dorian player
/// says and "sharp 6" is what nobody says.
///
/// Only for the seven-note scales. A pentatonic has no degree to line up against a major
/// scale's fourth, and a symmetrical scale disagrees with everything, so both say nothing
/// here and leave the explaining to their notes and their formula.
List<String> _characteristicTonesOf(ScaleType type) {
  final steps = type.semitones;
  final reference = type.isMinorSounding ? ScaleType.minor : ScaleType.major;
  final theirs = reference.semitones;
  if (type == reference || steps.length != theirs.length) {
    return const [];
  }

  final major = ScaleType.major.semitones;
  final tones = <String>[];
  for (var index = 0; index < steps.length; index++) {
    if (steps[index] == theirs[index]) {
      continue;
    }
    final degree = index + 1;
    tones.add(switch (steps[index]) {
      final step when step < theirs[index] => 'b$degree',
      final step when step == major[index] => 'natural $degree',
      _ => '#$degree',
    });
  }
  return tones;
}

/// Every quality on the root whose notes the scale already has.
///
/// The chromatic scale is left out on purpose: it spells every chord there is, so listing
/// them would be a wall of symbols that tells a player nothing about the scale.
List<Chord> _chordsOver(Scale scale) {
  if (scale.type == ScaleType.chromatic) {
    return const [];
  }

  final steps = {for (final semitone in scale.type.semitones) semitone % 12};
  return [
    for (final type in ChordType.values)
      if (type.intervals.every((interval) => steps.contains(interval % 12)))
        Chord(scale.root, type),
  ];
}
