import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../pedals/data/pedal_draft.dart';
import '../../pedals/widgets/pedal_form.dart';
import '../providers/patch_editor.dart';

/// Adds a pedal to one scene: named, filed, and inside the unit the scene is on.
///
/// The pedals feature's own form, opened with the unit as its host, which is what
/// reduces it to a name and a category - a block of a unit carries no brand,
/// purchase date, status or photo of its own.
///
/// Saving lands on the new pedal, because setting its controls is what the user
/// does next and this is the screen those are on.
class ScenePedalFormScreen extends ConsumerStatefulWidget {
  const ScenePedalFormScreen({
    required this.pedalId,
    required this.patchId,
    required this.sceneId,
    super.key,
  });

  /// The unit, which is what the new pedal goes inside.
  final int pedalId;
  final int patchId;
  final int sceneId;

  @override
  ConsumerState<ScenePedalFormScreen> createState() =>
      _ScenePedalFormScreenState();
}

class _ScenePedalFormScreenState extends ConsumerState<ScenePedalFormScreen> {
  bool _isSaving = false;

  Future<void> _save(PedalDraft draft) async {
    setState(() => _isSaving = true);

    try {
      final pedalId = await ref
          .read(patchEditorProvider)
          .addNewPedal(draft, sceneId: widget.sceneId);
      if (mounted) {
        context.go(Routes.pedalDetail(pedalId));
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        showFailureSnackBar(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add pedal to scene')),
      body: PedalForm(
        submitLabel: 'Add pedal',
        hostPedalId: widget.pedalId,
        isSaving: _isSaving,
        onSubmit: _save,
      ),
    );
  }
}
