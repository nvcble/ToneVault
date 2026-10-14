import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/midi/midi_connection_state.dart';
import '../../../core/midi/midi_endpoint.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../../shared/widgets/inline_button_theme.dart';
import '../data/midi_clock_output_state.dart';
import '../providers/midi_clock_providers.dart';
import '../providers/midi_connection_controller.dart';
import 'midi_clock_log_view.dart';
import 'midi_clock_readout.dart';
import 'midi_number_field.dart';

/// The MIDI Clock test: a standards-compliant clock stream, sent on demand,
/// measured while it runs.
///
/// Sends Start (0xFA), then 24 Timing Clock pulses (0xF8) to the quarter
/// note, then Stop (0xFC) - nothing device-specific, and no CC pretending to
/// be a tempo. Whether the device at the other end follows a clock is a
/// question only the device can answer, which is why this panel reports what
/// was sent and never what was received.
class MidiClockPanel extends ConsumerWidget {
  const MidiClockPanel({required this.profileId, super.key});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(midiClockProvider(profileId));
    final controller = ref.read(midiClockProvider(profileId).notifier);
    final snapshot = ref.watch(midiConnectionProvider(profileId));
    final connected = snapshot.state == MidiConnectionState.connected;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MIDI Clock Test', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Sends the standard clock stream: Start (FA), 24 Timing Clock '
              'pulses (F8) per quarter note, Stop (FC). A clock is a '
              'synchronisation stream, not a command - a device that follows '
              'one works its tempo out from the pulse rate, and a device that '
              'does not ignores every byte. Nothing here can tell you the '
              'unit received anything: watch the unit.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Output: ${_outputName(connected, snapshot.endpoints)}',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              connected
                  ? 'Chosen on the Connection section above.'
                  : 'Connect the device above before sending.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _TempoRow(bpm: state.bpm, onChanged: controller.setBpm),
            const SizedBox(height: AppSpacing.sm),
            InlineButtonTheme(
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final step in const [-5, -1, 1, 5])
                    OutlinedButton(
                      onPressed: () => controller.nudgeBpm(step),
                      child: Text(step > 0 ? '+$step' : '$step'),
                    ),
                  OutlinedButton(
                    onPressed: controller.tap,
                    child: const Text('Tap tempo'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            InlineButtonTheme(
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  FilledButton(
                    onPressed: connected && !state.isRunning
                        ? () => _run(context, controller.start)
                        : null,
                    child: const Text('Start Clock'),
                  ),
                  OutlinedButton(
                    onPressed: state.isRunning
                        ? () => _run(context, controller.stop)
                        : null,
                    child: const Text('Stop Clock'),
                  ),
                  OutlinedButton(
                    onPressed: connected && !state.isRunning
                        ? () => _run(context, controller.sendTestPulse)
                        : null,
                    child: const Text('Send Test Pulse'),
                  ),
                ],
              ),
            ),
            SwitchListTile(
              value: state.outputEnabled,
              onChanged: controller.setOutputEnabled,
              contentPadding: EdgeInsets.zero,
              title: const Text('MIDI Clock output'),
              subtitle: const Text(
                'Off by default. While off, only the Start button here sends '
                'clock; nothing else in the app puts it on the wire.',
              ),
            ),
            const Divider(),
            MidiClockReadout(report: state.report),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Last message: ${_lastMessage(state)}',
              style: theme.textTheme.bodySmall,
            ),
            const Divider(),
            MidiClockLogView(
              entries: state.entries,
              onClear: controller.clearLog,
            ),
          ],
        ),
      ),
    );
  }

  String _outputName(bool connected, List<MidiEndpoint> endpoints) {
    if (!connected) {
      return 'no device connected';
    }
    return endpoints.firstOrNull?.name ?? 'connected device';
  }

  /// A running stream's last message is nearly always a pulse, and pulses
  /// are counted rather than logged - so say which pulse it was rather than
  /// quoting a log that deliberately does not hold it.
  String _lastMessage(MidiClockOutputState state) {
    final report = state.report;
    if (state.isRunning && report != null) {
      return 'F8 Timing Clock · pulse ${report.pulsesSent} of this run';
    }
    final entry = state.lastEntry;
    if (entry == null) {
      return 'nothing sent yet';
    }
    return '${entry.bytes == null ? '' : '${entry.bytes} '}${entry.type}';
  }

  /// Runs an action that talks to the port, putting any failure in front of
  /// the user rather than only in the log.
  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (context.mounted) {
        showFailureSnackBar(context, error);
      }
    }
  }
}

/// The tempo: shown big, typed in, or tapped - the clock's one source of
/// BPM, whichever way it was set.
class _TempoRow extends StatelessWidget {
  const _TempoRow({required this.bpm, required this.onChanged});

  final int bpm;
  final void Function(int bpm) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('$bpm', style: theme.textTheme.headlineMedium),
        const SizedBox(width: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Text('BPM', style: theme.textTheme.bodySmall),
        ),
        const Spacer(),
        MidiNumberField(value: bpm, onChanged: onChanged),
      ],
    );
  }
}
