/// A problem the user should hear about, phrased for the user.
///
/// Repositories catch driver and database exceptions and rethrow them as an
/// [AppFailure] so no `SqliteException` text ever reaches a snackbar, while
/// [cause] keeps the technical detail available for logging.
class AppFailure implements Exception {
  const AppFailure(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() =>
      cause == null ? 'AppFailure: $message' : 'AppFailure: $message ($cause)';
}
