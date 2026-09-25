/// A [MidiEngine.request] got no matching response in time.
///
/// Distinct from [MidiConnectionFailure]: the link itself is fine, the
/// device simply never sent back anything the caller's matcher accepted -
/// silence, a malformed reply, or a firmware that does not answer this
/// command at all.
class MidiRequestTimedOut implements Exception {
  const MidiRequestTimedOut();

  @override
  String toString() =>
      'MidiRequestTimedOut: no matching response arrived in time.';
}
