/// The reasons this app declines to send a patch selection, worded for the
/// user.
///
/// They live beside the layout constants rather than in the screen because
/// each quotes a protocol fact, and the wording has to keep matching the fact:
/// each says *why* it cannot be done, not just that it failed.
///
/// A factory patch no longer refuses here. It used to, with wording that said
/// it "has to be chosen on the pedal itself" - which claimed more than is
/// known, since all that was observed is that a plain Program Change did not
/// move the pedal. Double-tapping one now offers the experimental Bank Select
/// attempts instead.
library;

import '../../../../core/errors/app_failure.dart';

const AppFailure amperoMiniNotConnectedFailure = AppFailure(
  'Connect to the Ampero Mini before selecting a patch.',
);
