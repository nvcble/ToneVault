import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/midi/midi_connection_state.dart';
import '../../../core/midi/midi_device_profile.dart';
import '../providers/midi_connection_controller.dart';
import '../providers/midi_preset_capture_providers.dart';
import 'midi_connection_status.dart';

/// What a device's Preset Import screen shows in place of a real import flow
/// while [NuxMg30V5PresetTransferService] has no verified implementation:
/// connect, then hand off to MIDI Diagnostics rather than dead-ending on
/// "not available" - see the diagnostic-capable-import brief.
///
/// Never invents a preset-read command: there is no "Start Preset Read" that
/// actually reads anything here, only the honest statement that the protocol
/// is unverified and a path to the tool that can help confirm one.
class ExperimentalPresetImportPanel extends ConsumerWidget {
  const ExperimentalPresetImportPanel({
    required this.profileId,
    required this.profile,
    required this.unitId,
    super.key,
  });

  final String profileId;
  final MidiDeviceProfile profile;
  final int unitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(midiConnectionProvider(profileId));
    final controller = ref.read(midiConnectionProvider(profileId).notifier);
    final isConnected = snapshot.state == MidiConnectionState.connected;
    final captureCount =
        ref.watch(midiPresetCapturesProvider(unitId)).valueOrNull?.length ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.science_outlined,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Experimental ${profile.displayName} Preset Import',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'This feature uses experimental MIDI communication. NUX has not '
            'published a SysEx protocol for reading saved patches off this '
            'unit, and its own MIDI implementation chart names no command '
            'for it either.',
          ),
          const SizedBox(height: AppSpacing.md),
          MidiConnectionStatus(snapshot: snapshot),
          const SizedBox(height: AppSpacing.md),
          if (!isConnected)
            FilledButton(
              onPressed: snapshot.isBusy ? null : controller.connect,
              child: const Text('Connect'),
            )
          else ...[
            const Card(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text('Preset-read protocol has not yet been verified.'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton.icon(
              icon: const Icon(Icons.biotech),
              label: const Text('Run MIDI Diagnostic'),
              onPressed: () => context.push(Routes.midiDiagnostics(profileId)),
            ),
          ],
          if (captureCount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              icon: const Icon(Icons.folder_open),
              label: Text('Review $captureCount Captured Preset(s)'),
              onPressed: () =>
                  context.push(Routes.midiCapturedPresetImport(profileId)),
            ),
          ],
        ],
      ),
    );
  }
}
