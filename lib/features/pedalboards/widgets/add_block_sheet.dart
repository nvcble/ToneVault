import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/enums/signal_block_type.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/pedalboard_providers.dart';
import 'signal_block_style.dart';

/// Puts a new block on the end of a rig's chain.
///
/// The type is all that is asked for. A rig is laid out before it is bought, so
/// "a delay goes here" is a complete thing to say, and which pedal fills it - if
/// one ever does - is a separate decision made on the block itself.
///
/// Where in the chain it goes is settled by dragging afterwards, so the choice
/// here is only what the block is for.
class AddBlockSheet extends ConsumerStatefulWidget {
  const AddBlockSheet({required this.pedalboardId, super.key});

  final int pedalboardId;

  @override
  ConsumerState<AddBlockSheet> createState() => _AddBlockSheetState();
}

class _AddBlockSheetState extends ConsumerState<AddBlockSheet> {
  bool _isSaving = false;

  Future<void> _add(SignalBlockType blockType) async {
    setState(() => _isSaving = true);

    try {
      await ref
          .read(signalChainRepositoryProvider)
          .addBlock(pedalboardId: widget.pedalboardId, blockType: blockType);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      // A refused block leaves the sheet open, so another can be picked without
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

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text('What goes here?', style: theme.textTheme.titleMedium),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                // Enum order, which follows a conventional chain, so the list
                // reads the way a board is built.
                for (final blockType in SignalBlockType.values)
                  _BlockTypeTile(
                    blockType: blockType,
                    onTap: _isSaving ? null : () => _add(blockType),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockTypeTile extends StatelessWidget {
  const _BlockTypeTile({required this.blockType, this.onTap});

  final SignalBlockType blockType;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = SignalBlockStyle.of(blockType);

    return ListTile(
      leading: Icon(style.icon, color: style.color),
      title: Text(blockType.label),
      onTap: onTap,
    );
  }
}
