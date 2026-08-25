import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/database/daos/signal_chain_dao.dart';
import '../../../core/enums/signal_block_type.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/chain_endpoints.dart';
import '../data/chain_routing.dart';
import '../data/endpoint_summary.dart';
import '../providers/pedalboard_providers.dart';
import 'add_block_sheet.dart';
import 'assign_pedal_sheet.dart';
import 'block_cables_sheet.dart';
import 'block_endpoint_sheet.dart';
import 'routing_advice_panel.dart';
import 'send_pair_sheet.dart';
import 'signal_block_menu.dart';
import 'signal_chain_canvas.dart';

/// A rig's signal chain: what is on it, in the order signal reaches it.
///
/// The only part of the chain that knows about the repository. The canvas below
/// is handed a callback so a drag can be tested without a database, and every
/// action a block offers is carried out from here.
class SignalChainView extends ConsumerWidget {
  const SignalChainView({required this.pedalboardId, super.key});

  final int pedalboardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chain = ref.watch(signalChainProvider(pedalboardId));
    final routing =
        ref.watch(signalRoutingProvider(pedalboardId)).valueOrNull ??
        ChainRouting.none;
    final endpoints =
        ref.watch(signalEndpointsProvider(pedalboardId)).valueOrNull ??
        ChainEndpoints.none;

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
                        'Add blocks in the order signal reaches them, from your '
                        'guitar through to wherever the rig ends up. A block '
                        'can wait empty until you own the pedal for it.',
                  )
                : SignalChainCanvas(
                    chain: chain,
                    routing: routing,
                    edges: endpointSummaries(
                      chain: chain,
                      endpoints: endpoints,
                    ),
                    onReorder: (blockIds) => ref
                        .read(signalChainRepositoryProvider)
                        .reorderChain(pedalboardId, blockIds),
                    onOpenBlock: (entry) => _openBlock(context, ref, entry),
                    onAddEnd: (blockType) => _addEnd(context, ref, blockType),
                  ),
          ),
        ),
        RoutingAdvicePanel(
          notes: ref.watch(routingAdviceProvider(pedalboardId)),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                builder: (sheetContext) =>
                    AddBlockSheet(pedalboardId: pedalboardId),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add block'),
            ),
          ),
        ),
      ],
    );
  }

  /// Turns a drawn end of the chain into a block of the rig's own.
  ///
  /// Only then is there something to ask where signal comes from or goes to, so
  /// the sheet is offered straight away rather than leaving the user to find it
  /// on a block that has just appeared.
  Future<void> _addEnd(
    BuildContext context,
    WidgetRef ref,
    SignalBlockType blockType,
  ) async {
    final repository = ref.read(signalChainRepositoryProvider);
    int? blockId;

    await _run(context, () async {
      blockId = await repository.addBlock(
        pedalboardId: pedalboardId,
        blockType: blockType,
        atStart: blockType == SignalBlockType.input,
      );
    });
    if (blockId == null || !context.mounted) return;

    final block = await repository.findBlock(blockId!);
    if (block == null || !context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => BlockEndpointSheet(block: block),
    );
  }

  /// Offers what can be done with a block, then does it.
  Future<void> _openBlock(
    BuildContext context,
    WidgetRef ref,
    ChainBlock entry,
  ) async {
    final action = await showSignalBlockMenu(context, entry);
    if (action == null || !context.mounted) return;

    switch (action) {
      case SignalBlockAction.viewSettings:
        // The pedal's own screen, which is where its controls, configurations
        // and history already are. A rig does not keep a second copy of them.
        final pedal = entry.pedal;
        if (pedal != null) context.go(Routes.pedalDetail(pedal.id));
      case SignalBlockAction.assignPedal:
        await showModalBottomSheet<void>(
          context: context,
          builder: (sheetContext) => AssignPedalSheet(block: entry.block),
        );
      case SignalBlockAction.editBlock:
        context.go(Routes.blockEdit(pedalboardId, entry.block.id));
      case SignalBlockAction.endpoint:
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (sheetContext) => BlockEndpointSheet(
            block: entry.block,
            // The sheet opens on the user's own last answer, which this screen is
            // already watching.
            saved: ref
                .read(signalEndpointsProvider(pedalboardId))
                .valueOrNull
                ?.of(entry.block.id),
          ),
        );
      case SignalBlockAction.pairReturn:
        await showModalBottomSheet<void>(
          context: context,
          builder: (sheetContext) => SendPairSheet(
            pedalboardId: pedalboardId,
            sendBlockId: entry.block.id,
          ),
        );
      case SignalBlockAction.cables:
        await showModalBottomSheet<void>(
          context: context,
          builder: (sheetContext) => BlockCablesSheet(
            pedalboardId: pedalboardId,
            sourceBlockId: entry.block.id,
          ),
        );
      case SignalBlockAction.toggleBypass:
        await _run(
          context,
          () => ref
              .read(signalChainRepositoryProvider)
              .setEnabled(
                blockId: entry.block.id,
                isEnabled: !entry.block.isEnabled,
              ),
        );
      case SignalBlockAction.remove:
        await _remove(context, ref, entry);
    }
  }

  /// Takes a block off, and offers to put it back.
  ///
  /// A block can carry a label, notes and a pedal, so removing one by mistake
  /// costs more than a tap to redo. The undo restores all of it, in the place it
  /// stood.
  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    ChainBlock entry,
  ) async {
    final repository = ref.read(signalChainRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);

    await _run(context, () async {
      final gone = await repository.removeBlock(entry.block.id);

      messenger.showSnackBar(
        SnackBar(
          content: Text('${gone.blockType.label} removed'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              try {
                await repository.restoreBlock(gone);
              } catch (error) {
                messenger.showSnackBar(
                  SnackBar(content: Text(failureMessage(error))),
                );
              }
            },
          ),
        ),
      );
    });
  }

  Future<void> _run(BuildContext context, Future<void> Function() write) async {
    try {
      await write();
    } catch (error) {
      if (context.mounted) {
        showFailureSnackBar(context, error);
      }
    }
  }
}
