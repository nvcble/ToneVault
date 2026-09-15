import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/midi/midi_connection_state.dart';
import '../../../core/midi/midi_device_profile.dart';
import '../../../core/midi/midi_device_registry.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../../shared/widgets/section_label.dart';
import '../providers/midi_connection_controller.dart';
import '../providers/midi_engine_providers.dart';
import '../providers/midi_mapping_providers.dart';
import '../providers/patch_control_providers.dart';
import '../widgets/midi_scene_buttons.dart';
import '../widgets/patch_selection_settings_card.dart';

/// Patch selection (experimental) and Pro Scene switching for one device.
class MidiControlScreen extends ConsumerWidget {
  const MidiControlScreen({required this.profileId, super.key});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = MidiDeviceRegistry.findById(profileId);
    if (profile == null) {
      return const Scaffold(
        body: EmptyState(icon: Icons.error_outline, title: 'Unknown device'),
      );
    }

    final connected =
        ref.watch(midiConnectionProvider(profileId)).state ==
        MidiConnectionState.connected;
    final experimentalEnabled = ref.watch(
      experimentalProgramChangeEnabledProvider,
    );
    final canLoadPatch = connected && experimentalEnabled;
    final currentPatch = ref.watch(currentPatchNumberProvider(profileId));
    final overrideAsync = ref.watch(patchSelectionOverrideProvider(profileId));
    final defaults = profile.patchSelectionDefaults;

    return Scaffold(
      appBar: AppBar(
        title: Text('${profile.displayName} control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'CC mapping',
            onPressed: () => context.push(Routes.midiMapping(profileId)),
          ),
          IconButton(
            icon: const Icon(Icons.terminal),
            tooltip: 'MIDI Monitor',
            onPressed: () => context.push(Routes.midiMonitor(profileId)),
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: FilledButton.icon(
              icon: const Icon(Icons.search),
              label: const Text('Select Patch'),
              onPressed: () => context.push(Routes.midiPatchBrowser(profileId)),
            ),
          ),
          const SectionLabel('Patch selection (experimental)'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable experimental Program Change'),
                  subtitle: const Text(
                    'Unverified against hardware. Watch the MIDI Monitor while testing.',
                  ),
                  value: experimentalEnabled,
                  onChanged: (value) =>
                      ref
                              .read(
                                experimentalProgramChangeEnabledProvider
                                    .notifier,
                              )
                              .state =
                          value,
                ),
                if (defaults != null)
                  overrideAsync.when(
                    data: (override) => PatchSelectionSettingsCard(
                      defaults: defaults,
                      strategyOverride: override,
                      onUsesBankSelectChanged: (value) => ref
                          .read(patchSelectionRepositoryProvider)
                          .setOverride(profile: profile, usesBankSelect: value),
                      onBankSelectMsbChanged: (value) => ref
                          .read(patchSelectionRepositoryProvider)
                          .setOverride(
                            profile: profile,
                            bankSelectMsb: value,
                            clearBankSelectMsb: value == null,
                          ),
                      onBankSelectLsbChanged: (value) => ref
                          .read(patchSelectionRepositoryProvider)
                          .setOverride(
                            profile: profile,
                            bankSelectLsb: value,
                            clearBankSelectLsb: value == null,
                          ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (error, stackTrace) => const SizedBox.shrink(),
                  ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: canLoadPatch
                          ? () => _load(context, ref, profile, currentPatch - 1)
                          : null,
                    ),
                    Expanded(
                      child: Text(
                        'Patch $currentPatch',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: canLoadPatch
                          ? () => _load(context, ref, profile, currentPatch + 1)
                          : null,
                    ),
                  ],
                ),
                FilledButton(
                  onPressed: canLoadPatch
                      ? () => _load(context, ref, profile, currentPatch)
                      : null,
                  child: const Text('Load patch'),
                ),
              ],
            ),
          ),
          const SectionLabel('Scenes'),
          if (!connected)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text('Not connected.'),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: MidiSceneButtons(
              onSelect: connected
                  ? (scene) => _sendScene(context, ref, profile, scene)
                  : null,
            ),
          ),
          const SectionLabel('More'),
          ListTile(
            leading: const Icon(Icons.play_circle_outline),
            title: const Text('Live Control'),
            subtitle: const Text('Large buttons for playing'),
            onTap: () => context.push(Routes.liveControl(profileId)),
          ),
          ListTile(
            leading: const Icon(Icons.folder_copy_outlined),
            title: const Text('Patches'),
            subtitle: const Text('Program numbers, scenes and sending'),
            onTap: () => context.push(Routes.midiPatches(profileId)),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('All parameters'),
            subtitle: const Text('Blocks, models and knobs'),
            onTap: () => context.push(Routes.midiParameters(profileId)),
          ),
        ],
      ),
    );
  }

  Future<void> _load(
    BuildContext context,
    WidgetRef ref,
    MidiDeviceProfile profile,
    int patchNumber,
  ) async {
    if (patchNumber < 1) {
      return;
    }
    try {
      final override = await ref.read(
        patchSelectionOverrideProvider(profileId).future,
      );
      await ref
          .read(patchControlControllerProvider)
          .loadPatch(
            profile: profile,
            patchNumber: patchNumber,
            override: override,
            experimentalEnabled: ref.read(
              experimentalProgramChangeEnabledProvider,
            ),
          );
      ref.read(currentPatchNumberProvider(profileId).notifier).state =
          patchNumber;
    } catch (error) {
      if (context.mounted) showFailureSnackBar(context, error);
    }
  }

  Future<void> _sendScene(
    BuildContext context,
    WidgetRef ref,
    MidiDeviceProfile profile,
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
    } catch (error) {
      if (context.mounted) showFailureSnackBar(context, error);
    }
  }
}
