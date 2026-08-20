import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/patch_draft.dart';
import '../data/patch_validator.dart';
import '../providers/patch_editor.dart';
import '../providers/patch_providers.dart';
import '../widgets/patch_name_form.dart';

/// Adds a scene to [patchId], or renames [sceneId] when one is given.
class SceneFormScreen extends ConsumerStatefulWidget {
  const SceneFormScreen({
    required this.pedalId,
    required this.patchId,
    this.sceneId,
    super.key,
  });

  final int pedalId;
  final int patchId;
  final int? sceneId;

  @override
  ConsumerState<SceneFormScreen> createState() => _SceneFormScreenState();
}

class _SceneFormScreenState extends ConsumerState<SceneFormScreen> {
  static const String _nameHelper = 'A part of the song, such as Verse or Solo';

  bool _isSaving = false;

  bool get _isEditing => widget.sceneId != null;

  Future<void> _save(SceneDraft draft) async {
    setState(() => _isSaving = true);

    try {
      final sceneId = await ref
          .read(patchEditorProvider)
          .saveScene(draft, patchId: widget.patchId, sceneId: widget.sceneId);
      if (mounted) {
        // Straight to the scene, where the pedals it uses are picked.
        context.go(Routes.sceneDetail(widget.pedalId, widget.patchId, sceneId));
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        showFailureSnackBar(context, error);
      }
    }
  }

  Future<void> _confirmDelete(int sceneId) async {
    final name =
        ref.read(sceneProvider(sceneId)).valueOrNull?.name ?? 'this scene';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete scene?'),
        content: Text(
          'Where every control sits in $name is deleted with it. The patch, the '
          'unit and the pedals inside it are untouched.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await ref.read(patchEditorProvider).deleteScene(sceneId);
      if (mounted) {
        context.go(Routes.patchDetail(widget.pedalId, widget.patchId));
      }
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sceneId = widget.sceneId;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit scene' : 'Add scene'),
        actions: sceneId == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: _isSaving ? null : () => _confirmDelete(sceneId),
                ),
              ],
      ),
      body: sceneId == null
          ? PatchNameForm(
              submitLabel: 'Add scene',
              nameHelper: _nameHelper,
              footnote:
                  'A new scene starts out empty. Pick which of the unit\'s '
                  'pedals it uses next.',
              validator: PatchValidator.sceneName,
              isSaving: _isSaving,
              onSubmit: _save,
            )
          : _buildEditBody(sceneId),
    );
  }

  Widget _buildEditBody(int sceneId) {
    return ref
        .watch(sceneProvider(sceneId))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: 'Could not open this scene',
            message: failureMessage(error),
          ),
          data: (scene) {
            if (scene == null) {
              return const EmptyState(
                icon: Icons.help_outline,
                title: 'That scene no longer exists',
              );
            }

            return PatchNameForm(
              // A different scene has to start the fields over; the same one
              // keeps whatever is half-typed.
              key: ValueKey<int>(scene.id),
              initialDraft: PatchDraft.fromScene(scene),
              submitLabel: 'Save changes',
              nameHelper: _nameHelper,
              validator: PatchValidator.sceneName,
              isSaving: _isSaving,
              onSubmit: _save,
            );
          },
        );
  }
}
