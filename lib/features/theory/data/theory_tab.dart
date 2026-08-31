/// The seven views of a key the theory browser offers, in the order they are shown.
///
/// Named rather than counted, because they are linked to from outside: a dashboard
/// shortcut to the modes and a search result about the circle of fifths both have to say
/// which tab they mean, and `?tab=circle` in a URL survives a tab being inserted in front
/// of it in a way that `?tab=5` does not.
enum TheoryTab {
  chords,
  shapes,
  caged,
  scales,
  progressions,
  substitutions,
  circle;

  String get label => switch (this) {
    TheoryTab.chords => 'Chords',
    TheoryTab.shapes => 'Shapes',
    TheoryTab.caged => 'CAGED',
    TheoryTab.scales => 'Scales',
    TheoryTab.progressions => 'Progressions',
    TheoryTab.substitutions => 'Substitutions',
    TheoryTab.circle => 'Circle',
  };
}
