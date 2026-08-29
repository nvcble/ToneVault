import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../pedals/providers/pedal_providers.dart';
import '../data/collection_tally.dart';

/// The home screen's counts, taken from the stream the Pedals tab already
/// watches.
///
/// Nothing new is queried: the pedal list is live for its own tab, so counting
/// it here costs a walk over a list that is already in memory. Counting in a
/// provider rather than in the widget leaves the screen one thing to switch on,
/// and leaves the counting testable on its own.
final Provider<AsyncValue<CollectionTally>> collectionTallyProvider =
    Provider<AsyncValue<CollectionTally>>((ref) {
      final pedals = ref.watch(pedalListProvider);

      return pedals.whenData((rows) => tallyCollection(pedals: rows));
    });
