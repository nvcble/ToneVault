import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/signal_chain_dao.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../pedals/providers/pedal_providers.dart';
import '../data/block_pedal_choices.dart';
import '../providers/pedalboard_providers.dart';

/// Puts one pedal from the inventory into a block, or empties the block again.
///
/// Only the block changes. The pedal is referenced rather than copied, so the
/// same one can stand on as many rigs as the user has, and taking it out of a
/// block leaves it owned with its settings and history intact.
class AssignPedalSheet extends ConsumerStatefulWidget {
  const AssignPedalSheet({required this.block, super.key});

  final SignalBlock block;

  @override
  ConsumerState<AssignPedalSheet> createState() => _AssignPedalSheetState();
}

class _AssignPedalSheetState extends ConsumerState<AssignPedalSheet> {
  bool _isSaving = false;

  Future<void> _assign(int? pedalId) async {
    setState(() => _isSaving = true);

    try {
      await ref
          .read(signalChainRepositoryProvider)
          .assignPedal(blockId: widget.block.id, pedalId: pedalId);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        showFailureSnackBar(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pedals = ref.watch(pedalListProvider).valueOrNull ?? const <Pedal>[];
    final chain =
        ref.watch(signalChainProvider(widget.block.pedalboardId)).valueOrNull ??
        const <ChainBlock>[];

    final choices = pedalChoices(
      pedals: pedals,
      chain: chain,
      blockType: widget.block.blockType,
      exceptBlockId: widget.block.id,
    );
    final hasNone = choices.suited.isEmpty && choices.others.isEmpty;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'What fills this ${widget.block.blockType.label.toLowerCase()}?',
              style: theme.textTheme.titleMedium,
            ),
          ),
          if (hasNone)
            _NothingToPut(inventoryIsEmpty: pedals.isEmpty)
          else
            Flexible(child: _buildList(choices)),
        ],
      ),
    );
  }

  Widget _buildList(PedalChoices choices) {
    return ListView(
      shrinkWrap: true,
      children: [
        // What the block asks for comes first; everything else owned follows,
        // because it is the user's board and a fuzz in the overdrive slot is
        // their call. No heading where there is only one group to read.
        if (choices.suited.isNotEmpty && choices.others.isNotEmpty)
          const _GroupHeading('Suits this block'),
        for (final pedal in choices.suited) _tileFor(pedal),
        if (choices.suited.isNotEmpty && choices.others.isNotEmpty)
          const _GroupHeading('Everything else you own'),
        for (final pedal in choices.others) _tileFor(pedal),
        if (widget.block.pedalId != null) ...[
          const Divider(),
          ListTile(
            leading: const Icon(Icons.remove_circle_outline),
            title: const Text('Leave this block empty'),
            subtitle: const Text('The pedal stays in your inventory'),
            onTap: _isSaving ? null : () => _assign(null),
          ),
        ],
      ],
    );
  }

  Widget _tileFor(Pedal pedal) {
    final isHere = pedal.id == widget.block.pedalId;

    return ListTile(
      title: Text(pedal.name, overflow: TextOverflow.ellipsis),
      subtitle: pedal.brand == null ? null : Text(pedal.brand!),
      trailing: isHere ? const Icon(Icons.check) : null,
      onTap: _isSaving || isHere ? null : () => _assign(pedal.id),
    );
  }
}

class _GroupHeading extends StatelessWidget {
  const _GroupHeading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// Shown instead of the list when nothing in the inventory could go in, which
/// happens for two quite different reasons.
class _NothingToPut extends StatelessWidget {
  const _NothingToPut({required this.inventoryIsEmpty});

  final bool inventoryIsEmpty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Text(
        inventoryIsEmpty
            ? 'Add a pedal to your inventory first, and it can then fill a block.'
            : 'Every pedal you own that could go on a rig is already on this '
                  'one.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
