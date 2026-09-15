import '../../../core/midi/midi_connection_state.dart';
import '../../../core/midi/midi_device_profile.dart';
import '../../../core/midi/midi_endpoint.dart';

/// Everything the connection screen needs to draw, gathered in one value so
/// the controller has a single thing to publish.
class MidiConnectionSnapshot {
  const MidiConnectionSnapshot({
    required this.profile,
    required this.state,
    required this.endpoints,
    this.errorMessage,
    this.isBusy = false,
  });

  factory MidiConnectionSnapshot.initial(MidiDeviceProfile profile) =>
      MidiConnectionSnapshot(
        profile: profile,
        state: MidiConnectionState.disconnected,
        endpoints: const [],
      );

  final MidiDeviceProfile profile;
  final MidiConnectionState state;
  final List<MidiEndpoint> endpoints;
  final String? errorMessage;

  /// Whether a scan or connect attempt is in flight - what a progress
  /// indicator reads, so the screen never looks idle while it is actually
  /// waiting on the platform's MIDI plugin.
  final bool isBusy;

  bool get hasDetectedDevice => endpoints.isNotEmpty;

  MidiConnectionSnapshot copyWith({
    MidiConnectionState? state,
    List<MidiEndpoint>? endpoints,
    String? errorMessage,
    bool clearError = false,
    bool? isBusy,
  }) => MidiConnectionSnapshot(
    profile: profile,
    state: state ?? this.state,
    endpoints: endpoints ?? this.endpoints,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    isBusy: isBusy ?? this.isBusy,
  );
}
