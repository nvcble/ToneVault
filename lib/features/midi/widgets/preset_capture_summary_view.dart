import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../data/nux_mg30_v5_preset_capture_service.dart';

/// What one capture-all run did, and - when anything failed - why.
///
/// The reason is the whole point: this used to report "Failed: 0, 1, 2, ..."
/// and nothing else, which reads the same whether the device never answered,
/// the send was refused because nothing was connected, or a query threw. The
/// message is selectable so it can be pasted into a bug report as-is.
class PresetCaptureSummaryView extends StatelessWidget {
  const PresetCaptureSummaryView({required this.summary, super.key});

  final PresetCaptureSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final small = theme.textTheme.bodySmall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Captured: ${summary.captured}   Overwritten: ${summary.overwritten}   '
          'Skipped: ${summary.skipped}   Failed: ${summary.failures.length}',
        ),
        if (summary.stoppedEarly)
          Text(
            'Stopped early: several slots in a row failed the same way, so the '
            'rest were not attempted.',
            style: small?.copyWith(color: theme.colorScheme.error),
          ),
        for (final group in groupCaptureFailures(summary.failures)) ...[
          const SizedBox(height: AppSpacing.xs),
          SelectableText(
            '${group.count} slot(s) failed: ${group.message}',
            style: small?.copyWith(color: theme.colorScheme.error),
          ),
        ],
        if (summary.failures.isNotEmpty)
          Text(
            'Slots: ${summary.failures.map((failure) => failure.programNumber).join(', ')}',
            style: small,
          ),
      ],
    );
  }
}
