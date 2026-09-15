import 'midi_connection_failure.dart';
import 'midi_connection_state.dart';
import 'midi_endpoint.dart';
import 'midi_message.dart';
import 'midi_transport_type.dart';

/// One physical link a [MidiEngine] can send and receive over.
///
/// The engine, the device profiles and every screen above them read a
/// transport only through this contract - never `flutter_midi_command`
/// directly - so the plugin stays isolated to the implementations under
/// `transports/`. A Bluetooth implementation can be added the same way once a
/// device profile actually asks for one.
abstract class MidiTransport {
  MidiTransportType get type;

  MidiConnectionState get currentState;

  Stream<MidiConnectionState> get connectionState;

  /// Messages the connected device has sent, decoded into [MidiMessage].
  Stream<MidiMessage> get incoming;

  /// Fires whenever a device might have appeared or disappeared - a USB
  /// device plugged or unplugged, for instance - so a caller knows to [scan]
  /// again rather than relying on the user to ask.
  Stream<void> get availabilityChanged;

  /// The devices this transport can currently see, before any of them is
  /// connected to.
  Future<List<MidiEndpoint>> scan();

  /// Throws a [MidiConnectionFailure] when the device cannot be reached -
  /// never a raw plugin exception, so nothing above the transport layer needs
  /// to know what plugin is behind it.
  Future<void> connect(MidiEndpoint endpoint);

  Future<void> disconnect();

  /// Sends [message] to whichever device [connect] was last called with.
  ///
  /// Throws a [StateError] when nothing is connected - callers are expected
  /// to check [currentState] first, the same way a repository checks a row
  /// exists before writing to it.
  Future<void> send(MidiMessage message);

  void dispose();
}
