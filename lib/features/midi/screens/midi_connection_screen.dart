import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/midi/midi_connection_state.dart';
import '../../../shared/widgets/section_label.dart';
import '../providers/midi_connection_controller.dart';
import '../widgets/midi_connection_status.dart';

/// Connect to, or disconnect from, one device profile's hardware.
class MidiConnectionScreen extends ConsumerWidget {
  const MidiConnectionScreen({required this.profileId, super.key});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(midiConnectionProvider(profileId));
    final controller = ref.read(midiConnectionProvider(profileId).notifier);
    final isConnected = snapshot.state == MidiConnectionState.connected;
    final isBusy = snapshot.state == MidiConnectionState.connecting;

    return Scaffold(
      appBar: AppBar(
        title: Text(snapshot.profile.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Look for the device again',
            onPressed: controller.scan,
          ),
        ],
      ),
      body: ListView(
        children: [
          const SectionLabel('Device'),
          _Field(label: 'Device', value: snapshot.profile.displayName),
          _Field(
            label: 'Connection type',
            value: snapshot.profile.connectionTypes.map((type) => type.label).join(', '),
          ),
          const SectionLabel('Connection'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: MidiConnectionStatus(snapshot: snapshot),
          ),
          if (!snapshot.hasDetectedDevice)
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: Text('No MIDI device detected.'),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: isConnected || isBusy ? null : controller.connect,
                    child: const Text('Connect'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton(
                    onPressed: isConnected ? controller.disconnect : null,
                    child: const Text('Disconnect'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: FilledButton.tonal(
              onPressed: isConnected ? () => context.push(Routes.midiControl(profileId)) : null,
              child: const Text('Open control'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline)),
          Text(value, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
