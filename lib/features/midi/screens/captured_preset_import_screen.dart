import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/midi_device_link_providers.dart';
import '../providers/preset_import_providers.dart';
import '../widgets/preset_import_flow.dart';

/// Phase 7 of the diagnostic-import brief: the same [PresetImportFlow] the
/// real transfer will use one day, pointed at captures already saved from
/// MIDI Diagnostics instead of a live device.
///
/// Nothing shown here is a confirmed NUX protocol - every preset is decoded
/// with the same unverified logic used in Diagnostics. This screen exists so
/// decoding can be reviewed and, if it
/// looks right, brought into the Patch Browser - without requiring the
/// MG-30 to be reconnected.
class CapturedPresetImportScreen extends ConsumerWidget {
  const CapturedPresetImportScreen({required this.profileId, super.key});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pedalAsync = ref.watch(linkedPedalProvider(profileId));

    return Scaffold(
      appBar: AppBar(title: const Text('Captured Presets (Experimental)')),
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
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Decoded from raw bytes saved in MIDI Diagnostics, not read '
                  'live from the device. Unverified for V5 - check each '
                  'preset before trusting it.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                child: PresetImportFlow(
                  unitId: pedal.id,
                  service: ref.watch(
                    experimentalCapturedPresetImportServiceProvider(pedal.id),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
