import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/collection_tally.dart';
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
      error: (error, _) => _CouldNotCount(error: error),
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

class _CouldNotCount extends StatelessWidget {
  const _CouldNotCount({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(width: AppSpacing.md),
            // Said plainly and left on screen: a wrong count is worse than a
            // count that admits it is missing.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Could not count your gear',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(failureMessage(error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
