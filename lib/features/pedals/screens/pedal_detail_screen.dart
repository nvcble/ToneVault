import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../configurations/widgets/configuration_list_view.dart';
import '../../controls/widgets/control_list_view.dart';
import '../providers/pedal_editor.dart';
import '../providers/pedal_providers.dart';
import '../widgets/pedal_overview.dart';

/// Everything recorded about one pedal.
///
/// Overview is the pedal itself; Controls is what it can be set to;
/// Configurations are the settings worth keeping. History joins them in a later
/// phase.
class PedalDetailScreen extends ConsumerWidget {
  const PedalDetailScreen({required this.pedalId, super.key});

  final int pedalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pedalValue = ref.watch(pedalProvider(pedalId));
    final pedal = pedalValue.valueOrNull;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(pedal?.name ?? 'Pedal'),
          actions: pedal == null
              ? null
              : [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit',
                    onPressed: () => context.go(Routes.pedalEdit(pedalId)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete',
                    onPressed: () => _confirmDelete(context, ref, pedal.name),
                  ),
                ],
          bottom: const TabBar(
            // 'Configurations' is the widest label the app has; the narrower
            // padding keeps three tabs across a phone in portrait.
            labelPadding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Controls'),
              Tab(text: 'Configurations'),
            ],
          ),
        ),
        body: pedalValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: 'Could not open this pedal',
            message: failureMessage(error),
          ),
          data: (pedal) => pedal == null
              ? const EmptyState(
                  icon: Icons.help_outline,
                  title: 'That pedal no longer exists',
                  message: 'It may have been deleted on another screen.',
                )
              : TabBarView(
                  children: [
                    PedalOverview(pedal: pedal),
                    ControlListView(pedalId: pedalId),
                    ConfigurationListView(pedalId: pedalId),
                  ],
                ),
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
        title: const Text('Delete pedal?'),
        content: Text(
          'This removes $name and everything recorded about it. To keep its '
          'history, set its status to Sold or Replaced instead.',
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
      await ref.read(pedalEditorProvider).delete(pedalId);
      if (context.mounted) {
        context.go(Routes.pedals);
      }
    } catch (error) {
      if (context.mounted) {
        showFailureSnackBar(context, error);
      }
    }
  }
}
