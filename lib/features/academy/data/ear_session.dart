import 'ear_drill.dart';
import 'ear_question.dart';

/// A drill being worked through: the question on screen, what was answered, and how
/// the sitting has gone so far.
///
/// The score is not written to the database. A run at a drill is a sitting rather than
/// an achievement - a player does twenty of them while waiting for a kettle - and
/// keeping a table of guesses would turn practice into a record to be ashamed of.
/// Lesson progress is the thing worth remembering, and that is already kept.
class EarSession {
  const EarSession({
    required this.drill,
    required this.question,
    required this.asked,
    required this.right,
    this.chosen,
  });

  final EarDrill drill;
  final EarQuestion question;

  /// Which choice was tapped, or null while the question is still open.
  final int? chosen;

  /// How many questions this sitting has put up, this one included.
  final int asked;
  final int right;

  bool get answered => chosen != null;

  bool get wasRight => chosen != null && question.isCorrect(chosen!);

  /// `3 of 4`, which is a score a player can read at a glance without arithmetic.
  String get score => '$right of ${answered ? asked : asked - 1}';

  EarSession answering(int choice) => EarSession(
    drill: drill,
    question: question,
    chosen: choice,
    asked: asked,
    right: right + (question.isCorrect(choice) ? 1 : 0),
  );

  EarSession asking(EarQuestion next) =>
      EarSession(drill: drill, question: next, asked: asked + 1, right: right);
}
