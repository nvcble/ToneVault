/// Date formatting for anything the user reads.
///
/// `yyyy-MM-dd` is unambiguous in every locale and sorts naturally, which is
/// enough for purchase and change dates - so the app needs no `intl`
/// dependency and no locale plumbing.
String formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

/// A date with the time of day, for history entries: a change happens at a
/// moment, and several of them can happen on one afternoon.
///
/// Timestamps are stored in UTC, so they are brought back to the user's own
/// clock here rather than read out as the database holds them.
String formatDateTime(DateTime moment) {
  final local = moment.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${formatDate(local)} $hour:$minute';
}
