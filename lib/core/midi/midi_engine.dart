import 'dart:async';

import 'midi_connection_state.dart';
import 'midi_device_profile.dart';
import 'midi_endpoint.dart';
import 'midi_log_entry.dart';
import 'midi_message.dart';
import 'midi_request_failure.dart';
import 'midi_transport.dart';

/// The one place that holds a live device connection.
///
/// Providers read a device only through this: which profile is attached and
/// which transport is carrying it stay here, so a screen never touches
/// `MidiTransport` or `MidiDeviceProfile` implementations directly.
class MidiEngine {
  MidiDeviceProfile? _profile;
  MidiTransport? _transport;
  StreamSubscription<MidiMessage>? _incomingLogSubscription;

  final _logController = StreamController<MidiLogEntry>.broadcast();
  final _history = <MidiLogEntry>[];

  static const _maxHistory = 200;

  MidiDeviceProfile? get profile => _profile;

  MidiConnectionState get currentState =>
      _transport?.currentState ?? MidiConnectionState.disconnected;

  Stream<MidiConnectionState> get connectionState =>
      _transport?.connectionState ?? const Stream<MidiConnectionState>.empty();

  Stream<MidiMessage> get incoming =>
      _transport?.incoming ?? const Stream<MidiMessage>.empty();

  Stream<void> get availabilityChanged =>
      _transport?.availabilityChanged ?? const Stream<void>.empty();

  /// New messages sent or received from this point on, for the MIDI Monitor.
  /// Fires whether or not anything else is currently listening to [incoming].
  ///
  /// [history] is what a monitor reads first, so opening it late still shows
  /// what already happened while the engine was attached but nothing was
  /// watching.
  Stream<MidiLogEntry> get log => _logController.stream;

  /// The most recent messages sent or received, oldest first, capped at
  /// [_maxHistory] - kept by the engine itself rather than by whoever is
  /// watching [log], so it exists whether or not a monitor has ever been
  /// opened.
  List<MidiLogEntry> get history => List.unmodifiable(_history);

  /// Attaches [profile] and the transport [transportBuilder] builds for it.
  ///
  /// A no-op when this profile is already attached with a live transport, so
  /// returning to a connection screen does not tear down and rebuild a
  /// connection that is still there.
  void attach({
    required MidiDeviceProfile profile,
    required MidiTransport Function() transportBuilder,
  }) {
    if (_profile?.id == profile.id && _transport != null) {
      return;
    }
    _incomingLogSubscription?.cancel();
    _transport?.dispose();
    // A previous device's messages are not this one's history.
    _history.clear();
    _profile = profile;
    _transport = transportBuilder();
    _incomingLogSubscription = _transport!.incoming.listen(_logIncoming);
  }

  Future<List<MidiEndpoint>> scan() {
    final transport = _transport;
    if (transport == null) {
      return Future.value(const <MidiEndpoint>[]);
    }
    return transport.scan();
  }

  Future<void> connect(MidiEndpoint endpoint) {
    final transport = _transport;
    if (transport == null) {
      throw StateError('No MIDI transport attached.');
    }
    return transport.connect(endpoint);
  }

  Future<void> disconnect() {
    final transport = _transport;
    if (transport == null) {
      return Future.value();
    }
    return transport.disconnect();
  }

  /// Sends [message], logging the attempt whether or not it got out.
  ///
  /// A refused send used to be logged as nothing at all, so a diagnostic
  /// capture of a failing run looked identical to one where the app had never
  /// tried - see [MidiLogEntry.failure].
  Future<void> send(MidiMessage message) async {
    try {
      final transport = _transport;
      if (transport == null) {
        throw StateError('No MIDI transport attached.');
      }
      await transport.send(message);
      _recordOutgoing(message);
    } catch (error) {
      _recordOutgoing(message, failure: error.toString());
      rethrow;
    }
  }

  /// Sends each message in [messages] in order - a Bank Select ahead of a
  /// Program Change, for instance - stopping at the first one that fails.
  Future<void> sendAll(List<MidiMessage> messages) async {
    for (final message in messages) {
      await send(message);
    }
  }

  /// Sends [message], then waits for the first incoming message [matches]
  /// accepts - a generic request/response pattern (a SysEx query and its
  /// reply, for instance), not specific to any one device profile or
  /// message shape.
  ///
  /// The listener is attached before sending, so a reply that arrives
  /// immediately cannot be missed. Throws [MidiRequestTimedOut] if nothing
  /// matching arrives within [timeout].
  Future<MidiMessage> request(
    MidiMessage message, {
    required bool Function(MidiMessage message) matches,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final response = incoming.firstWhere(matches).timeout(
      timeout,
      onTimeout: () => throw const MidiRequestTimedOut(),
    );
    await send(message);
    return response;
  }

  void _logIncoming(MidiMessage message) {
    _record(
      MidiLogEntry(direction: MidiDirection.incoming, message: message, timestamp: DateTime.now()),
    );
  }

  void _recordOutgoing(MidiMessage message, {String? failure}) {
    _record(
      MidiLogEntry(
        direction: MidiDirection.outgoing,
        message: message,
        timestamp: DateTime.now(),
        failure: failure,
      ),
    );
  }

  void _record(MidiLogEntry entry) {
    _history.add(entry);
    if (_history.length > _maxHistory) {
      _history.removeAt(0);
    }
    _logController.add(entry);
  }

  void dispose() {
    _incomingLogSubscription?.cancel();
    _transport?.dispose();
    _transport = null;
    _profile = null;
    _logController.close();
  }
}
