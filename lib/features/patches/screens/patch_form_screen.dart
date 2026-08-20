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

/// Adds a patch to [pedalId], or renames [patchId] when one is given.
class PatchFormScreen extends ConsumerStatefulWidget {
  const PatchFormScreen({required this.pedalId, this.patchId, super.key});

  final int pedalId;
  final int? patchId;

  @override
  ConsumerState<PatchFormScreen> createState() => _PatchFormScreenState();
}

class _PatchFormScreenState extends ConsumerState<PatchFormScreen> {
  bool _isSaving = false;

  bool get _isEditing => widget.patchId != null;

  Future<void> _save(PatchDraft draft) async {
    setState(() => _isSaving = true);

    try {
      final patchId = await ref
          .read(patchEditorProvider)
          .savePatch(draft, pedalId: widget.pedalId, patchId: widget.patchId);
      if (mounted) {
        // Straight to its scenes, which is what a new patch is for.
        context.go(Routes.patchDetail(widget.pedalId, patchId));
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        showFailureSnackBar(context, error);
      }
    }
  }

  Future<void> _confirmDelete(int patchId) async {
    final name =
        ref.read(patchProvider(patchId)).valueOrNull?.name ?? 'this patch';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete patch?'),
        content: Text(
          'Every scene under $name is deleted with it, and the positions those '
          'scenes held. The unit and the pedals inside it are untouched.',
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
      await ref.read(patchEditorProvider).deletePatch(patchId);
      if (mounted) {
        context.go(Routes.pedalDetail(widget.pedalId));
      }
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final patchId = widget.patchId;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit patch' : 'Add patch'),
        actions: patchId == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: _isSaving ? null : () => _confirmDelete(patchId),
                ),
              ],
      ),
      body: patchId == null
          ? PatchNameForm(
              submitLabel: 'Add patch',
              nameHelper: 'What the unit is switched to, such as Worship Clean',
              footnote:
                  'A new patch starts out with no scenes. Add one for each part '
                  'of the song you change between.',
              validator: PatchValidator.patchName,
              isSaving: _isSaving,
              onSubmit: _save,
            )
          : _buildEditBody(patchId),
    );
  }

  Widget _buildEditBody(int patchId) {
    return ref
        .watch(patchProvider(patchId))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            icon: Icons.error_outline,
            title: 'Could not open this patch',
            message: failureMessage(error),
          ),
          data: (patch) {
            if (patch == null) {
              return const EmptyState(
                icon: Icons.help_outline,
                title: 'That patch no longer exists',
              );
            }

            return PatchNameForm(
              // A different patch has to start the fields over; the same one
              // keeps whatever is half-typed.
              key: ValueKey<int>(patch.id),
              initialDraft: PatchDraft.fromPatch(patch),
              submitLabel: 'Save changes',
              nameHelper: 'What the unit is switched to, such as Worship Clean',
              validator: PatchValidator.patchName,
              isSaving: _isSaving,
              onSubmit: _save,
            );
          },
        );
  }
}
