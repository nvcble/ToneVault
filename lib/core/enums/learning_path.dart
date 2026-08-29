/// One of the two ways through the Academy.
///
/// Rhythm and lead are kept completely separate rather than being two halves of
/// one syllabus. A player who wants to hold a song together behind a singer and
/// a player who wants to solo over it need different things in a different order,
/// and asking either of them to work past the other's material to reach their own
/// is how a course gets abandoned. Nothing is shared between the two but the
/// theory both of them lean on.
enum LearningPath {
  rhythm,
  lead;

  String get label => switch (this) {
    LearningPath.rhythm => 'Rhythm Guitar',
    LearningPath.lead => 'Lead Guitar',
  };

  /// What the path is for, in the words of what the player will be able to do.
  String get summary => switch (this) {
    LearningPath.rhythm =>
      'Chords, strumming and feel. Holding a song together.',
    LearningPath.lead => 'Scales, phrasing and soloing. Playing over a song.',
  };
}
