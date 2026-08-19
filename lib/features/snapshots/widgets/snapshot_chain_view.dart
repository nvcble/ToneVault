import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/snapshot_providers.dart';
import 'snapshot_entry_tile.dart';

/// The rig as one snapshot recorded it, in the order signal ran through it.
class SnapshotChainView extends ConsumerWidget {
  const SnapshotChainView({required this.snapshotId, super.key});

  final int snapshotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(snapshotEntriesProvider(snapshotId))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: 'Could not read this snapshot',
            message: failureMessage(error),
          ),
          data: (entries) => entries.isEmpty
              // Capture refuses an empty rig, so this only shows if the rows
              // underneath went missing.
              ? const EmptyState(
                  icon: Icons.linear_scale,
                  title: 'This snapshot has no pedals in it',
                  message: 'There is nothing left to read out of it.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: entries.length,
                  itemBuilder: (context, index) =>
                      SnapshotEntryTile(entry: entries[index]),
                ),
        );
  }
}
