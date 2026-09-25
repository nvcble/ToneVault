import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/midi/midi_connection_state.dart';
import '../../../core/midi/midi_device_registry.dart';
import '../../../core/midi/profiles/nux_mg30_v5/nux_mg30_v5_profile.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../../shared/widgets/inline_button_theme.dart';
import '../../../shared/widgets/section_label.dart';
import '../data/midi_connection_snapshot.dart';
import '../providers/midi_capture_controller.dart';
import '../providers/midi_connection_controller.dart';
import '../providers/midi_device_link_providers.dart';
import '../widgets/midi_connection_status.dart';
import '../widgets/nux_mg30_v5_capture_all_panel.dart';
import '../widgets/nux_mg30_v5_preset_read_panel.dart';
import '../widgets/raw_sysex_sender.dart';

/// MIDI Diagnostics: everything the reverse-engineering brief asks for that
/// is not specific to one guessed protocol - connection info, a bounded
/// capture of raw traffic, and a way to try a candidate SysEx frame by hand.
///
/// Reached from a device's Patches screen directly, and from the Preset
/// Import screen whenever no verified transfer protocol exists yet for that
/// device - see `PresetImportScreen`.
class MidiDiagnosticsScreen extends ConsumerWidget {
  const MidiDiagnosticsScreen({required this.profileId, super.key});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = MidiDeviceRegistry.findById(profileId);
    if (profile == null) {
      return const Scaffold(
        body: EmptyState(icon: Icons.error_outline, title: 'Unknown device'),
      );
    }

    final MidiConnectionSnapshot snapshot;
    try {
      // The MIDI plugin is touched the moment this provider first builds -
      // if the platform side is unavailable, this throws rather than
      // hanging, and the screen would otherwise render nothing at all.
      snapshot = ref.watch(midiConnectionProvider(profileId));
    } catch (error) {
      return Scaffold(
        appBar: AppBar(title: const Text('MIDI Diagnostics')),
        body: EmptyState(
          icon: Icons.error_outline,
          title: 'Could not reach the MIDI plugin',
          message: failureMessage(error),
        ),
      );
    }

    final capture = ref.watch(midiCaptureProvider);
    final captureController = ref.read(midiCaptureProvider.notifier);
    final unitId = ref.watch(linkedPedalProvider(profileId)).valueOrNull?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('MIDI Diagnostics')),
      body: ListView(
        children: [
          const SectionLabel('Connection'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${profile.manufacturer} ${profile.model}'),
                // Firmware and transport are what this profile was built
                // for, not something read off the connected unit - nothing
                // yet queries the device's own firmware version.
                Text(
                  'Firmware: ${profile.firmwareVersion} (assumed, not detected)',
                ),
                Text(
                  'Transport: ${profile.connectionTypes.map((t) => t.label).join(', ')}',
                ),
                const SizedBox(height: AppSpacing.sm),
                MidiConnectionStatus(snapshot: snapshot),
                const SizedBox(height: AppSpacing.sm),
                if (snapshot.state != MidiConnectionState.connected)
                  FilledButton(
                    onPressed: snapshot.isBusy
                        ? null
                        : ref
                              .read(midiConnectionProvider(profileId).notifier)
                              .connect,
                    child: const Text('Connect'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const SectionLabel('MIDI Capture'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            // Without a finite minimum width, the theme's column-spanning
            // FilledButton takes a whole line of the wrap to itself.
            child: InlineButtonTheme(
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  FilledButton(
                    onPressed: capture.isCapturing
                        ? null
                        : captureController.start,
                    child: const Text('Start Capture'),
                  ),
                  OutlinedButton(
                    onPressed: capture.isCapturing
                        ? captureController.stop
                        : null,
                    child: const Text('Stop Capture'),
                  ),
                  OutlinedButton(
                    onPressed: capture.entries.isEmpty
                        ? null
                        : captureController.clear,
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
          ),
          // The bytes themselves live on their own page: a few seconds of real
          // traffic is enough rows to bury every control below this one.
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('View Capture Log'),
            subtitle: Text(
              capture.entries.isEmpty
                  ? capture.isCapturing
                        ? 'Capturing. Nothing received yet.'
                        : 'Nothing captured yet.'
                  : '${capture.entries.length} message(s) recorded',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.midiCaptureLog(profileId)),
          ),
          const SizedBox(height: AppSpacing.md),
          const SectionLabel('Manual Probe'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: RawSysExSender(),
          ),
          if (profile is NuxMg30V5Profile) ...[
            const SizedBox(height: AppSpacing.md),
            const SectionLabel('Preset Import (Milestone 1)'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: NuxMg30V5PresetReadPanel(
                profileId: profileId,
                unitId: unitId,
              ),
            ),
            if (unitId != null) ...[
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: NuxMg30V5CaptureAllPanel(
                  profileId: profileId,
                  unitId: unitId,
                ),
              ),
            ],
          ],
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
