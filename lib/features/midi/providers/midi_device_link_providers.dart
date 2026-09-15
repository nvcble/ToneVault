import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/midi_device_link_dao.dart';
import '../../../core/database/daos/midi_patch_program_number_dao.dart';
import '../../../core/database/daos/midi_scene_number_dao.dart';
import '../../../core/database/daos/scene_dao.dart';
import '../../../core/database/database_provider.dart';
import '../../controls/providers/control_providers.dart';
import '../../pedals/providers/pedal_providers.dart';
import '../data/midi_device_link_repository.dart';
import '../data/midi_patch_program_repository.dart';
import '../data/midi_scene_number_repository.dart';
import '../data/midi_scene_send_service.dart';
import 'midi_engine_providers.dart';

final Provider<MidiDeviceLinkDao> midiDeviceLinkDaoProvider = Provider<MidiDeviceLinkDao>(
  (ref) => MidiDeviceLinkDao(ref.watch(appDatabaseProvider)),
);

final Provider<MidiPatchProgramNumberDao> midiPatchProgramNumberDaoProvider =
    Provider<MidiPatchProgramNumberDao>(
      (ref) => MidiPatchProgramNumberDao(ref.watch(appDatabaseProvider)),
    );

final Provider<MidiSceneNumberDao> midiSceneNumberDaoProvider = Provider<MidiSceneNumberDao>(
  (ref) => MidiSceneNumberDao(ref.watch(appDatabaseProvider)),
);

final Provider<MidiDeviceLinkRepository> midiDeviceLinkRepositoryProvider =
    Provider<MidiDeviceLinkRepository>(
      (ref) => MidiDeviceLinkRepository(
        ref.watch(midiDeviceLinkDaoProvider),
        ref.watch(pedalRepositoryProvider),
        ref.watch(controlRepositoryProvider),
      ),
    );

final Provider<MidiPatchProgramRepository> midiPatchProgramRepositoryProvider =
    Provider<MidiPatchProgramRepository>(
      (ref) => MidiPatchProgramRepository(ref.watch(midiPatchProgramNumberDaoProvider)),
    );

final Provider<MidiSceneNumberRepository> midiSceneNumberRepositoryProvider =
    Provider<MidiSceneNumberRepository>(
      (ref) => MidiSceneNumberRepository(ref.watch(midiSceneNumberDaoProvider)),
    );

final Provider<MidiSceneSendService> midiSceneSendServiceProvider = Provider<MidiSceneSendService>(
  (ref) => MidiSceneSendService(SceneDao(ref.watch(appDatabaseProvider)), ref.watch(midiEngineProvider)),
);

/// The pedal linked to one device profile, or null when it has not been
/// added as gear yet.
final StreamProviderFamily<Pedal?, String> linkedPedalProvider = StreamProvider.family<Pedal?, String>(
  (ref, deviceProfileId) =>
      ref.watch(midiDeviceLinkRepositoryProvider).watchLinkedPedal(deviceProfileId),
);

final StreamProviderFamily<MidiPatchProgramNumber?, int> patchProgramNumberProvider =
    StreamProvider.family<MidiPatchProgramNumber?, int>(
      (ref, patchId) => ref.watch(midiPatchProgramRepositoryProvider).watchNumber(patchId),
    );

final StreamProviderFamily<MidiSceneNumber?, int> sceneNumberProvider =
    StreamProvider.family<MidiSceneNumber?, int>(
      (ref, sceneId) => ref.watch(midiSceneNumberRepositoryProvider).watchNumber(sceneId),
    );

/// One unit's numbered patches, in cycling order - what Live Control's
/// Previous/Next read.
final StreamProviderFamily<List<NumberedPatch>, int> numberedPatchesProvider =
    StreamProvider.family<List<NumberedPatch>, int>(
      (ref, pedalId) => ref.watch(midiPatchProgramRepositoryProvider).watchNumberedPatches(pedalId),
    );
