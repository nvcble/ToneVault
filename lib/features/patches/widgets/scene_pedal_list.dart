import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/async_list_section.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../../shared/widgets/named_tile.dart';
import '../providers/patch_editor.dart';
import '../providers/patch_providers.dart';
import 'pick_scene_pedal_sheet.dart';

/// The pedals one scene uses, picked from the ones inside the unit.
///
/// A row opens the pedal itself, because that is where its controls, its
/// configurations and its history are. Taking it out is a change to this scene
/// only: the pedal belongs to the unit, and another scene may still use it.
class ScenePedalList extends ConsumerWidget {
  const ScenePedalList({
    required this.pedalId,
    required this.sceneId,
    super.key,
  });

  /// The unit, which is where the pedals a scene may use come from.
  final int pedalId;
  final int sceneId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncListSection<Pedal>(
      items: ref.watch(scenePedalListProvider(sceneId)),
      errorTitle: 'Could not load the pedals in this scene',
      empty: const EmptyState(
        icon: Icons.playlist_add,
        title: 'No pedals in this scene',
        message:
            'Pick the ones this part of the song switches on. They come from '
            'the pedals inside the unit.',
      ),
      itemBuilder: (context, pedal) => NamedTile(
        name: pedal.name,
        subtitle: pedal.brand ?? pedal.category.label,
        onTap: () => context.go(Routes.pedalDetail(pedal.id)),
        onRemove: () => _remove(context, ref, pedal),
        removeTooltip: 'Take out of this scene',
      ),
      addLabel: 'Add pedal to scene',
      onAdd: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) =>
            PickScenePedalSheet(pedalId: pedalId, sceneId: sceneId),
      ),
    );
  }

  /// Asks first, because the positions this scene held for the pedal go with it.
  Future<void> _remove(BuildContext context, WidgetRef ref, Pedal pedal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Take out of this scene?'),
        content: Text(
          'Where ${pedal.name}\'s controls sit in this scene is forgotten with '
          'it. The pedal itself stays in the unit, and other scenes keep '
          'their own settings for it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Take out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(patchEditorProvider)
          .removePedal(sceneId: sceneId, pedalId: pedal.id);
    } catch (error) {
      if (context.mounted) {
        showFailureSnackBar(context, error);
      }
    }
  }
}
