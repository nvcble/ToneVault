import 'package:flutter/material.dart';

import '../../core/errors/app_failure.dart';

/// Wording for [error], safe to put in front of the user.
///
/// An [AppFailure] was written for them and is shown as-is. Anything else is a
/// bug rather than a rule they broke, so its technical text is withheld.
String failureMessage(Object error) {
  return error is AppFailure
      ? error.message
      : 'Something went wrong. Please try again.';
}

/// Reports [error] in a snack bar.
///
/// Callers pass the error they caught rather than a message, so no screen has
/// to decide for itself what is safe to display.
void showFailureSnackBar(BuildContext context, Object error) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) {
    return;
  }

  messenger
    // A queued snack bar from an earlier attempt would otherwise delay this
    // one until it is stale.
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(failureMessage(error))));
}
