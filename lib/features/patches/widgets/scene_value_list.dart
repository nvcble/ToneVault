import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../configurations/widgets/value_editor_sheet.dart';
import '../../controls/widgets/control_value_list.dart';
import '../providers/patch_editor.dart';
import '../providers/patch_providers.dart';

/// Where the controls of the pedals in one scene sit.
///
/// A scene holds the positions itself rather than pointing at a configuration of
/// each pedal: the same pedal is in several scenes at different settings, and that
/// is the whole point of scenes.
class SceneValueList extends ConsumerWidget {
  const SceneValueList({required this.sceneId, super.key});

  final int sceneId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // No `ownerToHide`: every control here belongs to a pedal inside the unit,
    // and none of those pedals is the one this screen is about.
    return ControlValueList(
      groups: ref.watch(sceneControlsProvider(sceneId)),
      values: ref.watch(sceneValuesProvider(sceneId)),
      empty: const EmptyState(
        icon: Icons.tune,
        title: 'Nothing to set yet',
        message:
            'A scene sets the controls of the pedals in it. Put pedals in this '
            'scene under Pedals and their controls show up here.',
      ),
      onEdit: (control, storedValue) =>
          _edit(context, ref, control, storedValue),
    );
  }

  /// The sheet only asks for a position; storing it against this scene is here.
  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    PedalControl control,
    double? storedValue,
  ) {
    final editor = ref.read(patchEditorProvider);

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => ValueEditorSheet(
        control: control,
        storedValue: storedValue,
        onSave: (value, reason) => editor.setValue(
          sceneId: sceneId,
          controlId: control.id,
          value: value,
          reason: reason,
        ),
        onClear: (reason) => editor.clearValue(
          sceneId: sceneId,
          controlId: control.id,
          reason: reason,
        ),
      ),
    );
  }
}
