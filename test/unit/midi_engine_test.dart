import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/midi_block_definition.dart';
import 'package:tone_vault/core/midi/midi_connection_state.dart';
import 'package:tone_vault/core/midi/midi_device_profile.dart';
import 'package:tone_vault/core/midi/midi_endpoint.dart';
import 'package:tone_vault/core/midi/midi_engine.dart';
import 'package:tone_vault/core/midi/midi_feature.dart';
import 'package:tone_vault/core/midi/midi_log_entry.dart';
import 'package:tone_vault/core/midi/midi_message.dart';
import 'package:tone_vault/core/midi/midi_parameter_definition.dart';
import 'package:tone_vault/core/midi/midi_support_level.dart';
import 'package:tone_vault/core/midi/midi_transport_type.dart';
import 'package:tone_vault/core/midi/patch_selection_defaults.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_profile.dart';

import '../support/fake_midi_transport.dart';

const _profile = NuxMg30V5Profile();
const _endpoint = MidiEndpoint(id: 'dev-1', name: 'MG-30', type: MidiTransportType.usb);

/// A second, unrelated device profile - just enough to prove history does
/// not leak from one device to another.
class _OtherProfile extends MidiDeviceProfile {
  const _OtherProfile();

  @override
  String get id => 'other';
  @override
  String get manufacturer => 'Other';
  @override
  String get model => 'Other';
  @override
  String get firmwareVersion => '1';
  @override
  String get displayName => 'Other';
  @override
  List<MidiTransportType> get connectionTypes => const [MidiTransportType.usb];
  @override
  int get defaultChannel => 0;
  @override
  Map<MidiFeature, MidiSupportLevel> get capabilities => const {};
  @override
  List<MidiParameterDefinition> get parameterDefinitions => const [];
  @override
  List<MidiBlockDefinition> get blockDefinitions => const [];
  @override
  PatchSelectionDefaults? get patchSelectionDefaults => null;
}

void main() {
  test('has nothing attached and reports disconnected before attach', () async {
    final engine = MidiEngine();

    expect(engine.profile, isNull);
    expect(engine.currentState, MidiConnectionState.disconnected);
    expect(await engine.scan(), isEmpty);
  });

  test('send and connect throw before a transport is attached', () async {
    final engine = MidiEngine();

    expect(
      () => engine.connect(_endpoint),
      throwsA(isA<StateError>()),
    );
    expect(
      () => engine.send(const ProgramChangeMessage(channel: 0, program: 0)),
      throwsA(isA<StateError>()),
    );
  });

  test('attach reuses the existing transport for the same profile', () {
    final engine = MidiEngine();
    var buildCount = 0;
    FakeMidiTransport build() {
      buildCount++;
      return FakeMidiTransport();
    }

    engine.attach(profile: _profile, transportBuilder: build);
    engine.attach(profile: _profile, transportBuilder: build);

    expect(buildCount, 1);
  });

  test('scan, connect and disconnect delegate to the attached transport', () async {
    final engine = MidiEngine();
    final transport = FakeMidiTransport(endpoints: const [_endpoint]);
    engine.attach(profile: _profile, transportBuilder: () => transport);

    expect(await engine.scan(), [_endpoint]);

    await engine.connect(_endpoint);
    expect(engine.currentState, MidiConnectionState.connected);

    await engine.disconnect();
    expect(engine.currentState, MidiConnectionState.disconnected);
  });

  test('availabilityChanged is empty before attach and forwards the transport\'s after', () async {
    final engine = MidiEngine();
    expect(await engine.availabilityChanged.isEmpty, isTrue);

    final transport = FakeMidiTransport();
    engine.attach(profile: _profile, transportBuilder: () => transport);

    final fired = engine.availabilityChanged.first;
    transport.triggerAvailabilityChange();

    await fired;
  });

  test('send logs the message as outgoing', () async {
    final engine = MidiEngine();
    final transport = FakeMidiTransport(endpoints: const [_endpoint]);
    engine.attach(profile: _profile, transportBuilder: () => transport);
    await engine.connect(_endpoint);

    final logged = engine.log.first;
    const message = ControlChangeMessage(channel: 0, controller: 80, value: 1);
    await engine.send(message);

    final entry = await logged;
    expect(entry.direction, MidiDirection.outgoing);
    expect(entry.message, same(message));
    expect(transport.sent, [message]);
  });

  test('logs a message the transport reports as incoming', () async {
    final engine = MidiEngine();
    final transport = FakeMidiTransport();
    engine.attach(profile: _profile, transportBuilder: () => transport);

    final logged = engine.log.first;
    const message = ProgramChangeMessage(channel: 0, program: 4);
    transport.receive(message);

    final entry = await logged;
    expect(entry.direction, MidiDirection.incoming);
    expect(entry.message, same(message));
  });

  test('sendAll sends every message in order', () async {
    final engine = MidiEngine();
    final transport = FakeMidiTransport(endpoints: const [_endpoint]);
    engine.attach(profile: _profile, transportBuilder: () => transport);
    await engine.connect(_endpoint);

    const bankSelect = ControlChangeMessage(channel: 0, controller: 0, value: 0);
    const programChange = ProgramChangeMessage(channel: 0, program: 5);
    await engine.sendAll([bankSelect, programChange]);

    expect(transport.sent, [bankSelect, programChange]);
  });

  test('history holds what happened before anything was watching log', () async {
    final engine = MidiEngine();
    final transport = FakeMidiTransport(endpoints: const [_endpoint]);
    engine.attach(profile: _profile, transportBuilder: () => transport);
    await engine.connect(_endpoint);

    const message = ControlChangeMessage(channel: 0, controller: 80, value: 1);
    await engine.send(message);

    // No listener on `log` was ever attached - `history` is what a Monitor
    // opened only now would read.
    expect(engine.history, [
      isA<MidiLogEntry>()
          .having((entry) => entry.direction, 'direction', MidiDirection.outgoing)
          .having((entry) => entry.message, 'message', same(message)),
    ]);
  });

  test('history is capped rather than growing without bound', () async {
    final engine = MidiEngine();
    final transport = FakeMidiTransport(endpoints: const [_endpoint]);
    engine.attach(profile: _profile, transportBuilder: () => transport);
    await engine.connect(_endpoint);

    for (var value = 0; value < 210; value++) {
      await engine.send(ControlChangeMessage(channel: 0, controller: 80, value: value % 128));
    }

    expect(engine.history, hasLength(200));
    final last = engine.history.last.message as ControlChangeMessage;
    expect(last.value, 209 % 128);
  });

  test('attaching a different device profile clears the previous one\'s history', () async {
    final engine = MidiEngine();
    final transport = FakeMidiTransport(endpoints: const [_endpoint]);
    engine.attach(profile: _profile, transportBuilder: () => transport);
    await engine.connect(_endpoint);
    await engine.send(const ControlChangeMessage(channel: 0, controller: 80, value: 1));
    expect(engine.history, isNotEmpty);

    engine.attach(profile: const _OtherProfile(), transportBuilder: FakeMidiTransport.new);

    expect(engine.history, isEmpty);
  });

  test('dispose tears down the attached transport', () {
    final engine = MidiEngine();
    final transport = FakeMidiTransport();
    engine.attach(profile: _profile, transportBuilder: () => transport);

    engine.dispose();

    expect(transport.disposed, isTrue);
    expect(engine.profile, isNull);
  });
}
