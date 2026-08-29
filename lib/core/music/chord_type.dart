import 'interval.dart';

/// The chord qualities the engine knows, each as the intervals stacked above its
/// root and the symbol a player writes for it.
///
/// Quality and root are kept apart on purpose. There are twelve roots, so naming
/// every chord would mean listing this file twelve times over; a chord is a quality
/// applied to a root, and [Chord] does the applying.
///
/// The list is the working vocabulary of the curriculum rather than everything that
/// can be spelled. A quality earns its place here by appearing in a lesson.
enum ChordType {
  major,
  minor,
  diminished,
  augmented,
  sus2,
  sus4,
  fifth,
  sixth,
  minorSixth,
  add9,
  dominantSeventh,
  majorSeventh,
  minorSeventh,
  minorMajorSeventh,
  halfDiminished,
  diminishedSeventh,
  dominantNinth,
  majorNinth,
  minorNinth,
  minorEleventh,
  dominantThirteenth,
  dominantSeventhSus4,
  dominantSeventhFlatNine,
  dominantSeventhSharpNine,
  dominantSeventhFlatFive,
  dominantSeventhSharpFive;

  /// Semitones above the root, root included.
  ///
  /// Written as numbers rather than as the named intervals next door in
  /// `interval.dart`, because a chord is read as a shape: `0 4 7` is a major triad at
  /// sight, `0 3 7` is a minor one, and spelling each degree out in words would treble
  /// the length of this table without saying anything more. Extensions keep their real
  /// distance rather than being folded into an octave - 14 for a ninth, 21 for a
  /// thirteenth - so a fretboard can draw them where they are actually played.
  List<int> get intervals => switch (this) {
    ChordType.major => const [0, 4, 7],
    ChordType.minor => const [0, 3, 7],
    ChordType.diminished => const [0, 3, 6],
    ChordType.augmented => const [0, 4, 8],
    ChordType.sus2 => const [0, 2, 7],
    ChordType.sus4 => const [0, 5, 7],
    ChordType.fifth => const [0, 7],
    ChordType.sixth => const [0, 4, 7, 9],
    ChordType.minorSixth => const [0, 3, 7, 9],
    ChordType.add9 => const [0, 4, 7, 14],
    ChordType.dominantSeventh => const [0, 4, 7, 10],
    ChordType.majorSeventh => const [0, 4, 7, 11],
    ChordType.minorSeventh => const [0, 3, 7, 10],
    ChordType.minorMajorSeventh => const [0, 3, 7, 11],
    ChordType.halfDiminished => const [0, 3, 6, 10],
    ChordType.diminishedSeventh => const [0, 3, 6, 9],
    ChordType.dominantNinth => const [0, 4, 7, 10, 14],
    ChordType.majorNinth => const [0, 4, 7, 11, 14],
    ChordType.minorNinth => const [0, 3, 7, 10, 14],
    ChordType.minorEleventh => const [0, 3, 7, 10, 14, 17],
    ChordType.dominantThirteenth => const [0, 4, 7, 10, 14, 21],
    ChordType.dominantSeventhSus4 => const [0, 5, 7, 10],
    ChordType.dominantSeventhFlatNine => const [0, 4, 7, 10, 13],
    ChordType.dominantSeventhSharpNine => const [0, 4, 7, 10, 15],
    ChordType.dominantSeventhFlatFive => const [0, 4, 6, 10],
    ChordType.dominantSeventhSharpFive => const [0, 4, 8, 10],
  };

  /// What goes after the root: `Am7` is the root A and the symbol `m7`.
  String get symbol => switch (this) {
    ChordType.major => '',
    ChordType.minor => 'm',
    ChordType.diminished => 'dim',
    ChordType.augmented => 'aug',
    ChordType.sus2 => 'sus2',
    ChordType.sus4 => 'sus4',
    ChordType.fifth => '5',
    ChordType.sixth => '6',
    ChordType.minorSixth => 'm6',
    ChordType.add9 => 'add9',
    ChordType.dominantSeventh => '7',
    ChordType.majorSeventh => 'maj7',
    ChordType.minorSeventh => 'm7',
    ChordType.minorMajorSeventh => 'mMaj7',
    ChordType.halfDiminished => 'm7b5',
    ChordType.diminishedSeventh => 'dim7',
    ChordType.dominantNinth => '9',
    ChordType.majorNinth => 'maj9',
    ChordType.minorNinth => 'm9',
    ChordType.minorEleventh => 'm11',
    ChordType.dominantThirteenth => '13',
    ChordType.dominantSeventhSus4 => '7sus4',
    ChordType.dominantSeventhFlatNine => '7b9',
    ChordType.dominantSeventhSharpNine => '7#9',
    ChordType.dominantSeventhFlatFive => '7b5',
    ChordType.dominantSeventhSharpFive => '7#5',
  };

  /// The quality said in words, for where a chord is being explained rather than
  /// written: `Am7` is read out as "A minor seventh".
  String get label => switch (this) {
    ChordType.major => 'major',
    ChordType.minor => 'minor',
    ChordType.diminished => 'diminished',
    ChordType.augmented => 'augmented',
    ChordType.sus2 => 'suspended second',
    ChordType.sus4 => 'suspended fourth',
    ChordType.fifth => 'fifth',
    ChordType.sixth => 'sixth',
    ChordType.minorSixth => 'minor sixth',
    ChordType.add9 => 'added ninth',
    ChordType.dominantSeventh => 'dominant seventh',
    ChordType.majorSeventh => 'major seventh',
    ChordType.minorSeventh => 'minor seventh',
    ChordType.minorMajorSeventh => 'minor major seventh',
    ChordType.halfDiminished => 'half diminished',
    ChordType.diminishedSeventh => 'diminished seventh',
    ChordType.dominantNinth => 'dominant ninth',
    ChordType.majorNinth => 'major ninth',
    ChordType.minorNinth => 'minor ninth',
    ChordType.minorEleventh => 'minor eleventh',
    ChordType.dominantThirteenth => 'dominant thirteenth',
    ChordType.dominantSeventhSus4 => 'dominant seventh suspended fourth',
    ChordType.dominantSeventhFlatNine => 'dominant seventh flat nine',
    ChordType.dominantSeventhSharpNine => 'dominant seventh sharp nine',
    ChordType.dominantSeventhFlatFive => 'dominant seventh flat five',
    ChordType.dominantSeventhSharpFive => 'dominant seventh sharp five',
  };

  /// The chord written as the degrees it stacks: `1 3 5 b7`.
  ///
  /// The same information as [intervals] and the form a player reads it in. A chord
  /// heard as a sound is learned as a symbol; a chord understood is learned as which
  /// degrees of the scale it takes and which it leaves out.
  String get formula => intervals.map(degreeLabel).join(' ');

  /// Each step above the root said in words: `root, major 3rd, perfect 5th`.
  ///
  /// Kept apart from [formula] because the two answer different questions - the formula
  /// says what the chord is made of, and this says how far apart the notes sit, which is
  /// what makes one quality sound unlike another.
  List<String> get intervalNames => [
    for (final interval in intervals)
      interval == 0 ? 'root' : intervalLabel(interval),
  ];

  /// Whether the chord wants to resolve a fourth above its root. Every dominant
  /// quality does, and knowing which ones is what lets substitutions be worked out
  /// rather than listed.
  bool get isDominant => intervals.contains(4) && intervals.contains(10);

  bool get isMinor => intervals.contains(3);
}

/// The quality a set of intervals spells, or null where nothing here matches.
///
/// Used to name a chord that was built rather than written - the triads and sevenths
/// of a key are stacked out of a scale, and this is what turns the result back into
/// something a player can read. Compared as pitch classes, so a ninth stacked two
/// octaves up still counts as a ninth.
ChordType? chordTypeFor(Iterable<int> intervals) {
  final wanted = {for (final interval in intervals) interval % 12};
  for (final type in ChordType.values) {
    final spelled = {for (final interval in type.intervals) interval % 12};
    if (spelled.length == wanted.length && spelled.containsAll(wanted)) {
      return type;
    }
  }
  return null;
}
