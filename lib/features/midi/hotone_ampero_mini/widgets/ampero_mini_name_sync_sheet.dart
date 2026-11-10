import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/midi/midi_engine.dart';
import '../../providers/midi_engine_providers.dart';
import '../data/ampero_mini_patch_layout.dart';
import '../data/ampero_mini_patch_reader.dart';
import '../data/ampero_mini_patch_sync.dart';
import '../providers/hotone_ampero_mini_data_providers.dart';

/// Reads the 99 user-patch names from the pedal into the local library.
class AmperoMiniNameSyncSheet extends ConsumerStatefulWidget {
  const AmperoMiniNameSyncSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    builder: (_) => const AmperoMiniNameSyncSheet(),
  );

  @override
  ConsumerState<AmperoMiniNameSyncSheet> createState() =>
      _AmperoMiniNameSyncSheetState();
}

class _AmperoMiniNameSyncSheetState
    extends ConsumerState<AmperoMiniNameSyncSheet> {
  bool _running = false;
  bool _stop = false;
  int _done = 0;
  AmperoMiniSyncOutcome? _outcome;

  Future<void> _start() async {
    setState(() {
      _running = true;
      _stop = false;
      _done = 0;
      _outcome = null;
    });
    final MidiEngine engine = ref.read(midiEngineProvider);
    final outcome = await syncAmperoMiniUserPatchNames(
      reader: AmperoMiniPatchReader(engine),
      repository: ref.read(hotoneAmperoMiniPatchRepositoryProvider),
      onProgress: (n) {
        if (mounted) setState(() => _done = n);
      },
      shouldStop: () => _stop,
    );
    if (mounted) {
      setState(() {
        _running = false;
        _outcome = outcome;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outcome = _outcome;
    final total = amperoMiniUserPatchCount;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Read names from pedal', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Asks the pedal for the name of each of the 99 user patches '
              '(P01-1 to P33-3) and stores them here, replacing names read '
              'before. Factory patches are not read. It stops at the first '
              'slot the pedal does not answer clearly.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            if (_running || outcome != null)
              LinearProgressIndicator(value: _done / total),
            const SizedBox(height: AppSpacing.xs),
            if (_running || outcome != null) Text('$_done of $total read'),
            if (outcome?.failure != null)
              Text(
                'Stopped. ${outcome!.failure}. Names read so far are kept.',
                style: TextStyle(color: theme.colorScheme.error),
              )
            else if (outcome != null && !_stop)
              const Text('Done.'),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (_running)
                  OutlinedButton(
                    onPressed: _stop
                        ? null
                        : () => setState(() => _stop = true),
                    child: Text(_stop ? 'Stopping...' : 'Stop'),
                  )
                else ...[
                  FilledButton(
                    onPressed: _start,
                    child: Text(outcome == null ? 'Start' : 'Run again'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
