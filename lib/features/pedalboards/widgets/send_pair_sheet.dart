import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/daos/signal_chain_dao.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/chain_block_name.dart';
import '../data/chain_endpoints.dart';
import '../data/endpoint_choices.dart';
import '../data/signal_endpoint_repository.dart';
import '../providers/pedalboard_providers.dart';
import 'sheet_note.dart';

/// Which return brings signal back in after it leaves at this send.
///
/// This is the rig's own trip out and back, and no cable is stored for it: in
/// between, the signal is off the board - through an amplifier's effects loop, most
/// often - and a cable would claim the app knows what happens to it out there. The
/// pair is what makes the chain read in the order it is patched.
///
/// The amplifier's own send and return are not these. A board's send goes into the
/// amp, and what comes back arrives from the amp's send, which is why the two halves
/// are described separately and only tied together here.
class SendPairSheet extends ConsumerStatefulWidget {
  const SendPairSheet({
    required this.pedalboardId,
    required this.sendBlockId,
    super.key,
  });

  final int pedalboardId;
  final int sendBlockId;

  @override
  ConsumerState<SendPairSheet> createState() => _SendPairSheetState();
}

class _SendPairSheetState extends ConsumerState<SendPairSheet> {
  bool _isSaving = false;

  Future<void> _run(
    Future<void> Function(SignalEndpointRepository endpoints) write,
  ) async {
    setState(() => _isSaving = true);

    try {
      await write(ref.read(signalEndpointRepositoryProvider));
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) showFailureSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chain =
        ref.watch(signalChainProvider(widget.pedalboardId)).valueOrNull ??
        const <ChainBlock>[];
    final endpoints =
        ref.watch(signalEndpointsProvider(widget.pedalboardId)).valueOrNull ??
        ChainEndpoints.none;

    final paired = endpoints.pairedWith(widget.sendBlockId);
    final candidates = pairCandidates(
      chain: chain,
      endpoints: endpoints,
      sendBlockId: widget.sendBlockId,
    );

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Where does it come back in?',
              style: theme.textTheme.titleMedium,
            ),
          ),
          Flexible(child: _buildList(candidates, paired)),
        ],
      ),
    );
  }

  Widget _buildList(List<PairCandidate> candidates, int? paired) {
    return ListView(
      shrinkWrap: true,
      children: [
        // A rig can be saved with a send and no return: it is a loop the user has
        // not finished describing, not a mistake.
        if (candidates.isEmpty)
          const SheetNote(
            'Nothing on this rig takes signal back in yet. Add a return block, '
            'and pair it with this send.',
          ),
        for (final candidate in candidates)
          ListTile(
            leading: Icon(
              candidate.block.block.id == paired
                  ? Icons.check_circle
                  : Icons.loop,
            ),
            title: Text(
              candidate.block.displayName,
              overflow: TextOverflow.ellipsis,
            ),
            // Offered anyway, so a user rearranging their loops can see where the
            // return they were after has gone rather than find it missing.
            subtitle: candidate.isTaken
                ? const Text('Already paired with another send')
                : null,
            enabled: !_isSaving,
            onTap: candidate.block.block.id == paired
                ? null
                : () => _run(
                    (endpoints) => endpoints.pair(
                      sendBlockId: widget.sendBlockId,
                      returnBlockId: candidate.block.block.id,
                    ),
                  ),
          ),
        if (paired != null) ...[
          const Divider(),
          ListTile(
            leading: const Icon(Icons.link_off),
            title: const Text('Not paired'),
            subtitle: const Text('Both blocks stay on the rig'),
            enabled: !_isSaving,
            onTap: () =>
                _run((endpoints) => endpoints.unpair(widget.sendBlockId)),
          ),
        ],
      ],
    );
  }
}
