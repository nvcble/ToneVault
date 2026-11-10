import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/midi/midi_message.dart';
import '../../../../shared/widgets/failure_snack_bar.dart';
import '../data/ampero_mini_read_probe.dart';
import '../providers/hotone_ampero_mini_data_providers.dart';

/// Sends one request copied from Hotone's editor and shows the raw reply.
///
/// An experiment, not a feature: it reports what came back and never claims a
/// patch was read. It sends only on a tap, one message at a time.
class AmperoMiniReadProbeSheet extends ConsumerStatefulWidget {
  const AmperoMiniReadProbeSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const AmperoMiniReadProbeSheet(),
  );

  @override
  ConsumerState<AmperoMiniReadProbeSheet> createState() =>
      _AmperoMiniReadProbeSheetState();
}

class _AmperoMiniReadProbeSheetState
    extends ConsumerState<AmperoMiniReadProbeSheet> {
  // Defaults to the slot captured on 2026-11-10: user bank, P02-1.
  int _bank = 1;
  int _index = 3;
  AmperoMiniProbeStep _step = AmperoMiniProbeStep.request08;
  bool _busy = false;
  AmperoMiniReadProbeResult? _result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = _result;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Patch read probe', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Sends the one message Hotone\'s editor sends first for a '
                'patch slot, and lists what the pedal answers. Experimental: '
                'it is not known what the message does besides drawing a '
                'reply, and nothing here proves a patch was read.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 1, label: Text('Bank 1 (user)')),
                  ButtonSegment(value: 0, label: Text('Bank 0 (factory)')),
                ],
                selected: {_bank},
                onSelectionChanged: (s) => setState(() => _bank = s.first),
              ),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<AmperoMiniProbeStep>(
                segments: [
                  for (final s in AmperoMiniProbeStep.values)
                    ButtonSegment(value: s, label: Text('Request ${s.label}')),
                ],
                selected: {_step},
                onSelectionChanged: (s) => setState(() => _step = s.first),
              ),
              Row(
                children: [
                  Expanded(child: Text('Slot index: $_index')),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _index > 0
                        ? () => setState(() => _index--)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _index < amperoMiniProbeSlotsPerBank - 1
                        ? () => setState(() => _index++)
                        : null,
                  ),
                ],
              ),
              FilledButton(
                onPressed: _busy ? null : _send,
                child: Text(_busy ? 'Listening...' : 'Send read request'),
              ),
              if (result != null) ...[
                const SizedBox(height: AppSpacing.md),
                _ResultView(result: result),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _result = null;
    });
    try {
      final result = await ref
          .read(hotoneAmperoMiniMidiServiceProvider)
          .probeRead(bank: _bank, index: _index, step: _step);
      if (mounted) setState(() => _result = result);
    } catch (error) {
      if (mounted) showFailureSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result});

  final AmperoMiniReadProbeResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mono = theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          result.acknowledged
              ? 'The pedal sent the same acknowledgement the editor gets.'
              : result.replies.isEmpty
              ? 'The pedal sent no reply.'
              : 'The pedal replied (not the 08 acknowledgement; see below).',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text('Sent: ${hexBytes(result.sent)}', style: mono),
        Text('Received ${result.replies.length} message(s):'),
        for (final reply in result.replies) Text(hexBytes(reply), style: mono),
      ],
    );
  }
}
