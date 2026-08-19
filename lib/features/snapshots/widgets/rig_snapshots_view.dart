import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../pedalboards/providers/pedalboard_providers.dart';
import '../providers/snapshot_providers.dart';
import 'snapshot_card.dart';

/// Every snapshot taken of one rig, newest first.
///
/// Capture is offered here rather than as an app bar action, next to the list it
/// adds to - and only while there is something on the rig to record, since the
/// repository refuses an empty one.
class RigSnapshotsView extends ConsumerWidget {
  const RigSnapshotsView({required this.pedalboardId, super.key});

  final int pedalboardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshots = ref.watch(rigSnapshotsProvider(pedalboardId));
    final chain = ref.watch(rigChainProvider(pedalboardId)).valueOrNull;
    final rigIsEmpty = chain != null && chain.isEmpty;

    return Column(
      children: [
        Expanded(
          child: snapshots.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load the snapshots',
              message: failureMessage(error),
            ),
            data: (snapshots) => snapshots.isEmpty
                ? EmptyState(
                    icon: Icons.photo_camera_outlined,
                    title: 'No snapshots of this rig yet',
                    message: rigIsEmpty
                        ? 'Build the chain first. A snapshot then records where '
                              'every pedal on it was set.'
                        : 'Take one to keep where every pedal was set on the '
                              'day you played it.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: snapshots.length,
                    itemBuilder: (context, index) =>
                        SnapshotCard(snapshot: snapshots[index]),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: rigIsEmpty
                  ? null
                  : () => context.go(Routes.snapshotNew(pedalboardId)),
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Take a snapshot'),
            ),
          ),
        ),
      ],
    );
  }
}
