import '../../../core/enums/signal_destination.dart';
import '../../../core/enums/signal_source.dart';

/// What the user has said one edge of a rig reaches, before it is saved.
///
/// Both [destination] and [source] are here because one form asks about either -
/// which of the two applies is decided by the block's type, not by the form - and
/// `SignalEndpointValidator` is what refuses a draft holding both.
class SignalEndpointDraft {
  const SignalEndpointDraft({
    this.destination,
    this.source,
    this.gear,
    this.notes,
  });

  final SignalDestination? destination;
  final SignalSource? source;

  /// What is at the other end, in the user's own words.
  final String? gear;

  final String? notes;

  SignalEndpointDraft copyWith({
    SignalDestination? destination,
    SignalSource? source,
    String? gear,
    String? notes,
  }) {
    return SignalEndpointDraft(
      destination: destination ?? this.destination,
      source: source ?? this.source,
      gear: gear ?? this.gear,
      notes: notes ?? this.notes,
    );
  }

  /// Whitespace trimmed and blank text read as nothing said, so a field the user
  /// typed into and cleared again is stored the same as one they never touched.
  SignalEndpointDraft normalized() => SignalEndpointDraft(
    destination: destination,
    source: source,
    gear: _tidy(gear),
    notes: _tidy(notes),
  );

  static String? _tidy(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
