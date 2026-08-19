import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/pedalboard_providers.dart';
import '../providers/rig_editor.dart';
import '../widgets/rig_chain_view.dart';
import '../widgets/rig_overview.dart';

/// One rig: what it is, and what is on it.
class RigScreen extends ConsumerWidget {
  const RigScreen({required this.pedalboardId, super.key});

  final int pedalboardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pedalboardValue = ref.watch(pedalboardProvider(pedalboardId));
    final pedalboard = pedalboardValue.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(pedalboard?.name ?? 'Rig'),
        actions: pedalboard == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: () => context.go(Routes.rigEdit(pedalboardId)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: () =>
                      _confirmDelete(context, ref, pedalboard.name),
                ),
              ],
      ),
      body: pedalboardValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not open this rig',
          message: failureMessage(error),
        ),
        data: (pedalboard) => pedalboard == null
            ? const EmptyState(
                icon: Icons.help_outline,
                title: 'That rig no longer exists',
                message: 'It may have been deleted on another screen.',
              )
            : Column(
                children: [
                  RigOverview(pedalboard: pedalboard),
                  const Divider(height: 1),
                  Expanded(child: RigChainView(pedalboardId: pedalboardId)),
                ],
              ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete rig?'),
        content: Text(
          '$name goes, along with the order of the pedals on it. The pedals '
          'themselves are not touched.',
        ),
        actions: [
          TextButton(
            // Dialogs are Navigator routes rather than go_router pages, so they
            // are dismissed through the Navigator.
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

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(rigEditorProvider).delete(pedalboardId);
      if (context.mounted) {
        context.go(Routes.rigs);
      }
    } catch (error) {
      if (context.mounted) {
        showFailureSnackBar(context, error);
      }
    }
  }
}
