import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/midi_patch_favorite_dao.dart';
import '../../../core/database/daos/midi_patch_recent_dao.dart';
import '../../../core/database/database_provider.dart';
import '../data/midi_patch_favorite_repository.dart';
import '../data/midi_patch_recent_repository.dart';

final Provider<MidiPatchFavoriteDao> midiPatchFavoriteDaoProvider =
    Provider<MidiPatchFavoriteDao>(
      (ref) => MidiPatchFavoriteDao(ref.watch(appDatabaseProvider)),
    );

final Provider<MidiPatchRecentDao> midiPatchRecentDaoProvider =
    Provider<MidiPatchRecentDao>(
      (ref) => MidiPatchRecentDao(ref.watch(appDatabaseProvider)),
    );

final Provider<MidiPatchFavoriteRepository>
midiPatchFavoriteRepositoryProvider = Provider<MidiPatchFavoriteRepository>(
  (ref) => MidiPatchFavoriteRepository(ref.watch(midiPatchFavoriteDaoProvider)),
);

final Provider<MidiPatchRecentRepository> midiPatchRecentRepositoryProvider =
    Provider<MidiPatchRecentRepository>(
      (ref) => MidiPatchRecentRepository(ref.watch(midiPatchRecentDaoProvider)),
    );

final StreamProvider<Set<int>> favoritePatchIdsProvider =
    StreamProvider<Set<int>>(
      (ref) => ref
          .watch(midiPatchFavoriteRepositoryProvider)
          .watchFavoritePatchIds(),
    );

final StreamProvider<List<MidiPatchRecent>> patchRecentsProvider =
    StreamProvider<List<MidiPatchRecent>>(
      (ref) => ref.watch(midiPatchRecentRepositoryProvider).watchRecents(),
    );
