import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pedalboard_dao.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../pedals/providers/pedal_providers.dart';
import '../data/chain_choices.dart';
import '../providers/pedalboard_providers.dart';

/// Puts one pedal from the inventory on the end of a rig's chain.
///
/// A sheet rather than a screen: it is a single tap, and the chain the pedal
/// joins stays in view behind it. Where in the chain it goes is settled by
/// dragging afterwards, so the choice here is only which pedal.
class AddPedalSheet extends ConsumerStatefulWidget {
  const AddPedalSheet({required this.pedalboardId, super.key});

  final int pedalboardId;

  @override
  ConsumerState<AddPedalSheet> createState() => _AddPedalSheetState();
}

class _AddPedalSheetState extends ConsumerState<AddPedalSheet> {
  bool _isSaving = false;

  Future<void> _add(int pedalId) async {
    setState(() => _isSaving = true);

    try {
      await ref
          .read(rigChainRepositoryProvider)
          .addPedal(pedalboardId: widget.pedalboardId, pedalId: pedalId);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      // A refused pedal leaves the sheet open, so another can be picked without
      // starting again.
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
        ref.watch(rigChainProvider(widget.pedalboardId)).valueOrNull ??
        const <ChainSlot>[];
    final addable = addablePedals(pedals: pedals, chain: chain);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text('Add a pedal', style: theme.textTheme.titleMedium),
          ),
          if (addable.isEmpty)
            _NothingToAdd(inventoryIsEmpty: pedals.isEmpty)
          else
            Flexible(child: _buildList(addable)),
        ],
      ),
    );
  }

  Widget _buildList(List<Pedal> addable) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: addable.length,
      itemBuilder: (context, index) {
        final pedal = addable[index];
        final brand = pedal.brand;

        return ListTile(
          title: Text(pedal.name, overflow: TextOverflow.ellipsis),
          subtitle: brand == null ? null : Text(brand),
          trailing: const Icon(Icons.add),
          onTap: _isSaving ? null : () => _add(pedal.id),
        );
      },
    );
  }
}

/// Shown instead of the list when nothing in the inventory could go on, which
/// happens for two quite different reasons.
class _NothingToAdd extends StatelessWidget {
  const _NothingToAdd({required this.inventoryIsEmpty});

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
            ? 'Add a pedal to your inventory first, and it can then go on a rig.'
            : 'Every pedal you own that could go on a rig is already on this '
                  'one.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
