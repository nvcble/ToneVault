import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/midi/profiles/nux_mg30_v5/nux_mg30_v5_layout_probe.dart';
import '../providers/midi_preset_capture_providers.dart';

/// Runs [probeNuxMg30V5BlockLayout] over every capture saved for the unit and
/// reports what it found, so the one thing standing between an imported patch
/// and the pedals it used - where the block region sits in a V5 reply - can be
/// narrowed down from dumps already on the phone.
///
/// A reading only, like everything else in Diagnostics: nothing here changes a
/// patch, and a candidate offset is a lead to check against what the unit shows
/// on that slot, not a decode.
class NuxMg30V5LayoutProbePanel extends ConsumerWidget {
  const NuxMg30V5LayoutProbePanel({required this.unitId, super.key});

  final int unitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final captures =
        ref.watch(midiPresetCapturesProvider(unitId)).valueOrNull ?? const [];
    final findings = probeNuxMg30V5BlockLayout([
      for (final capture in captures) capture.rawSysEx,
    ]);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Block Layout Probe', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Which pedals a patch uses is in the dump; this looks for where. '
              'Capture more slots to narrow it: an offset has to hold for every '
              'one of them.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            _Row(
              label: 'Dumps scanned',
              value: findings.dumps == 0
                  ? 'none captured yet'
                  : '${findings.dumps} '
                        '(${findings.frameLengths.join(', ')} bytes)',
            ),
            _Row(
              label: 'Chain order',
              value: _offsets(findings.chainOrderBases),
            ),
            _Row(label: 'Model codes', value: _offsets(findings.modelCodeBases)),
            if (findings.dumps > 0 &&
                findings.chainOrderBases.isEmpty &&
                findings.modelCodeBases.isEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'No offset fits in every dump, so this frame does not lay the '
                'region out the way firmware v4.0.3 does. Nothing is guessed '
                'from it.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Selectable, because the next step with an offset is pasting it into a note
  /// or a bug report.
  static String _offsets(List<int> bases) =>
      bases.isEmpty ? 'no candidate offset' : bases.join(', ');
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label)),
          Expanded(child: SelectableText(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
