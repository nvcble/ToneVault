import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/midi/midi_connection_state.dart';
import '../data/midi_connection_snapshot.dart';

/// The connection state, and the error in place of it when there is one.
class MidiConnectionStatus extends StatelessWidget {
  const MidiConnectionStatus({required this.snapshot, super.key});

  final MidiConnectionSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = switch (snapshot.state) {
      MidiConnectionState.connected => colors.primary,
      MidiConnectionState.connecting => colors.tertiary,
      MidiConnectionState.error => colors.error,
      MidiConnectionState.disconnected => colors.outline,
    };

    return Row(
      children: [
        if (snapshot.isBusy)
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Icon(Icons.circle, size: 12, color: color),
        const SizedBox(width: AppSpacing.sm),
        Text(snapshot.errorMessage ?? snapshot.state.label),
      ],
    );
  }
}
