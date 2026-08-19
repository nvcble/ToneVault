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
