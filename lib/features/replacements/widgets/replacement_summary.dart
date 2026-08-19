import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/daos/pedal_replacement_dao.dart';
import '../../../shared/formatting/app_date_format.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/replacement_choices.dart';
import '../providers/replacement_providers.dart';

/// How this pedal relates to the ones it replaced, or to the one that replaced
/// it.
///
/// Nothing at all when the pedal has never been part of a swap, so an ordinary
/// pedal's overview is not padded out with an empty section.
class ReplacementSummary extends ConsumerWidget {
  const ReplacementSummary({
    required this.pedalId,
    this.onOpenPedal,
    super.key,
  });

  final int pedalId;

  /// Given the other pedal in the swap, so the two are one tap apart.
  final ValueChanged<int>? onOpenPedal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(pedalSwapsProvider(pedalId))
        .when(
          loading: () => const SizedBox.shrink(),
          // Quiet, but not silent: this sits under the pedal's own details, and a
          // swap that cannot be read is not the same as a pedal with no swaps.
          error: (error, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              failureMessage(error),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          data: (swaps) => _buildSwaps(swaps),
        );
  }

  Widget _buildSwaps(List<PedalSwap> swaps) {
    final retirement = retirementOf(pedalId, swaps);
    final takeovers = takeoversBy(pedalId, swaps);
    if (retirement == null && takeovers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        children: [
          if (retirement != null)
            _SwapRow(
              icon: Icons.swap_horiz,
              headline: 'Replaced by ${retirement.incoming.name}',
              swap: retirement,
              onTap: _tapFor(retirement.incoming.id),
            ),
          for (final takeover in takeovers)
            _SwapRow(
              icon: Icons.history,
              headline: 'Took over from ${takeover.outgoing.name}',
              swap: takeover,
              onTap: _tapFor(takeover.outgoing.id),
            ),
        ],
      ),
    );
  }

  VoidCallback? _tapFor(int otherPedalId) {
    final open = onOpenPedal;
    return open == null ? null : () => open(otherPedalId);
  }
}

class _SwapRow extends StatelessWidget {
  const _SwapRow({
    required this.icon,
    required this.headline,
    required this.swap,
    this.onTap,
  });

  final IconData icon;
  final String headline;
  final PedalSwap swap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final reason = swap.replacement.reason;

    return ListTile(
      leading: Icon(icon),
      title: Text(headline),
      // The date is what a swap always has; the reason is the user's own and
      // only shown when they gave one.
      subtitle: Text(
        [formatDate(swap.replacement.replacedAt), ?reason].join(' · '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}
