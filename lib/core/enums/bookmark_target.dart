/// What kind of thing a bookmark points at.
///
/// A bookmark stores this and a key rather than a foreign key to one table. A
/// lesson is a row, but a chord, a scale and a progression are worked out by the
/// theory engine and have no row to point at: there is no `chords` table, because
/// there is no end to the chords a player might want to look up. So the key is a
/// string the engine can be asked to resolve again - "Cmaj7", "A dorian" - and
/// this says which way to read it.
/// Stored by name rather than by number, so a new kind can be added here without
/// touching a row that is already saved.
enum BookmarkTarget {
  lesson,
  chord,
  scale,

  /// A scale kept for being a mode: `D Dorian` rather than `D minor`.
  ///
  /// The same string as a scale and resolved the same way - what differs is what the
  /// player was doing. Somebody working through the modes of C keeps seven things that
  /// are all "a scale", and a list that called them that would be seven rows they have
  /// to read the label of to tell apart.
  mode,
  progression,

  /// A chord kept as a swap for another one: `Db7` kept while looking at `G7`.
  substitution;

  String get label => switch (this) {
    BookmarkTarget.lesson => 'Lesson',
    BookmarkTarget.chord => 'Chord',
    BookmarkTarget.scale => 'Scale',
    BookmarkTarget.mode => 'Mode',
    BookmarkTarget.progression => 'Progression',
    BookmarkTarget.substitution => 'Substitution',
  };
}
