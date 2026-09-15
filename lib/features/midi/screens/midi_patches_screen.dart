import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/midi/midi_connection_state.dart';
import '../../../core/midi/midi_device_registry.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../patches/providers/patch_providers.dart';
import '../providers/midi_connection_controller.dart';
import '../providers/midi_device_link_providers.dart';
import '../providers/midi_mapping_providers.dart';
import '../providers/patch_control_providers.dart';
import '../widgets/midi_number_field.dart';

/// The linked unit's patches - or, before one is linked, the way to add it.
class MidiPatchesScreen extends ConsumerWidget {
  const MidiPatchesScreen({required this.profileId, super.key});

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Import from device',
            onPressed: () => context.push(Routes.midiPresetImport(profileId)),
          ),
        ],
      ),
      body: pedalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load this device\'s gear',
          message: failureMessage(error),
        ),
        data: (pedal) {
          if (pedal == null) {
            return EmptyState(
              icon: Icons.link_off,
              title: '${profile.displayName} is not gear yet',
              message:
                  'Add it once, and its patches and scenes live alongside every '
                  'other pedal you track.',
              action: FilledButton(
                onPressed: () async {
                  try {
                    await ref
                        .read(midiDeviceLinkRepositoryProvider)
                        .createLinkedGear(profile);
                  } catch (error) {
                    if (context.mounted) showFailureSnackBar(context, error);
                  }
                },
                child: Text('Add ${profile.displayName} as gear'),
              ),
            );
          }

          final patchesAsync = ref.watch(patchListProvider(pedal.id));
          return patchesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load patches',
              message: failureMessage(error),
            ),
            data: (patches) => patches.isEmpty
                ? const EmptyState(
                    icon: Icons.list_alt,
                    title: 'No patches yet',
                    message: 'Add patches for this unit from the Pedals tab.',
                  )
                : ListView.builder(
                    itemCount: patches.length,
                    itemBuilder: (context, index) {
                      final patch = patches[index];
                      final numberAsync = ref.watch(
                        patchProgramNumberProvider(patch.id),
                      );
                      final programNumber =
                          numberAsync.valueOrNull?.programNumber;
                      final experimentalEnabled = ref.watch(
                        experimentalProgramChangeEnabledProvider,
                      );
                      final connected =
                          ref.watch(midiConnectionProvider(profileId)).state ==
                          MidiConnectionState.connected;

                      return ListTile(
                        title: Text(patch.name),
                        onTap: () => context.push(
                          Routes.midiPatchScenes(profileId, patch.id),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MidiNumberField(
                              value: programNumber,
                              onChanged: (number) async {
                                try {
                                  await ref
                                      .read(midiPatchProgramRepositoryProvider)
                                      .setNumber(
                                        patchId: patch.id,
                                        programNumber: number,
                                      );
                                } catch (error) {
                                  if (context.mounted) {
                                    showFailureSnackBar(context, error);
                                  }
                                }
                              },
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            IconButton(
                              icon: const Icon(Icons.send),
                              tooltip: 'Load this patch',
                              onPressed:
                                  connected &&
                                      experimentalEnabled &&
                                      programNumber != null
                                  ? () async {
                                      try {
                                        final override = await ref.read(
                                          patchSelectionOverrideProvider(
                                            profileId,
                                          ).future,
                                        );
                                        await ref
                                            .read(
                                              patchControlControllerProvider,
                                            )
                                            .loadPatch(
                                              profile: profile,
                                              patchNumber: programNumber,
                                              patchId: patch.id,
                                              override: override,
                                              experimentalEnabled: true,
                                            );
                                      } catch (error) {
                                        if (context.mounted) {
                                          showFailureSnackBar(context, error);
                                        }
                                      }
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
