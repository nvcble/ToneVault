import 'interval.dart';

/// The scales the engine knows, as formulas rather than as note lists.
///
/// Every seven-note scale here is either the major scale's pattern of steps started
/// from a different degree, or that pattern with one note moved. Nothing is written
/// out twice: the modes are rotations, and the two useful modes of melodic minor are
/// rotations of it. That is what keeps this file short and keeps a mistake in one
/// scale from being a mistake in only one of the twelve keys it appears in.
///
/// The pentatonics and the blues scale are given as degrees, because they are not
/// rotations of anything - they are the seven-note scales with notes taken out, and
/// saying which notes is clearer than saying which steps.
///
/// The last three are the symmetrical ones, and they are why nothing here assumes a
/// scale has seven notes. A whole tone scale has six, a diminished scale eight and the
/// chromatic scale twelve; each is one step repeated, so each is a step pattern like
/// the others rather than a special case.
enum ScaleType {
  major,
  dorian,
  phrygian,
  lydian,
  mixolydian,
  minor,
  locrian,
  harmonicMinor,
  melodicMinor,
  lydianDominant,
  altered,
  majorPentatonic,
  minorPentatonic,
  blues,
  wholeTone,
  diminished,
  chromatic;

  /// The scale as semitones above its root, root included.
  List<int> get semitones => switch (this) {
    ScaleType.major => _degreesOf(_majorSteps),
    ScaleType.dorian => _degreesOf(_rotate(_majorSteps, 1)),
    ScaleType.phrygian => _degreesOf(_rotate(_majorSteps, 2)),
    ScaleType.lydian => _degreesOf(_rotate(_majorSteps, 3)),
    ScaleType.mixolydian => _degreesOf(_rotate(_majorSteps, 4)),
    ScaleType.minor => _degreesOf(_rotate(_majorSteps, 5)),
    ScaleType.locrian => _degreesOf(_rotate(_majorSteps, 6)),
    ScaleType.harmonicMinor => _degreesOf(_harmonicMinorSteps),
    ScaleType.melodicMinor => _degreesOf(_melodicMinorSteps),
    ScaleType.lydianDominant => _degreesOf(_rotate(_melodicMinorSteps, 3)),
    ScaleType.altered => _degreesOf(_rotate(_melodicMinorSteps, 6)),
    ScaleType.majorPentatonic => const [0, 2, 4, 7, 9],
    ScaleType.minorPentatonic => const [0, 3, 5, 7, 10],
    ScaleType.blues => const [0, 3, 5, 6, 7, 10],
    ScaleType.wholeTone => _degreesOf(_wholeToneSteps),
    ScaleType.diminished => _degreesOf(_diminishedSteps),
    ScaleType.chromatic => _degreesOf(_chromaticSteps),
  };

  String get label => switch (this) {
    ScaleType.major => 'major',
    ScaleType.dorian => 'Dorian',
    ScaleType.phrygian => 'Phrygian',
    ScaleType.lydian => 'Lydian',
    ScaleType.mixolydian => 'Mixolydian',
    ScaleType.minor => 'minor',
    ScaleType.locrian => 'Locrian',
    ScaleType.harmonicMinor => 'harmonic minor',
    ScaleType.melodicMinor => 'melodic minor',
    ScaleType.lydianDominant => 'Lydian dominant',
    ScaleType.altered => 'altered',
    ScaleType.majorPentatonic => 'major pentatonic',
    ScaleType.minorPentatonic => 'minor pentatonic',
    ScaleType.blues => 'blues',
    ScaleType.wholeTone => 'whole tone',
    ScaleType.diminished => 'diminished',
    ScaleType.chromatic => 'chromatic',
  };

  /// The scale as the degrees it takes: `1 b3 4 5 b7` is the minor pentatonic in every
  /// key there is.
  ///
  /// This is the form a scale is taught and remembered in, and the reason it is worth
  /// showing next to the notes: the notes are one key's worth of the answer, and the
  /// formula is all twelve.
  String get formula => semitones.map(degreeLabel).join(' ');

  /// Each note's distance from the root said in words: `root, minor 3rd, perfect 4th`.
  List<String> get intervalNames => [
    for (final semitone in semitones)
      semitone == 0 ? 'root' : intervalLabel(semitone),
  ];

  /// Whether the third of the scale is minor, which is what decides whether a
  /// player calls the whole thing a minor sound. The locrian and altered scales
  /// count: their third is flat even though nobody thinks of them as minor keys.
  bool get isMinorSounding => semitones.contains(3);

  /// Whether a player would call this a mode: the same notes as a scale they already
  /// know, started somewhere else.
  ///
  /// Major and minor are left out, though they are rotations of each other. A player
  /// learning Dorian is learning a mode; a player in C major is in a key, and calling
  /// that a mode of A minor would be true and no use to anybody.
  bool get isMode => const {
    ScaleType.dorian,
    ScaleType.phrygian,
    ScaleType.lydian,
    ScaleType.mixolydian,
    ScaleType.locrian,
    ScaleType.lydianDominant,
    ScaleType.altered,
  }.contains(this);
}

/// Tone, tone, semitone, tone, tone, tone, semitone. Everything else in the file
/// is this, moved.
const List<int> _majorSteps = [2, 2, 1, 2, 2, 2, 1];

/// Major with a flat third and a flat sixth: the step and a half between them is
/// the sound of the scale.
const List<int> _harmonicMinorSteps = [2, 1, 2, 2, 1, 3, 1];

/// Natural minor with the seventh raised, so the five chord of a minor key has a
/// scale that fits it.
const List<int> _melodicMinorSteps = [2, 1, 2, 2, 2, 2, 1];

/// Nothing but tones. Six notes, no semitone anywhere, and the same scale started on
/// any of its own notes - which is why it has no modes and no home.
const List<int> _wholeToneSteps = [2, 2, 2, 2, 2, 2];

/// Tone, semitone, over and over: eight notes, and the reason a diminished seventh
/// chord can stand for any of four roots.
///
/// This is the whole-half form, the one that fits a diminished chord. Started a
/// semitone along it is the half-whole scale a player uses over an altered dominant -
/// the same eight notes, so it is a rotation rather than a scale of its own.
const List<int> _diminishedSteps = [2, 1, 2, 1, 2, 1, 2, 1];

/// Every note there is. Not a key and not a sound, but the thing a run between two
/// notes is drawn from, and a fretboard worth being able to show.
const List<int> _chromaticSteps = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];

/// The same steps started [by] places along, which is all a mode is.
List<int> _rotate(List<int> steps, int by) => [
  for (var index = 0; index < steps.length; index++)
    steps[(index + by) % steps.length],
];

/// Steps between neighbours turned into distances from the root.
List<int> _degreesOf(List<int> steps) {
  final degrees = <int>[0];
  var total = 0;
  for (final step in steps.take(steps.length - 1)) {
    total += step;
    degrees.add(total);
  }
  return degrees;
}
