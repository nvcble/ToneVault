import 'dart:async';

import 'package:flutter_midi_command/flutter_midi_command.dart' as fmc;
import 'package:flutter_midi_command/flutter_midi_command_messages.dart' as fmc;

import '../midi_connection_failure.dart';
import '../midi_connection_state.dart';
import '../midi_endpoint.dart';
import '../midi_message.dart';
import '../midi_transport.dart';
import '../midi_transport_type.dart';
import '../sysex_framing.dart';

/// The only file in the app that imports `flutter_midi_command`.
///
/// Wraps a wired, USB-class-compliant MIDI device - what the plugin reports
/// as [fmc.MidiDeviceType.serial]. Bluetooth and network devices are outside
/// this transport's [scan] on purpose: nothing the app ships asks for them
/// yet.
class UsbMidiTransport implements MidiTransport {
  UsbMidiTransport({fmc.MidiCommand? command})
    : _command = command ?? fmc.MidiCommand();

  final fmc.MidiCommand _command;

  fmc.MidiDevice? _connectedDevice;
  StreamSubscription<fmc.MidiConnectionState>? _deviceStateSubscription;
  StreamSubscription<fmc.MidiDataReceivedEvent>? _dataSubscription;

  final _stateController = StreamController<MidiConnectionState>.broadcast();
  final _incomingController = StreamController<MidiMessage>.broadcast();

  MidiConnectionState _currentState = MidiConnectionState.disconnected;

  @override
  MidiTransportType get type => MidiTransportType.usb;

  @override
  MidiConnectionState get currentState => _currentState;

  @override
  Stream<MidiConnectionState> get connectionState => _stateController.stream;

  @override
  Stream<MidiMessage> get incoming => _incomingController.stream;

  @override
  Stream<void> get availabilityChanged =>
      _command.onMidiSetupChanged?.map((_) {}) ?? const Stream<void>.empty();

  @override
  Future<List<MidiEndpoint>> scan() async {
    final devices = await _command.devices ?? const <fmc.MidiDevice>[];
    return [
      for (final device in devices)
        if (device.type == fmc.MidiDeviceType.serial)
          MidiEndpoint(
            id: device.id,
            name: device.name,
            type: MidiTransportType.usb,
          ),
    ];
  }

  @override
  Future<void> connect(MidiEndpoint endpoint) async {
    _setState(MidiConnectionState.connecting);
    try {
      final devices = await _command.devices ?? const <fmc.MidiDevice>[];
      final device = devices
          .where((candidate) => candidate.id == endpoint.id)
          .firstOrNull;
      if (device == null) {
        throw const MidiDeviceUnavailable();
      }

      await _command.connectToDevice(device);
      _connectedDevice = device;
      _dataSubscription = _command.onMidiDataReceived?.listen(_handleIncoming);
      _deviceStateSubscription = device.onConnectionStateChanged.listen(
        _handleDeviceState,
      );
      _setState(MidiConnectionState.connected);
    } on MidiConnectionFailure {
      _setState(MidiConnectionState.error);
      rethrow;
    } on fmc.MidiConnectionTimeoutException {
      _setState(MidiConnectionState.error);
      throw const MidiConnectionTimedOut();
    } catch (_) {
      _setState(MidiConnectionState.error);
      throw const MidiConnectionRefused();
    }
  }

  @override
  Future<void> disconnect() async {
    final device = _connectedDevice;
    if (device != null) {
      _command.disconnectDevice(device);
    }
    await _deviceStateSubscription?.cancel();
    await _dataSubscription?.cancel();
    _deviceStateSubscription = null;
    _dataSubscription = null;
    _connectedDevice = null;
    _setState(MidiConnectionState.disconnected);
  }

  @override
  Future<void> send(MidiMessage message) async {
    final device = _connectedDevice;
    if (device == null) {
      throw StateError('Cannot send a MIDI message while disconnected.');
    }
    _command.sendData(message.toBytes(), deviceId: device.id);
  }

  void _handleDeviceState(fmc.MidiConnectionState state) {
    switch (state) {
      case fmc.MidiConnectionState.connected:
        _setState(MidiConnectionState.connected);
      case fmc.MidiConnectionState.connecting:
        _setState(MidiConnectionState.connecting);
      case fmc.MidiConnectionState.disconnected:
      case fmc.MidiConnectionState.disconnecting:
        _setState(MidiConnectionState.disconnected);
    }
  }

  void _handleIncoming(fmc.MidiDataReceivedEvent event) {
    final device = _connectedDevice;
    if (device == null || event.device.id != device.id) {
      return;
    }
    _incomingController.add(_translate(event.message));
  }

  /// Every message shape [MidiMessage] itself knows about is decoded into it;
  /// anything else the plugin can parse (pitch bend, aftertouch, clock,
  /// NRPN/RPN) becomes [UnknownMessage] instead of being dropped, so a
  /// diagnostic capture never loses bytes a real device actually sent.
  MidiMessage _translate(fmc.MidiMessage message) {
    return switch (message) {
      fmc.PCMessage m => ProgramChangeMessage(
        channel: m.channel,
        program: m.program,
      ),
      fmc.CCMessage m => ControlChangeMessage(
        channel: m.channel,
        controller: m.controller,
        value: m.value,
      ),
      fmc.NoteOnMessage m => NoteMessage(
        channel: m.channel,
        note: m.note,
        velocity: m.velocity,
        isNoteOn: true,
      ),
      fmc.NoteOffMessage m => NoteMessage(
        channel: m.channel,
        note: m.note,
        velocity: m.velocity,
        isNoteOn: false,
      ),
      // The plugin hands over a whole frame; a payload is what is inside one.
      fmc.SysExMessage m => SysExMessage(
        payload: sysExPayload(m.rawData ?? m.headerData),
      ),
      _ => UnknownMessage(raw: message.data),
    };
  }

  void _setState(MidiConnectionState state) {
    _currentState = state;
    _stateController.add(state);
  }

  @override
  void dispose() {
    _deviceStateSubscription?.cancel();
    _dataSubscription?.cancel();
    _stateController.close();
    _incomingController.close();
  }
}
