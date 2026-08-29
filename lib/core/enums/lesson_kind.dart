/// What a lesson asks of the player.
///
/// It decides what the lesson screen puts in front of them - a metronome for a
/// practice routine, a fretboard for a technique, a player for ear training - so
/// a lesson does not have to say twice what it is.
enum LessonKind {
  concept,
  technique,
  theory,
  genre,
  earTraining,
  practice;

  String get label => switch (this) {
    LessonKind.concept => 'Concept',
    LessonKind.technique => 'Technique',
    LessonKind.theory => 'Theory',
    LessonKind.genre => 'Style',
    LessonKind.earTraining => 'Ear training',
    LessonKind.practice => 'Practice',
  };

  /// Whether the lesson is worth practising to a click. A concept is read and a
  /// technique is felt; a practice routine and a style are played in time.
  bool get wantsMetronome =>
      this == LessonKind.practice ||
      this == LessonKind.technique ||
      this == LessonKind.genre;
}
