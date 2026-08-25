import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/signal_chain_dao.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/signal_block_draft.dart';
import '../providers/pedalboard_providers.dart';
import '../widgets/signal_block_form.dart';

/// Edits one block of a rig's chain.
///
/// Only editing: a block is added from the chain itself, in one tap, because
/// choosing what goes where is done while looking at the board rather than on a
/// form of its own.
class SignalBlockFormScreen extends ConsumerStatefulWidget {
  const SignalBlockFormScreen({
    required this.pedalboardId,
    required this.blockId,
    super.key,
  });

  final int pedalboardId;
  final int blockId;

  @override
  ConsumerState<SignalBlockFormScreen> createState() =>
      _SignalBlockFormScreenState();
}

class _SignalBlockFormScreenState extends ConsumerState<SignalBlockFormScreen> {
  bool _isSaving = false;

  Future<void> _save(SignalBlockDraft draft) async {
    setState(() => _isSaving = true);

    try {
      await ref
          .read(signalChainRepositoryProvider)
          .editBlock(blockId: widget.blockId, draft: draft);
      if (mounted) {
        context.go(Routes.rigDetail(widget.pedalboardId));
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
    // Read off the chain the rig screen is already watching, so a block deleted
    // on another screen empties this one rather than saving over nothing.
    final chain = ref.watch(signalChainProvider(widget.pedalboardId));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit block')),
      body: chain.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not open this block',
          message: failureMessage(error),
        ),
        data: (chain) => switch (_blockIn(chain)) {
          final SignalBlock block => SignalBlockForm(
            // Rebuilding for a different block has to start the fields over; the
            // same block keeps whatever is half-typed.
            key: ValueKey<int>(block.id),
            initialDraft: SignalBlockDraft.fromBlock(block),
            isSaving: _isSaving,
            onSubmit: _save,
          ),
          _ => const EmptyState(
            icon: Icons.help_outline,
            title: 'That block is no longer on this rig',
            message: 'It may have been taken off on another screen.',
          ),
        },
      ),
    );
  }

  SignalBlock? _blockIn(List<ChainBlock> chain) {
    for (final entry in chain) {
      if (entry.block.id == widget.blockId) return entry.block;
    }
    return null;
  }
}
