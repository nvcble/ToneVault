import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/scene_dao.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/midi/midi_endpoint.dart';
import 'package:tone_vault/core/midi/midi_engine.dart';
import 'package:tone_vault/core/midi/midi_message.dart';
import 'package:tone_vault/core/midi/midi_transport_type.dart';
import 'package:tone_vault/core/midi/profiles/nux_mg30_v5/nux_mg30_v5_profile.dart';
import 'package:tone_vault/features/controls/data/control_draft.dart';
import 'package:tone_vault/features/midi/data/midi_scene_send_service.dart';
import 'package:tone_vault/features/patches/data/patch_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';

import '../support/fake_midi_transport.dart';
import '../support/repositories.dart';

const _profile = NuxMg30V5Profile();
const _endpoint = MidiEndpoint(
  id: 'dev-1',
  name: 'MG-30',
  type: MidiTransportType.usb,
);

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test(
    'sends only the scene values that resolve to a real MIDI parameter',
    () async {
      final unitId = await pedalRepository(database).createPedal(
        PedalDraft(
          name: _profile.displayName,
          type: PedalType.digital,
          category: PedalCategory.multiEffects,
        ),
      );
      final ampId = await pedalRepository(database).createPedal(
        PedalDraft(
          name: 'Amp',
          type: PedalType.digital,
          category: PedalCategory.other,
        ).insideUnit(unitId),
      );
      final knobControlId = await controlRepository(database).createControl(
        ampId,
        const ControlDraft(
          name: 'Amp Knob 1',
          type: ControlType.percentage,
          minValue: 0,
          maxValue: 100,
        ),
      );
      final unrelatedControlId = await controlRepository(database)
          .createControl(
            ampId,
            const ControlDraft(
              name: 'Not a MIDI thing',
              type: ControlType.percentage,
              minValue: 0,
              maxValue: 100,
            ),
          );

      final patchId = await patchRepository(
        database,
      ).createPatch(unitId, const PatchDraft(name: 'Test'));
      final sceneId = await sceneRepository(
        database,
      ).createScene(patchId, const SceneDraft(name: 'Verse'));
      await scenePedalRepository(
        database,
      ).addPedal(sceneId: sceneId, pedalId: ampId);
      await sceneValueRepository(
        database,
      ).setValue(sceneId: sceneId, controlId: knobControlId, value: 42);
      await sceneValueRepository(
        database,
      ).setValue(sceneId: sceneId, controlId: unrelatedControlId, value: 10);

      final engine = MidiEngine();
      final transport = FakeMidiTransport(endpoints: const [_endpoint]);
      engine.attach(profile: _profile, transportBuilder: () => transport);
      await engine.connect(_endpoint);

      final service = MidiSceneSendService(SceneDao(database), engine);
      final sent = await service.sendSceneValues(
        profile: _profile,
        effectiveParameters: _profile.parameterDefinitions,
        sceneId: sceneId,
      );

      expect(sent, 1);
      final message = transport.sent.single as ControlChangeMessage;
      // "Amp Knob 1" is CC 24 per the V5 chart.
      expect(message.controller, 24);
      expect(message.value, 42);
    },
  );

  test('sends nothing for a scene with no MIDI-mapped controls', () async {
    final unitId = await pedalRepository(database).createPedal(
      PedalDraft(
        name: _profile.displayName,
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
      ),
    );
    final patchId = await patchRepository(
      database,
    ).createPatch(unitId, const PatchDraft(name: 'Test'));
    final sceneId = await sceneRepository(
      database,
    ).createScene(patchId, const SceneDraft(name: 'Verse'));

    final engine = MidiEngine();
    final transport = FakeMidiTransport(endpoints: const [_endpoint]);
    engine.attach(profile: _profile, transportBuilder: () => transport);
    await engine.connect(_endpoint);

    final service = MidiSceneSendService(SceneDao(database), engine);
    final sent = await service.sendSceneValues(
      profile: _profile,
      effectiveParameters: _profile.parameterDefinitions,
      sceneId: sceneId,
    );

    expect(sent, 0);
    expect(transport.sent, isEmpty);
  });
}
