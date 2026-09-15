import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/midi_endpoint.dart';
import 'package:tone_vault/core/midi/midi_engine.dart';
import 'package:tone_vault/core/midi/midi_message.dart';
import 'package:tone_vault/core/midi/midi_transport_type.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_profile.dart';
import 'package:tone_vault/features/midi/providers/midi_capture_controller.dart';

import '../support/fake_midi_transport.dart';

const _profile = NuxMg30V5Profile();
const _endpoint = MidiEndpoint(id: 'dev-1', name: 'MG-30', type: MidiTransportType.usb);

void main() {
  test('only records entries logged between start and stop', () async {
    final engine = MidiEngine();
    final transport = FakeMidiTransport(endpoints: const [_endpoint]);
    engine.attach(profile: _profile, transportBuilder: () => transport);
    await engine.connect(_endpoint);
    final controller = MidiCaptureController(engine);

    await engine.send(const ProgramChangeMessage(channel: 0, program: 1));
    expect(controller.state.entries, isEmpty);

    controller.start();
    // The engine's log is a broadcast stream, delivered asynchronously -
    // awaiting the entry itself, the same way `midi_engine_test.dart` does,
    // is what actually guarantees the capture controller's own listener has
    // run by the time the assertion below reads its state.
    var delivered = engine.log.first;
    await engine.send(const ControlChangeMessage(channel: 0, controller: 80, value: 1));
    await delivered;
    expect(controller.state.entries, hasLength(1));

    controller.stop();
    delivered = engine.log.first;
    await engine.send(const ControlChangeMessage(channel: 0, controller: 80, value: 2));
    await delivered;
    expect(controller.state.entries, hasLength(1));
  });

  test('clear empties the buffer without needing another start', () {
    final engine = MidiEngine();
    final controller = MidiCaptureController(engine);
    controller.start();

    controller.clear();

    expect(controller.state.entries, isEmpty);
    expect(controller.state.isCapturing, isTrue);
  });
}
