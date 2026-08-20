import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../pedalboards/providers/pedalboard_providers.dart';
import '../../pedals/providers/pedal_providers.dart';
import '../data/collection_tally.dart';

/// The home screen's counts, taken from the streams the tabs already watch.
///
/// Nothing new is queried: the pedal and rig lists are live for their own tabs,
/// so counting them here costs a walk over two lists that are already in memory.
/// Combining them in a provider rather than in the widget leaves the screen one
/// thing to switch on, and leaves the counting testable on its own.
final Provider<AsyncValue<CollectionTally>> collectionTallyProvider =
    Provider<AsyncValue<CollectionTally>>((ref) {
      final pedals = ref.watch(pedalListProvider);
      final rigs = ref.watch(pedalboardListProvider);

      // Either list failing makes the whole tally wrong, so the failure is
      // passed on rather than counted as nothing.
      final failure = pedals.error ?? rigs.error;
      if (failure != null) {
        return AsyncValue.error(
          failure,
          pedals.stackTrace ?? rigs.stackTrace ?? StackTrace.current,
        );
      }

      final pedalRows = pedals.valueOrNull;
      final rigRows = rigs.valueOrNull;
      if (pedalRows == null || rigRows == null) {
        return const AsyncValue.loading();
      }

      return AsyncValue.data(tallyCollection(pedals: pedalRows, rigs: rigRows));
    });
