import '../../../core/enums/signal_block_type.dart';
import '../../../core/enums/signal_destination.dart';
import '../../../core/enums/signal_source.dart';
import 'signal_endpoint_draft.dart';

/// Validation rules for what one edge of a rig reaches.
///
/// Each rule is a `String?` function returning the problem or null, so the same
/// code backs both the form's own validator and the repository's guard. None of it
/// depends on Flutter.
abstract final class SignalEndpointValidator {
  /// Mirrors the length limit declared on `signal_endpoints.gear`.
  static const int gearMaxLength = 120;

  /// What is at the other end is optional, because 'Front of house' is already a
  /// complete answer on most nights. It is only asked for when the user has said
  /// the destination is something the app has no name for.
  static String? gear(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.length > gearMaxLength) {
      return 'Use at most $gearMaxLength characters.';
    }
    return null;
  }

  /// Whether a block of [type] can be described at all, and whether [draft]
  /// describes it the right way round.
  ///
  /// The direction is the rule that matters. A send and an output both let signal
  /// out and take a destination; an input and a return both take signal in and
  /// name a source. A row holding both would be a block claiming to be two ends of
  /// the same cable.
  static String? draft(SignalEndpointDraft draft, SignalBlockType type) {
    if (!type.isBoundary) {
      return 'Only an input, output, send or return says where signal comes '
          'from or goes to.';
    }
    if (type.carriesDestination) {
      if (draft.source != null) {
        return '${type.label} is where signal leaves, so it needs somewhere to '
            'go rather than somewhere to come from.';
      }
      if (draft.destination == null) return 'Say where this goes.';
    }
    if (type.carriesSource) {
      if (draft.destination != null) {
        return '${type.label} is where signal arrives, so it needs somewhere to '
            'come from rather than somewhere to go.';
      }
      if (draft.source == null) return 'Say where this comes from.';
    }
    if (_needsGear(draft) && (draft.gear?.trim().isEmpty ?? true)) {
      return 'Say what this is, since the app has no name for it.';
    }
    return gear(draft.gear);
  }

  /// 'Something else' says only that the app's own list did not cover it, so the
  /// user's own words are the whole answer and are asked for rather than optional.
  static bool _needsGear(SignalEndpointDraft draft) =>
      draft.destination == SignalDestination.custom ||
      draft.source == SignalSource.custom;
}
