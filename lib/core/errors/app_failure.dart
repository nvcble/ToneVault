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

/// Runs [operation], turning anything the database throws into an [AppFailure]
/// saying [message].
///
/// An [AppFailure] already raised passes through untouched: it was phrased by
/// whoever knew the actual problem, and a general message would only bury it.
///
/// Kept for tracking: every repository written before this one carries its own
/// private `_guard` doing exactly this. They are left as they are rather than
/// changed under working, tested code; new repositories call this instead of
/// adding an eleventh copy.
Future<T> guardFailure<T>(
  Future<T> Function() operation,
  String message,
) async {
  try {
    return await operation();
  } on AppFailure {
    rethrow;
  } catch (error) {
    throw AppFailure(message, cause: error);
  }
}
