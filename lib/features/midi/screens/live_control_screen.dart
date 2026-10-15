import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/database/daos/midi_patch_program_number_dao.dart';
import '../../../core/midi/midi_connection_state.dart';
import '../../../core/midi/midi_device_profile.dart';
import '../../../core/midi/midi_device_registry.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../../shared/widgets/fill_or_scroll.dart';
import '../../../shared/widgets/page_body.dart';
import '../data/live_control_navigation.dart';
import '../providers/midi_connection_controller.dart';
import '../providers/midi_device_link_providers.dart';
import '../providers/midi_engine_providers.dart';
import '../providers/midi_mapping_providers.dart';
import '../providers/patch_control_providers.dart';
import '../widgets/current_patch_card.dart';
import '../widgets/midi_scene_buttons.dart';
import '../widgets/midi_trigger_controls.dart';

/// A large-button, minimal screen for switching patches and scenes while
/// playing - see section 12 of the MIDI module brief. Nothing here edits
/// anything; that is the Patches/Parameters screens' job.
class LiveControlScreen extends ConsumerWidget {
  const LiveControlScreen({required this.profileId, super.key});

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
      appBar: AppBar(title: const Text('Live Control')),
      body: PageBody(
        child: pedalAsync.when(
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
                message:
                    'Add this device as gear from its Patches screen first.',
              );
            }
            return _LiveControlBody(
              profileId: profileId,
              profile: profile,
              unitId: pedal.id,
            );
          },
        ),
      ),
    );
  }
}

class _LiveControlBody extends ConsumerWidget {
  const _LiveControlBody({
    required this.profileId,
    required this.profile,
    required this.unitId,
  });

  final String profileId;
  final MidiDeviceProfile profile;
  final int unitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connected =
        ref.watch(midiConnectionProvider(profileId)).state ==
        MidiConnectionState.connected;
    final patchesAsync = ref.watch(numberedPatchesProvider(unitId));

    return patchesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => EmptyState(
        icon: Icons.error_outline,
        title: 'Could not load patches',
        message: failureMessage(error),
      ),
      data: (patches) {
        if (patches.isEmpty) {
          return const EmptyState(
            icon: Icons.list_alt,
            title: 'No numbered patches yet',
            message:
                'Give at least one patch a program number on the Patches screen.',
          );
        }

        final currentNumber = ref.watch(currentPatchNumberProvider(profileId));
        final current = patches
            .where((p) => p.programNumber == currentNumber)
            .firstOrNull;
        final currentScene = ref.watch(currentSceneNumberProvider(profileId));
        final canAct =
            connected && ref.watch(experimentalProgramChangeEnabledProvider);

        // The patch at the top and the controls at the foot, with the room
        // between them going into the gap - and scrolling instead of
        // overflowing on a screen too short for all of it, which is any phone
        // held sideways.
        return FillOrScroll(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!connected)
                      const Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.md),
                        child: Text('Not connected.'),
                      ),
                    CurrentPatchCard(
                      current: current,
                      onChangePatch: () =>
                          context.push(Routes.midiPatchBrowser(profileId)),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MidiSceneButtons(
                      selectedScene: currentScene,
                      onSelect: canAct
                          ? (scene) => _sendScene(context, ref, scene)
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // The same row and the same buttons as the scenes above
                    // them, so the two sit together as one block of controls.
                    MidiTriggerRow(
                      children: [
                        MidiTriggerButton(
                          label: 'Previous patch',
                          onPressed: canAct
                              ? () => _step(context, ref, patches, current, -1)
                              : null,
                        ),
                        MidiTriggerButton(
                          label: 'Next patch',
                          onPressed: canAct
                              ? () => _step(context, ref, patches, current, 1)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _step(
    BuildContext context,
    WidgetRef ref,
    List<NumberedPatch> patches,
    NumberedPatch? current,
    int direction,
  ) async {
    final target = nextLiveControlPatch(
      patches: patches,
      current: current,
      direction: direction,
    );
    if (target != null) {
      await _load(context, ref, target);
    }
  }

  Future<void> _load(
    BuildContext context,
    WidgetRef ref,
    NumberedPatch target,
  ) async {
    try {
      final override = await ref.read(
        patchSelectionOverrideProvider(profileId).future,
      );
      await ref
          .read(patchControlControllerProvider)
          .loadPatch(
            profile: profile,
            patchNumber: target.programNumber,
            patchId: target.patch.id,
            override: override,
            experimentalEnabled: true,
          );
      ref.read(currentPatchNumberProvider(profileId).notifier).state =
          target.programNumber;
    } catch (error) {
      if (context.mounted) showFailureSnackBar(context, error);
    }
  }

  Future<void> _sendScene(
    BuildContext context,
    WidgetRef ref,
    int scene,
  ) async {
    try {
      final parameters = await ref.read(
        effectiveParametersProvider(profileId).future,
      );
      await ref
          .read(midiParameterSenderProvider)
          .send(
            profile: profile,
            effectiveParameters: parameters,
            parameterName: 'Scene',
            value: scene - 1,
          );
      ref.read(currentSceneNumberProvider(profileId).notifier).state = scene;
    } catch (error) {
      if (context.mounted) showFailureSnackBar(context, error);
    }
  }
}
