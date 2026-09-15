import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/midi/midi_device_registry.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/midi_device_link_providers.dart';
import '../providers/preset_import_providers.dart';
import '../widgets/experimental_preset_import_panel.dart';
import '../widgets/preset_import_flow.dart';

/// Read-only preset import from a real device - see Part 1 of the MIDI
/// module brief.
///
/// Reachable from a device's Patches screen. Every device profile currently
/// has [presetImportServiceProvider] resolve to null - see that provider's
/// documentation - so today this shows [ExperimentalPresetImportPanel]
/// (connect, then a path to MIDI Diagnostics and to reviewing whatever has
/// already been captured there) rather than [PresetImportFlow] directly.
/// [PresetImportFlow] is ready the moment a device profile confirms a real
/// transfer protocol.
class PresetImportScreen extends ConsumerWidget {
  const PresetImportScreen({required this.profileId, super.key});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = MidiDeviceRegistry.findById(profileId);
    if (profile == null) {
      return const Scaffold(
        body: EmptyState(icon: Icons.error_outline, title: 'Unknown device'),
      );
    }

    final pedalAsync = ref.watch(linkedPedalProvider(profileId));
    final service = ref.watch(presetImportServiceProvider(profileId));

    return Scaffold(
      appBar: AppBar(title: const Text('Import Presets')),
      body: pedalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load this device\'s gear',
          message: failureMessage(error),
        ),
        data: (pedal) {
          if (pedal == null) {
            return const EmptyState(
              icon: Icons.link_off,
              title: 'Not gear yet',
              message: 'Add this device as gear from its Patches screen first.',
            );
          }
          if (service == null) {
            return ExperimentalPresetImportPanel(
              profileId: profileId,
              profile: profile,
              unitId: pedal.id,
            );
          }
          return PresetImportFlow(unitId: pedal.id, service: service);
        },
      ),
    );
  }
}
