/// How long the practice was, rounded the way a player would say it.
///
/// This file is the practice a player has put in, in words. Pure, so the wording can
/// be read straight out in a test rather than found on a screen, and nothing here
/// knows what a lesson is: it is handed a count of seconds and a count of sittings and
/// says what they come to.
///
/// Rounded down on purpose. A minute that has not finished has not been practised,
/// and a total that grew because the app rounded up is a total the player did not
/// earn. Anything under a minute is not given a number at all - `0 min` reads as
/// nothing recorded, which is not what a short sitting was.
String formatPracticeTime(int seconds) {
  if (seconds < 60) {
    return 'less than a minute';
  }

  final minutes = seconds ~/ 60;
  if (minutes < 60) {
    return '$minutes min';
  }

  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0 ? '$hours h' : '$hours h $rest min';
}

/// The whole line a lesson shows about its practice: how long, and over how many
/// sittings.
///
/// A total with no sittings behind it is left as the total alone. That is the honest
/// reading for practice recorded before the app kept sittings - saying `over 0
/// sittings` would be the app calling its own record empty, and guessing at a number
/// would be inventing evenings.
String practiceSummary({required int seconds, required int sittings}) {
  final time = formatPracticeTime(seconds);
  return switch (sittings) {
    <= 0 => time,
    1 => '$time in one sitting',
    _ => '$time over $sittings sittings',
  };
}
