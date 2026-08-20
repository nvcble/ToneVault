import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/collection_tally.dart';
import 'problem_card.dart';
import 'stat_card.dart';

/// What the collection holds, side by side, each card opening its own tab.
class CollectionTallyRow extends StatelessWidget {
  const CollectionTallyRow({
    required this.tally,
    this.onOpenPedals,
    this.onOpenRigs,
    super.key,
  });

  final AsyncValue<CollectionTally> tally;
  final VoidCallback? onOpenPedals;
  final VoidCallback? onOpenRigs;

  @override
  Widget build(BuildContext context) {
    return tally.when(
      loading: () => const _Counting(),
      // A zero here would read as an empty collection, which is a different
      // thing entirely, so the failure is shown instead of a number.
      error: (error, _) =>
          ProblemCard(title: 'Could not count your gear', error: error),
      // Stretched to the taller card, so the pair sits flush however long the
      // lines under the numbers turn out to be. A Row cannot stretch inside a
      // list on its own: it has no height to stretch to until this measures one.
      data: (tally) => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.tune,
                label: 'Pedals',
                value: '${tally.pedals}',
                detail: describePedals(tally),
                onTap: onOpenPedals,
              ),
            ),
            Expanded(
              child: StatCard(
                icon: Icons.dashboard_outlined,
                label: 'Rigs',
                value: '${tally.rigs}',
                detail: describeRigs(tally),
                onTap: onOpenRigs,
              ),
            ),
          ],
        ),
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
