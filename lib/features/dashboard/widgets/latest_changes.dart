import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/daos/change_log_dao.dart';
import '../../history/widgets/change_tile.dart';
import 'problem_card.dart';

/// How much of the timeline the home screen shows before handing over to the
/// History tab. Enough to notice something unexpected, not enough to scroll.
const int dashboardChangeCount = 3;

/// The newest entries from the change log, as a taste of the full timeline.
///
/// Reads the same stream the History tab does and takes the top of it, so the
/// two can never disagree about what happened last.
class LatestChanges extends StatelessWidget {
  const LatestChanges({
    required this.changes,
    this.onOpenPedal,
    this.onSeeAll,
    super.key,
  });

  final AsyncValue<List<PedalChange>> changes;
  final ValueChanged<int>? onOpenPedal;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return changes.when(
      loading: () => const SizedBox(
        height: 88,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: ProblemCard(
          title: 'Could not load what changed lately',
          error: error,
        ),
      ),
      data: (changes) => changes.isEmpty
          ? const _NothingYet()
          : _Latest(
              changes: changes,
              onOpenPedal: onOpenPedal,
              onSeeAll: onSeeAll,
            ),
    );
  }
}

class _Latest extends StatelessWidget {
  const _Latest({
    required this.changes,
    required this.onOpenPedal,
    required this.onSeeAll,
  });

  final List<PedalChange> changes;
  final ValueChanged<int>? onOpenPedal;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final openPedal = onOpenPedal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Named, because the home screen mixes every pedal together.
        for (final change in changes.take(dashboardChangeCount))
          ChangeTile(
            change: change,
            showPedalName: true,
            onTap: openPedal == null
                ? null
                : () => openPedal(change.entry.pedalId),
          ),
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: TextButton(
            onPressed: onSeeAll,
            child: const Text('See all history'),
          ),
        ),
      ],
    );
  }
}

class _NothingYet extends StatelessWidget {
  const _NothingYet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Text(
        'Nothing has changed yet. Once you start moving knobs, every change '
        'shows up here with the reason you gave for it.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
