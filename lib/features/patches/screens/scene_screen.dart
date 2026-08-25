import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../../shared/widgets/notes_banner.dart';
import '../../../shared/widgets/segmented_switch.dart';
import '../providers/patch_providers.dart';
import '../widgets/scene_pedal_list.dart';
import '../widgets/scene_value_list.dart';

/// One scene: where the controls of the pedals this part of the song uses sit.
///
/// Settings come first and the pedals are behind the switch: which pedals a
/// scene uses is decided once, and where their controls sit is what the user
/// comes back to. This is the only place the unit's pedals are managed.
class SceneScreen extends ConsumerStatefulWidget {
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
  ConsumerState<SceneScreen> createState() => _SceneScreenState();
}

class _SceneScreenState extends ConsumerState<SceneScreen> {
  bool _showingPedals = false;

  @override
  Widget build(BuildContext context) {
    final sceneValue = ref.watch(sceneProvider(widget.sceneId));
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
                  onPressed: () => context.go(
                    Routes.sceneEdit(
                      widget.pedalId,
                      widget.patchId,
                      widget.sceneId,
                    ),
                  ),
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
            : _buildScene(scene),
      ),
    );
  }

  Widget _buildScene(Scene scene) {
    return Column(
      children: [
        if (scene.notes != null) NotesBanner(scene.notes!),
        Expanded(
          child: SegmentedSwitch(
            firstLabel: 'Settings',
            secondLabel: 'Pedals',
            showingSecond: _showingPedals,
            onChanged: (showingPedals) =>
                setState(() => _showingPedals = showingPedals),
            child: _showingPedals
                ? ScenePedalList(
                    pedalId: widget.pedalId,
                    patchId: widget.patchId,
                    sceneId: widget.sceneId,
                  )
                : SceneValueList(sceneId: widget.sceneId),
          ),
        ),
      ],
    );
  }
}
