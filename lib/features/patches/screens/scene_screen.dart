import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../../shared/widgets/notes_banner.dart';
import '../providers/patch_providers.dart';
import '../widgets/scene_pedal_list.dart';

/// One scene: which of the unit's pedals this part of the song uses.
class SceneScreen extends ConsumerWidget {
  const SceneScreen({
    required this.pedalId,
    required this.patchId,
    required this.sceneId,
    super.key,
  });

  final int pedalId;
  final int patchId;
  final int sceneId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sceneValue = ref.watch(sceneProvider(sceneId));
    final scene = sceneValue.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(scene?.name ?? 'Scene'),
        actions: scene == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Rename',
                  onPressed: () =>
                      context.go(Routes.sceneEdit(pedalId, patchId, sceneId)),
                ),
              ],
      ),
      body: sceneValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not open this scene',
          message: failureMessage(error),
        ),
        data: (scene) => scene == null
            ? const EmptyState(
                icon: Icons.help_outline,
                title: 'That scene no longer exists',
                message: 'It may have been deleted on another screen.',
              )
            : Column(
                children: [
                  if (scene.notes != null) NotesBanner(scene.notes!),
                  Expanded(
                    child: ScenePedalList(pedalId: pedalId, sceneId: sceneId),
                  ),
                ],
              ),
      ),
    );
  }
}
