import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/daos/change_log_dao.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/change_log_repository.dart';
import 'change_tile.dart';

/// A timeline of changes, newest first.
///
/// Takes the loaded value rather than a provider so the same list serves the
/// collection-wide History tab and one pedal's own history tab, which read from
/// different providers but show the same rows.
class ChangeListView extends StatelessWidget {
  const ChangeListView({
    required this.changes,
    required this.emptyTitle,
    required this.emptyMessage,
    this.showPedalNames = false,
    this.onOpenPedal,
    super.key,
  });

  final AsyncValue<List<PedalChange>> changes;
  final String emptyTitle;
  final String emptyMessage;
  final bool showPedalNames;
  final ValueChanged<int>? onOpenPedal;

  @override
  Widget build(BuildContext context) {
    return changes.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyState(
        icon: Icons.error_outline,
        title: 'Could not load the history',
        message: failureMessage(error),
      ),
      data: (changes) => changes.isEmpty
          ? EmptyState(
              icon: Icons.history,
              title: emptyTitle,
              message: emptyMessage,
            )
          : _Timeline(
              changes: changes,
              showPedalNames: showPedalNames,
              onOpenPedal: onOpenPedal,
            ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.changes,
    required this.showPedalNames,
    required this.onOpenPedal,
  });

  final List<PedalChange> changes;
  final bool showPedalNames;
  final ValueChanged<int>? onOpenPedal;

  @override
  Widget build(BuildContext context) {
    // The query is bounded, so a full page means there is older history the
    // screen is not showing. Saying so beats letting the list look complete.
    final atLimit = changes.length >= historyPageSize;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      itemCount: changes.length + (atLimit ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == changes.length) {
          return const _OlderHistoryNote();
        }

        final change = changes[index];
        final openPedal = onOpenPedal;
        return ChangeTile(
          change: change,
          showPedalName: showPedalNames,
          onTap: openPedal == null
              ? null
              : () => openPedal(change.entry.pedalId),
        );
      },
    );
  }
}

class _OlderHistoryNote extends StatelessWidget {
  const _OlderHistoryNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(
        'Showing the $historyPageSize most recent changes.',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
