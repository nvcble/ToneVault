/// How far the player has got with one lesson.
///
/// A lesson with no progress row is [notStarted]; the value is in the enum all
/// the same, so a screen showing a mixture of lessons has one word for each of
/// them rather than a special case for the ones nothing has been written about.
enum ProgressState {
  notStarted,
  inProgress,
  completed;

  String get label => switch (this) {
    ProgressState.notStarted => 'Not started',
    ProgressState.inProgress => 'In progress',
    ProgressState.completed => 'Done',
  };
}
