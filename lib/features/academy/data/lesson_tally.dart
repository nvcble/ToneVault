/// How far through something the player is, counted in lessons.
///
/// A record rather than a class because that is all it is: two numbers that came
/// out of one query. The database layer hands back this same shape without naming
/// it - records are structural, so `core` does not have to import a feature to
/// return one - and everything above the database reads it through this.
///
/// Lessons rather than exercises or minutes. A lesson is the unit the player ticks
/// off, so it is the only unit they can check a percentage against.
typedef LessonTally = ({int lessons, int done});

/// Nothing counted: a course with no lessons in it, or a level with no courses.
const LessonTally emptyTally = (lessons: 0, done: 0);

/// One tally over several, which is how a level is the courses in it and a path is
/// its four levels.
LessonTally sumTallies(Iterable<LessonTally> tallies) {
  var lessons = 0;
  var done = 0;
  for (final tally in tallies) {
    lessons += tally.lessons;
    done += tally.done;
  }
  return (lessons: lessons, done: done);
}

extension LessonTallyReading on LessonTally {
  /// Nothing to be part way through. A level whose courses have not been loaded
  /// reads as this, and so does one whose courses are all still empty.
  bool get isEmpty => lessons == 0;

  bool get isComplete => lessons > 0 && done >= lessons;

  /// For a progress bar, which wants nought to one. Empty is nought rather than a
  /// division by zero.
  double get fraction => lessons == 0 ? 0 : (done / lessons).clamp(0, 1);

  /// Rounded down, not to the nearest. A course with one lesson left in it must
  /// not read as a hundred per cent, and rounding up is how that happens.
  int get percent {
    if (lessons == 0) {
      return 0;
    }
    if (done >= lessons) {
      return 100;
    }
    return (done * 100 / lessons).floor();
  }

  /// What the player reads beside the bar.
  ///
  /// The count comes first because it is the concrete half: "3 of 8" is what they
  /// can act on, and the percentage is the shape of it at a glance.
  String get label {
    final word = lessons == 1 ? 'lesson' : 'lessons';
    if (lessons == 0) {
      return 'No lessons yet';
    }
    if (isComplete) {
      return 'All $lessons $word done';
    }
    if (done == 0) {
      return 'Not started - $lessons $word';
    }
    return '$done of $lessons $word - $percent%';
  }
}
