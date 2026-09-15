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
import '../providers/midi_engine_providers.dart';
import '../providers/midi_mapping_providers.dart';
import '../widgets/midi_number_field.dart';

/// One patch's scenes: which Pro Scene slot each sends as, and the actions to
/// send that scene or the values it holds.
class MidiPatchScenesScreen extends ConsumerWidget {
  const MidiPatchScenesScreen({
    required this.profileId,
    required this.patchId,
    super.key,
  });

  final String profileId;
  final int patchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = MidiDeviceRegistry.findById(profileId);
    if (profile == null) {
      return const Scaffold(
        body: EmptyState(icon: Icons.error_outline, title: 'Unknown device'),
      );
    }

    final scenesAsync = ref.watch(sceneListProvider(patchId));
    final connected =
        ref.watch(midiConnectionProvider(profileId)).state ==
        MidiConnectionState.connected;

    return Scaffold(
      appBar: AppBar(title: const Text('Scenes')),
      body: scenesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load scenes',
          message: failureMessage(error),
        ),
        data: (scenes) => scenes.isEmpty
            ? const EmptyState(
                icon: Icons.list_alt,
                title: 'No scenes yet',
                message: 'Add scenes for this patch from the Pedals tab.',
              )
            : ListView.builder(
                itemCount: scenes.length,
                itemBuilder: (context, index) {
                  final scene = scenes[index];
                  final numberAsync = ref.watch(sceneNumberProvider(scene.id));
                  final sceneNumber = numberAsync.valueOrNull?.sceneNumber;

                  return ListTile(
                    title: Text(scene.name),
                    subtitle: const Text('Tap to edit its blocks'),
                    onTap: () => context.push(
                      Routes.midiSceneEditor(profileId, patchId, scene.id),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MidiNumberField(
                          value: sceneNumber,
                          onChanged: (number) async {
                            try {
                              await ref
                                  .read(midiSceneNumberRepositoryProvider)
                                  .setNumber(
                                    patchId: patchId,
                                    sceneId: scene.id,
                                    sceneNumber: number,
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
                          icon: const Icon(Icons.sync_alt),
                          tooltip: 'Send this scene',
                          onPressed: connected && sceneNumber != null
                              ? () async {
                                  try {
                                    final parameters = await ref.read(
                                      effectiveParametersProvider(
                                        profileId,
                                      ).future,
                                    );
                                    await ref
                                        .read(midiParameterSenderProvider)
                                        .send(
                                          profile: profile,
                                          effectiveParameters: parameters,
                                          parameterName: 'Scene',
                                          value: sceneNumber - 1,
                                        );
                                  } catch (error) {
                                    if (context.mounted) {
                                      showFailureSnackBar(context, error);
                                    }
                                  }
                                }
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.upload),
                          tooltip: 'Send this scene\'s block values',
                          onPressed: !connected
                              ? null
                              : () async {
                                  try {
                                    final parameters = await ref.read(
                                      effectiveParametersProvider(
                                        profileId,
                                      ).future,
                                    );
                                    final sent = await ref
                                        .read(midiSceneSendServiceProvider)
                                        .sendSceneValues(
                                          profile: profile,
                                          effectiveParameters: parameters,
                                          sceneId: scene.id,
                                        );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Sent $sent value(s).'),
                                        ),
                                      );
                                    }
                                  } catch (error) {
                                    if (context.mounted) {
                                      showFailureSnackBar(context, error);
                                    }
                                  }
                                },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
