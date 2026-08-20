import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/pedal_filter.dart';
import 'pedal_providers.dart';

/// What the pedal list is narrowed to right now.
///
/// Held here rather than in the screen's own state so it survives opening a
/// pedal and coming back, which is exactly what someone working through a long
/// list expects.
final StateProvider<PedalFilter> pedalFilterProvider =
    StateProvider<PedalFilter>((ref) => everyPedal);

/// The inventory with the current filter applied.
///
/// Derived from the same stream the list and the home tally read, so no second
/// query can drift out of step with the first.
final Provider<AsyncValue<PedalSearch>> pedalSearchProvider =
    Provider<AsyncValue<PedalSearch>>((ref) {
      final pedals = ref.watch(pedalListProvider);
      final filter = ref.watch(pedalFilterProvider);
      return pedals.whenData(
        (rows) => searchPedals(pedals: rows, filter: filter),
      );
    });
