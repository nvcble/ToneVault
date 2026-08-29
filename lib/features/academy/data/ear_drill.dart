import '../../../core/enums/skill_level.dart';

/// The ear training drills the app ships with.
///
/// Levelled the same way the courses are, and for the same reason: a player who cannot
/// yet hear major from minor is not helped by a drill on altered dominants, and one
/// working through the professional path is not helped by being asked again whether a
/// chord is bright or dark.
///
/// Each of these is a rule rather than a set of questions - see `ear_questions.dart` -
/// so a drill never runs out and never repeats itself in the same order twice.
enum EarDrill {
  majorOrMinor(
    SkillLevel.beginner,
    'Major or minor',
    'The one difference every other one is heard against.',
  ),
  openChords(
    SkillLevel.beginner,
    'Open chords',
    'The first shapes a player learns, named by ear.',
  ),
  chordsInAKey(
    SkillLevel.beginner,
    'Chords in a key',
    'Which chord of a key was played, which is how a song is followed.',
  ),
  // Intermediate rather than beginner, because naming a distance needs the words for
  // one: intervals are taught in the intermediate lessons, and a player who has not met
  // them yet would be guessing between four terms rather than listening.
  intervals(
    SkillLevel.intermediate,
    'Intervals',
    'Two notes, and how far apart they were.',
  ),
  seventhChords(
    SkillLevel.intermediate,
    'Seventh chords',
    'Major, minor, dominant and half diminished, in any key.',
  ),
  susChords(
    SkillLevel.intermediate,
    'Sus chords',
    'A third held back, and whether it was held above or below.',
  ),
  extendedChords(
    SkillLevel.advanced,
    'Extended chords',
    'Ninths, elevenths and thirteenths.',
  ),
  inversions(
    SkillLevel.advanced,
    'Inversions',
    'Which note of the chord was underneath it.',
  ),
  progressions(
    SkillLevel.advanced,
    'Progressions',
    'Four bars, heard as numbers rather than as chords.',
  ),
  alteredChords(
    SkillLevel.professional,
    'Altered chords',
    'Where a dominant has been sharpened or flattened, and which note.',
  ),
  voicings(
    SkillLevel.professional,
    'Voicings',
    'The same chord, and which of its notes was on top.',
  ),
  rootMovement(
    SkillLevel.professional,
    'Root movement',
    'How far the bass moved between two chords.',
  ),
  substitutions(
    SkillLevel.professional,
    'Substitutions',
    'Which dominant was played in the place the key expects one.',
  );

  const EarDrill(this.level, this.label, this.summary);

  final SkillLevel level;
  final String label;

  /// What the drill trains, in one line, for the list it is chosen from.
  final String summary;

  static List<EarDrill> forLevel(SkillLevel level) => [
    for (final drill in values)
      if (drill.level == level) drill,
  ];
}
