import 'midi_transport_type.dart';

/// One physical MIDI device a transport can see, before anything is known
/// about which device profile it might be running.
class MidiEndpoint {
  const MidiEndpoint({
    required this.id,
    required this.name,
    required this.type,
  });

  /// However the underlying transport names this device. Opaque to
  /// everything above the transport layer - passed back to it unchanged to
  /// connect.
  final String id;

  final String name;
  final MidiTransportType type;
}
