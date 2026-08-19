import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/formatting/app_date_format.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/snapshot_providers.dart';
import '../widgets/snapshot_chain_view.dart';

/// One snapshot: the rig as it stood, pedal by pedal.
///
/// Read-only apart from what the snapshot is called and what the notes say. The
/// readings themselves are the record of a day, so there is nothing to tap.
class SnapshotScreen extends ConsumerWidget {
  const SnapshotScreen({
    required this.pedalboardId,
    required this.snapshotId,
    super.key,
  });

  final int pedalboardId;
  final int snapshotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotValue = ref.watch(rigSnapshotProvider(snapshotId));
    final snapshot = snapshotValue.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(snapshot?.name ?? 'Snapshot'),
        actions: snapshot == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Rename',
                  onPressed: () =>
                      context.go(Routes.snapshotEdit(pedalboardId, snapshotId)),
                ),
              ],
      ),
      body: snapshotValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not open this snapshot',
          message: failureMessage(error),
        ),
        data: (snapshot) => snapshot == null
            ? const EmptyState(
                icon: Icons.help_outline,
                title: 'That snapshot no longer exists',
                message: 'It may have been deleted on another screen.',
              )
            : Column(
                children: [
                  _TakenOn(snapshot: snapshot),
                  Expanded(child: SnapshotChainView(snapshotId: snapshotId)),
                ],
              ),
      ),
    );
  }
}

/// When the rig looked like this, and whatever was written about the day.
class _TakenOn extends StatelessWidget {
  const _TakenOn({required this.snapshot});

  final RigSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notes = snapshot.notes;

    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Taken ${formatDateTime(snapshot.capturedAt)}',
            style: theme.textTheme.titleSmall,
          ),
          if (notes != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(notes, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
