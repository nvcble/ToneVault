import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/database/daos/mg30_patch_payload_dao.dart';
import '../../../../../core/database/database_provider.dart';
import '../../../../patches/providers/patch_providers.dart';
import '../../../../pedals/providers/pedal_providers.dart';
import '../../../providers/midi_device_link_providers.dart';
import '../data/mg30_v5_patch_library_importer.dart';

final Provider<Mg30PatchPayloadDao> mg30PatchPayloadDaoProvider =
    Provider<Mg30PatchPayloadDao>(
      (ref) => Mg30PatchPayloadDao(ref.watch(appDatabaseProvider)),
    );

/// Wired from the repositories the rest of the app already uses, so an imported
/// patch is an ordinary library patch rather than a second kind of patch.
final Provider<Mg30V5PatchLibraryImporter> mg30V5PatchLibraryImporterProvider =
    Provider<Mg30V5PatchLibraryImporter>(
      (ref) => Mg30V5PatchLibraryImporter(
        ref.watch(patchRepositoryProvider),
        ref.watch(sceneRepositoryProvider),
        ref.watch(scenePedalRepositoryProvider),
        ref.watch(sceneValueRepositoryProvider),
        ref.watch(midiPatchProgramRepositoryProvider),
        ref.watch(pedalRepositoryProvider),
        ref.watch(mg30PatchPayloadDaoProvider),
      ),
    );
