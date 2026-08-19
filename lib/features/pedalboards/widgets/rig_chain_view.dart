import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/pedalboard_providers.dart';
import 'add_pedal_sheet.dart';
import 'reorderable_chain_list.dart';

/// What is on a rig, in the order signal reaches it.
///
/// The only part of the chain that knows about the repository: the list below is
/// handed callbacks so a drag can be tested without a database.
class RigChainView extends ConsumerWidget {
  const RigChainView({required this.pedalboardId, super.key});

  final int pedalboardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chain = ref.watch(rigChainProvider(pedalboardId));

    return Column(
      children: [
        Expanded(
          child: chain.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load the chain',
              message: failureMessage(error),
            ),
            data: (chain) => chain.isEmpty
                ? const EmptyState(
                    icon: Icons.linear_scale,
                    title: 'Nothing on this rig yet',
                    message:
                        'Add pedals in the order signal reaches them, from '
                        'your guitar through to your amp.',
                  )
                : ReorderableChainList(
                    chain: chain,
                    onReorder: (slotIds) => ref
                        .read(rigChainRepositoryProvider)
                        .reorderChain(pedalboardId, slotIds),
                    onRemove: (slotId) => ref
                        .read(rigChainRepositoryProvider)
                        .removePedal(slotId),
                    onOpenPedal: (pedalId) =>
                        context.go(Routes.pedalDetail(pedalId)),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openAddSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Add pedal'),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openAddSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => AddPedalSheet(pedalboardId: pedalboardId),
    );
  }
}
