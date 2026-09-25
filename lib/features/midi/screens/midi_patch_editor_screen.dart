import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/midi/midi_device_registry.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../../shared/widgets/section_label.dart';
import '../../patches/providers/patch_providers.dart';
import '../../pedals/providers/pedal_providers.dart';
import '../providers/midi_device_link_providers.dart';
import '../providers/midi_mapping_providers.dart';
import '../widgets/midi_block_editor_tile.dart';

/// The signal chain of one scene: every block of the unit, on or off, with
/// its knobs one tap away - see section 11 of the MIDI module brief.
///
/// Editing a block's controls only changes what is stored, the same as it
/// would from the Pedals tab's own scene screen. Nothing is sent to the
/// device until "Send to device" is pressed.
class MidiPatchEditorScreen extends ConsumerWidget {
  const MidiPatchEditorScreen({
    required this.profileId,
    required this.patchId,
    required this.sceneId,
    super.key,
  });

  final String profileId;
  final int patchId;
  final int sceneId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = MidiDeviceRegistry.findById(profileId);
    if (profile == null) {
      return const Scaffold(
        body: EmptyState(icon: Icons.error_outline, title: 'Unknown device'),
      );
    }

    final sceneAsync = ref.watch(sceneProvider(sceneId));
    final pedalAsync = ref.watch(linkedPedalProvider(profileId));

    return Scaffold(
      appBar: AppBar(
        title: Text(sceneAsync.valueOrNull?.name ?? 'Patch Editor'),
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
            return const EmptyState(
              icon: Icons.link_off,
              title: 'Not gear yet',
              message: 'Add this device as gear from its Patches screen first.',
            );
          }
          return _SignalChain(
            profileId: profileId,
            sceneId: sceneId,
            unitId: pedal.id,
          );
        },
      ),
    );
  }
}

class _SignalChain extends ConsumerWidget {
  const _SignalChain({
    required this.profileId,
    required this.sceneId,
    required this.unitId,
  });

  final String profileId;
  final int sceneId;
  final int unitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocksAsync = ref.watch(componentPedalListProvider(unitId));
    final enabledAsync = ref.watch(scenePedalListProvider(sceneId));
    final controlsAsync = ref.watch(sceneControlsProvider(sceneId));
    final valuesAsync = ref.watch(sceneValuesProvider(sceneId));

    final blocks = blocksAsync.valueOrNull;
    final enabled = enabledAsync.valueOrNull;
    final groups = controlsAsync.valueOrNull;
    final values = valuesAsync.valueOrNull;
    if (blocks == null || enabled == null || groups == null || values == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final enabledIds = enabled.map((pedal) => pedal.id).toSet();
    final controlsByBlock = {
      for (final group in groups) group.owner.id: group.controls,
    };

    return Column(
      children: [
        const SectionLabel('Signal chain'),
        Expanded(
          child: blocks.isEmpty
              ? const EmptyState(
                  icon: Icons.list_alt,
                  title: 'No blocks yet',
                  message:
                      'This unit has no blocks added to it in the Pedals tab.',
                )
              : ListView(
                  children: [
                    for (final block in blocks)
                      MidiBlockEditorTile(
                        sceneId: sceneId,
                        block: block,
                        isEnabled: enabledIds.contains(block.id),
                        controls: controlsByBlock[block.id] ?? const [],
                        values: values,
                      ),
                  ],
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: FilledButton(
            onPressed: () => _send(context, ref),
            child: const Text('Send to device'),
          ),
        ),
      ],
    );
  }

  Future<void> _send(BuildContext context, WidgetRef ref) async {
    final profile = MidiDeviceRegistry.findById(profileId)!;
    try {
      final parameters = await ref.read(
        effectiveParametersProvider(profileId).future,
      );
      final sent = await ref
          .read(midiSceneSendServiceProvider)
          .sendSceneValues(
            profile: profile,
            effectiveParameters: parameters,
            sceneId: sceneId,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sent $sent value(s).')));
      }
    } catch (error) {
      if (context.mounted) showFailureSnackBar(context, error);
    }
  }
}
