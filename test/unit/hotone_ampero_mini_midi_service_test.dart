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

    test(
      'selecting a patch sends a plain Program Change, no Bank Select',
      () async {
        await service.selectPatch(profile: profile, patchNumber: 5);

        expect(transport.sent, hasLength(1));
        final sent = transport.sent.single as ProgramChangeMessage;
        expect(sent.channel, 0);
        expect(sent.program, 5);
      },
    );

    test('refuses a patch number outside 0-127', () async {
      await expectLater(
        () => service.selectPatch(profile: profile, patchNumber: 128),
        throwsArgumentError,
      );
      expect(transport.sent, isEmpty);
    });
  });
}
