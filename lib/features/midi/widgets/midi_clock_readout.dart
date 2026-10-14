import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../data/midi_clock_report.dart';

/// What the clock stream actually did: pulses sent, the rate they went out
/// at against the rate they were meant to, and how far off the schedule the
/// app managed to be.
///
/// Every figure here is about this app's own sending. None of it is evidence
/// about the device at the other end, which says nothing back.
class MidiClockReadout extends StatelessWidget {
  const MidiClockReadout({required this.report, super.key});

  /// Null before the stream has ever been started.
  final MidiClockReport? report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final report = this.report;

    if (report == null) {
      return Text(
        'Not started. Nothing has been sent.',
        style: theme.textTheme.bodySmall,
      );
    }

    final measured = report.measuredPulsesPerSecond;
    final error = report.errorMessage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Row(
          label: 'Pulses sent',
          value: '${report.pulsesSent}',
          note: 'attempted; USB MIDI confirms no delivery',
        ),
        _Row(
          label: 'Expected rate',
          value: '${report.expectedPulsesPerSecond.toStringAsFixed(2)}/s',
          note: '${report.bpm} BPM × 24',
        ),
        _Row(
          label: 'Measured rate',
          value: measured == null
              ? '—'
              : '${measured.toStringAsFixed(2)}/s',
          note: 'over ${_seconds(report.elapsed)}',
        ),
        _Row(
          label: 'Scheduling jitter',
          value: '${_millis(report.meanLateness)} mean',
          note: '${_millis(report.worstLateness)} worst',
        ),
        if (report.droppedPulses > 0)
          _Row(
            label: 'Pulses missed',
            value: '${report.droppedPulses}',
            note: 'the app woke too late to send them',
          ),
        if (error != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  String _millis(Duration value) =>
      '${(value.inMicroseconds / 1000).toStringAsFixed(1)} ms';

  String _seconds(Duration value) =>
      '${(value.inMilliseconds / 1000).toStringAsFixed(1)} s';
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, required this.note});

  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
          Expanded(
            flex: 2,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                  TextSpan(
                    text: '  $note',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
