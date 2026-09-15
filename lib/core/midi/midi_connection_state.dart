/// Where a [MidiTransport] stands with whatever device it was asked to reach.
///
/// A type of its own rather than the MIDI plugin's: this is what every
/// provider and screen above the transport layer reads, so swapping the
/// plugin behind `transports/` never touches them.
enum MidiConnectionState {
  disconnected,
  connecting,
  connected,
  error;

  String get label => switch (this) {
    MidiConnectionState.disconnected => 'Disconnected',
    MidiConnectionState.connecting => 'Connecting…',
    MidiConnectionState.connected => 'Connected',
    MidiConnectionState.error => 'Connection failed',
  };
}
