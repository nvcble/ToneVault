import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/snapshot_draft.dart';
import '../providers/snapshot_providers.dart';
import '../widgets/snapshot_details_form.dart';

/// Renames a snapshot, rewords its notes, or removes it altogether.
///
/// Deleting lives here rather than on the snapshot's own screen, so reading a
/// snapshot back never puts a delete button under a finger.
class SnapshotEditScreen extends ConsumerStatefulWidget {
  const SnapshotEditScreen({
    required this.pedalboardId,
    required this.snapshotId,
    super.key,
  });

  final int pedalboardId;
  final int snapshotId;

  @override
  ConsumerState<SnapshotEditScreen> createState() => _SnapshotEditScreenState();
}

class _SnapshotEditScreenState extends ConsumerState<SnapshotEditScreen> {
  bool _isSaving = false;

  Future<void> _save(SnapshotDraft draft) async {
    setState(() => _isSaving = true);

    try {
      await ref
          .read(rigSnapshotRepositoryProvider)
          .updateSnapshot(widget.snapshotId, draft);
      if (mounted) {
        context.go(
          Routes.snapshotDetail(widget.pedalboardId, widget.snapshotId),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        showFailureSnackBar(context, error);
      }
    }
  }

  Future<void> _confirmDelete(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete snapshot?'),
        content: Text(
          'The record of how the rig stood for $name goes, along with every '
          'reading under it. The rig and its pedals are untouched.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await ref
          .read(rigSnapshotRepositoryProvider)
          .deleteSnapshot(widget.snapshotId);
      if (mounted) {
        context.go(Routes.rigDetail(widget.pedalboardId));
      }
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshotValue = ref.watch(rigSnapshotProvider(widget.snapshotId));
    final snapshot = snapshotValue.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit snapshot'),
        actions: snapshot == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: _isSaving
                      ? null
                      : () => _confirmDelete(snapshot.name),
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
            : SnapshotDetailsForm(
                // A different snapshot has to start the fields over; the same
                // one keeps whatever is half-typed.
                key: ValueKey<int>(snapshot.id),
                initialDraft: SnapshotDraft.fromSnapshot(snapshot),
                isSaving: _isSaving,
                onSubmit: _save,
              ),
      ),
    );
  }
}
