import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/hotone_ampero_mini_patch_dao.dart';
import '../../../../core/database/database_provider.dart';
import '../../providers/midi_engine_providers.dart';
import '../data/hotone_ampero_mini_midi_service.dart';
import '../data/hotone_ampero_mini_patch_repository.dart';

/// Must match `HotoneAmperoMiniProfile().id` - a plain literal rather than a
/// const-getter read, since a getter cannot be evaluated in a const context
/// even on a const instance.
const _deviceProfileId = 'hotone_ampero_mini';

final Provider<HotoneAmperoMiniPatchDao> hotoneAmperoMiniPatchDaoProvider =
    Provider<HotoneAmperoMiniPatchDao>(
      (ref) => HotoneAmperoMiniPatchDao(ref.watch(appDatabaseProvider)),
    );

final Provider<HotoneAmperoMiniPatchRepository>
hotoneAmperoMiniPatchRepositoryProvider =
    Provider<HotoneAmperoMiniPatchRepository>(
      (ref) => HotoneAmperoMiniPatchRepository(
        ref.watch(hotoneAmperoMiniPatchDaoProvider),
        _deviceProfileId,
      ),
    );

final Provider<HotoneAmperoMiniMidiService>
hotoneAmperoMiniMidiServiceProvider = Provider<HotoneAmperoMiniMidiService>(
  (ref) => HotoneAmperoMiniMidiService(ref.watch(midiEngineProvider)),
);

/// Every synchronized patch row for this device, patch number ascending -
/// empty until a sync has actually happened, since nothing seeds placeholder
/// rows.
final StreamProvider<List<HotoneAmperoMiniPatch>>
hotoneAmperoMiniPatchesProvider = StreamProvider<List<HotoneAmperoMiniPatch>>(
  (ref) => ref.watch(hotoneAmperoMiniPatchRepositoryProvider).watchPatches(),
);
