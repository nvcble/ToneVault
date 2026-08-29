/// How far along a path a piece of the course sits.
///
/// Declaration order is the order a player works through, so iterating the enum
/// gives the four bands in the right order without a sort. Both paths use all
/// four: a beginner rhythm player and a beginner lead player are at the same
/// distance from the start of different journeys.
enum SkillLevel {
  beginner,
  intermediate,
  advanced,
  professional;

  String get label => switch (this) {
    SkillLevel.beginner => 'Beginner',
    SkillLevel.intermediate => 'Intermediate',
    SkillLevel.advanced => 'Advanced',
    SkillLevel.professional => 'Professional',
  };

  /// What a player at this level is working on, so the band is chosen by what it
  /// asks of them rather than by a word whose meaning everyone sets differently.
  String get summary => switch (this) {
    SkillLevel.beginner => 'First chords, first songs.',
    SkillLevel.intermediate => 'Playing in any key, and hearing why.',
    SkillLevel.advanced => 'Voicings, substitutions and style.',
    SkillLevel.professional => 'Reading a room, and the whole instrument.',
  };
}
