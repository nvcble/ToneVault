import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/midi_connection_state.dart';
import 'package:tone_vault/core/midi/midi_engine.dart';
import 'package:tone_vault/core/midi/midi_message.dart';
import 'package:tone_vault/core/midi/profiles/hotone_ampero_mini/hotone_ampero_mini_profile.dart';
import 'package:tone_vault/features/midi/hotone_ampero_mini/data/hotone_ampero_mini_midi_service.dart';

import '../support/fake_midi_transport.dart';

void main() {
  group('HotoneAmperoMiniMidiService', () {
    const profile = HotoneAmperoMiniProfile();
    late FakeMidiTransport transport;
    late MidiEngine engine;
    late HotoneAmperoMiniMidiService service;

    setUp(() async {
      transport = FakeMidiTransport();
      engine = MidiEngine()
        ..attach(profile: profile, transportBuilder: () => transport);
      transport.setState(MidiConnectionState.connected);
      service = HotoneAmperoMiniMidiService(engine);
    });

    tearDown(() => engine.dispose());

    test('a user patch sends CC0=1 then Program Change = patch', () async {
      await service.selectPatch(profile: profile, patchNumber: 5);

      expect(transport.sent, hasLength(2));
      final bank = transport.sent[0] as ControlChangeMessage;
      expect([bank.controller, bank.value], [0, 1]);
      expect((transport.sent[1] as ProgramChangeMessage).program, 5);
    });

    test('a factory patch sends CC61=20, CC0=0, PC = patch - 99', () async {
      await service.selectPatch(profile: profile, patchNumber: 99);

      expect(transport.sent, hasLength(3));
      final pre = transport.sent[0] as ControlChangeMessage;
      final bank = transport.sent[1] as ControlChangeMessage;
      expect([pre.controller, pre.value], [61, 20]);
      expect([bank.controller, bank.value], [0, 0]);
      expect((transport.sent[2] as ProgramChangeMessage).program, 0);
    });

    test('the last factory patch is PC 98', () async {
      await service.selectPatch(profile: profile, patchNumber: 197);

      expect((transport.sent.last as ProgramChangeMessage).program, 98);
    });

    test('refuses a patch number outside 0-197', () async {
      await expectLater(
        () => service.selectPatch(profile: profile, patchNumber: 198),
        throwsArgumentError,
      );
      expect(transport.sent, isEmpty);
    });
  });
}
