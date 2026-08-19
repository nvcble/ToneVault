import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../configurations/widgets/configuration_list_view.dart';
import '../../controls/widgets/control_list_view.dart';
import '../../history/widgets/pedal_history_view.dart';
import '../../replacements/data/replacement_choices.dart';
import '../../replacements/providers/replacement_providers.dart';
import '../../replacements/widgets/replace_pedal_sheet.dart';
import '../providers/pedal_editor.dart';
import '../providers/pedal_providers.dart';
import '../widgets/pedal_overview.dart';

/// Everything recorded about one pedal.
///
/// Overview is the pedal itself; Controls is what it can be set to;
/// Configurations are the settings worth keeping; History is what has changed
/// about all three.
class PedalDetailScreen extends ConsumerWidget {
  const PedalDetailScreen({required this.pedalId, super.key});

  final int pedalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pedalValue = ref.watch(pedalProvider(pedalId));
    final pedal = pedalValue.valueOrNull;

    // A pedal leaves the rig once, so the action is gone as soon as it has: the
    // repository refuses a second swap, and offering it anyway is an invitation
    // to be refused.
    final swaps =
        ref.watch(pedalSwapsProvider(pedalId)).valueOrNull ?? const [];
    final isReplaced = retirementOf(pedalId, swaps) != null;

    return DefaultTabController(
      length: 4,
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
                  if (!isReplaced)
                    IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      tooltip: 'Replace',
                      onPressed: () => _openReplaceSheet(context, pedal),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete',
                    onPressed: () => _confirmDelete(context, ref, pedal.name),
                  ),
                ],
          bottom: const TabBar(
            // Four tabs including 'Configurations' will not fit across a phone
            // in portrait, so the bar scrolls rather than squeezing the labels
            // into something unreadable.
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Controls'),
              Tab(text: 'Configurations'),
              Tab(text: 'History'),
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
                    PedalOverview(
                      pedal: pedal,
                      onOpenPedal: (otherId) =>
                          context.go(Routes.pedalDetail(otherId)),
                    ),
                    ControlListView(pedalId: pedalId),
                    ConfigurationListView(pedalId: pedalId),
                    PedalHistoryView(pedalId: pedalId),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _openReplaceSheet(BuildContext context, Pedal pedal) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => ReplacePedalSheet(pedal: pedal),
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
          '$name can only be deleted while nothing has been recorded about it. '
          'Once it has controls, configurations or history, set its status to '
          'Sold or Replaced instead, which keeps all of it.',
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
