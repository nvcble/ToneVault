import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../data/midi_clock_output_state.dart';

/// The clock diagnostic's log: what was sent, to which output, as which
/// bytes, and what failed.
///
/// Clock pulses are not in it - at 120 BPM they arrive 48 times a second,
/// which would push everything worth reading off the top within seconds. The
/// pulses are counted instead, by `MidiClockReadout`.
class MidiClockLogView extends StatelessWidget {
  const MidiClockLogView({
    required this.entries,
    required this.onClear,
    this.maxVisible = 12,
    super.key,
  });

  /// Newest first.
  final List<MidiClockLogEntry> entries;

  final VoidCallback onClear;

  /// How many rows to draw. The rest are counted in a line underneath: this
  /// sits inside the Diagnostics screen's own scroll view, and a list that
  /// grew without limit would bury every panel below it.
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (entries.isEmpty) {
      return Text(
        'Nothing sent yet.',
        style: theme.textTheme.bodySmall,
      );
    }

    final hidden = entries.length - maxVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in entries.take(maxVisible))
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: _LogRow(entry: entry),
          ),
        if (hidden > 0)
          Text(
            '$hidden earlier entr${hidden == 1 ? 'y' : 'ies'} not shown.',
            style: theme.textTheme.bodySmall,
          ),
        const SizedBox(height: AppSpacing.xs),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(onPressed: onClear, child: const Text('Clear log')),
        ),
      ],
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.entry});

  final MidiClockLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = entry.isFailure ? theme.colorScheme.error : null;
    final detail = entry.detail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_timestamp(entry.timestamp)}  ${entry.type}'
          '${entry.bytes == null ? '' : '  ${entry.bytes}'}',
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            color: color,
          ),
        ),
        Text(
          detail == null ? entry.device : '${entry.device} · $detail',
          style: theme.textTheme.bodySmall?.copyWith(
            color: color ?? theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Local wall-clock time to the millisecond, written out by hand rather
  /// than through `intl`: the app has no localisation dependency, and a log
  /// of a timing test wants the milliseconds a locale format would drop.
  String _timestamp(DateTime at) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(at.hour)}:${two(at.minute)}:${two(at.second)}'
        '.${at.millisecond.toString().padLeft(3, '0')}';
  }
}
