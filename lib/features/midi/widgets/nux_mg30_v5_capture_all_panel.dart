import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../../shared/widgets/progress_dialog.dart';
import '../data/nux_mg30_v5_preset_capture_service.dart';
import '../providers/midi_engine_providers.dart';
import '../providers/midi_preset_capture_providers.dart';
import 'preset_capture_summary_view.dart';

/// Bulk form of the single-preset read: walks every program number 0-127,
/// storing a raw capture (plus a best-effort decode) for each - see
/// `NuxMg30V5PresetCaptureService`.
///
/// Deliberately named "Capture", not "Import": nothing this produces is
/// wired into the Patch Browser or the Patch/Scene library yet - that is a
/// later phase, once the single-preset read has actually been confirmed
/// against real hardware. This exists so 128 reads do not have to be done
/// one at a time by hand once that happens.
class NuxMg30V5CaptureAllPanel extends ConsumerStatefulWidget {
  const NuxMg30V5CaptureAllPanel({required this.profileId, required this.unitId, super.key});

  final String profileId;
  final int unitId;

  @override
  ConsumerState<NuxMg30V5CaptureAllPanel> createState() => _NuxMg30V5CaptureAllPanelState();
}

class _NuxMg30V5CaptureAllPanelState extends ConsumerState<NuxMg30V5CaptureAllPanel> {
  bool _running = false;
  PresetCaptureSummary? _summary;

  @override
  Widget build(BuildContext context) {
    final existingCount = ref.watch(midiPresetCapturesProvider(widget.unitId)).valueOrNull?.length ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Capture All Presets (Experimental)', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$existingCount of 128 slots already captured. This reads program '
              'numbers 0-127 one at a time - it can take a few minutes. One slot '
              'timing out or failing does not stop the rest; the summary below '
              'lists which ones did not come back.',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              // The run itself reports into a modal ProgressDialog, so there is
              // nothing to show inline while it happens.
              onPressed: _running ? null : () => _start(existingCount),
              child: const Text('Capture All Presets'),
            ),
            if (_summary != null) ...[
              const SizedBox(height: AppSpacing.sm),
              PresetCaptureSummaryView(summary: _summary!),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _start(int existingCount) async {
    var decision = PresetCaptureDecision.skip;
    if (existingCount > 0) {
      final chosen = await showDialog<PresetCaptureDecision>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Already captured'),
          content: Text(
            '$existingCount slot(s) already have a capture. Keep them, or read '
            'and replace every one?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(PresetCaptureDecision.skip),
              child: const Text('Keep existing'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(PresetCaptureDecision.overwrite),
              child: const Text('Replace all'),
            ),
          ],
        ),
      );
      if (chosen == null || !mounted) {
        return;
      }
      decision = chosen;
    }

    setState(() {
      _running = true;
      _summary = null;
    });

    try {
      final summary = await runWithProgressDialog(
        context,
        title: 'Capturing Presets',
        label: (progress) => progress.total == 0
            ? 'Starting...'
            : 'Reading preset ${progress.completed} of ${progress.total}...',
        job: (report) => ref
            .read(nuxMg30V5PresetCaptureServiceProvider)
            .captureAll(
              unitId: widget.unitId,
              deviceProfileId: widget.profileId,
              onDuplicate: decision,
              onProgress: report,
            ),
      );
      if (mounted) setState(() => _summary = summary);
    } catch (error) {
      if (mounted) showFailureSnackBar(context, error);
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }
}
