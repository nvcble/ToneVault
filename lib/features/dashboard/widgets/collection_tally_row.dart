import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/collection_tally.dart';
import 'problem_card.dart';
import 'stat_card.dart';

/// What the collection holds, with a way in to it.
class CollectionTallyRow extends StatelessWidget {
  const CollectionTallyRow({required this.tally, this.onOpenPedals, super.key});

  final AsyncValue<CollectionTally> tally;
  final VoidCallback? onOpenPedals;

  @override
  Widget build(BuildContext context) {
    return tally.when(
      loading: () => const _Counting(),
      // A zero here would read as an empty collection, which is a different
      // thing entirely, so the failure is shown instead of a number.
      error: (error, _) =>
          ProblemCard(title: 'Could not count your gear', error: error),
      data: (tally) => StatCard(
        icon: Icons.tune,
        label: 'Pedals',
        value: '${tally.pedals}',
        detail: describePedals(tally),
        onTap: onOpenPedals,
      ),
    );
  }
}

class _Counting extends StatelessWidget {
  const _Counting();

  @override
  Widget build(BuildContext context) {
    // The height the cards will take, so the rest of the screen does not jump
    // down once the counts arrive.
    return const SizedBox(
      height: 116,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
