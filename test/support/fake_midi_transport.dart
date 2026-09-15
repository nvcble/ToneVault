import 'dart:async';

import 'package:tone_vault/core/midi/midi_connection_failure.dart';
import 'package:tone_vault/core/midi/midi_connection_state.dart';
import 'package:tone_vault/core/midi/midi_endpoint.dart';
import 'package:tone_vault/core/midi/midi_message.dart';
import 'package:tone_vault/core/midi/midi_transport.dart';
import 'package:tone_vault/core/midi/midi_transport_type.dart';

/// A transport with no hardware behind it, so the engine and its providers
/// can be tested without a physical MIDI device.
class FakeMidiTransport implements MidiTransport {
  FakeMidiTransport({
    List<MidiEndpoint> endpoints = const [],
    this.failScan = false,
    this.connectFailure,
  }) : endpoints = List.of(endpoints);

  /// Mutable, so a test can simulate a device being plugged in after [scan]
  /// last ran - see [triggerAvailabilityChange].
  final List<MidiEndpoint> endpoints;
  final bool failScan;

  /// Thrown by [connect] instead of succeeding, when set.
  final MidiConnectionFailure? connectFailure;

  final List<MidiMessage> sent = [];
  final _stateController = StreamController<MidiConnectionState>.broadcast();
  final _incomingController = StreamController<MidiMessage>.broadcast();
  final _availabilityController = StreamController<void>.broadcast();

  MidiConnectionState _currentState = MidiConnectionState.disconnected;
  bool disposed = false;

  @override
  MidiTransportType get type => MidiTransportType.usb;

  @override
  MidiConnectionState get currentState => _currentState;

  @override
  Stream<MidiConnectionState> get connectionState => _stateController.stream;

  @override
  Stream<MidiMessage> get incoming => _incomingController.stream;

  @override
  Stream<void> get availabilityChanged => _availabilityController.stream;

  @override
  Future<List<MidiEndpoint>> scan() async {
    if (failScan) {
      throw StateError('Scan failed.');
    }
    return List.of(endpoints);
  }

  @override
  Future<void> connect(MidiEndpoint endpoint) async {
    setState(MidiConnectionState.connecting);
    final failure = connectFailure;
    if (failure != null) {
      setState(MidiConnectionState.error);
      throw failure;
    }
    setState(MidiConnectionState.connected);
  }

  @override
  Future<void> disconnect() async {
    setState(MidiConnectionState.disconnected);
  }

  @override
  Future<void> send(MidiMessage message) async {
    if (_currentState != MidiConnectionState.connected) {
      throw StateError('Cannot send a MIDI message while disconnected.');
    }
    sent.add(message);
  }

  void setState(MidiConnectionState state) {
    _currentState = state;
    _stateController.add(state);
  }

  /// Delivers [message] as if the device had sent it.
  void receive(MidiMessage message) => _incomingController.add(message);

  /// Simulates a device being plugged or unplugged.
  void triggerAvailabilityChange() => _availabilityController.add(null);

  @override
  void dispose() {
    disposed = true;
    _stateController.close();
    _incomingController.close();
    _availabilityController.close();
  }
}
