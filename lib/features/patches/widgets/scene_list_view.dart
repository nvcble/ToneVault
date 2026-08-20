import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/formatting/app_date_format.dart';
import '../../../shared/widgets/async_list_section.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/named_tile.dart';
import '../providers/patch_providers.dart';

/// The scenes inside one patch: the sounds within the sound.
class SceneListView extends ConsumerWidget {
  const SceneListView({
    required this.pedalId,
    required this.patchId,
    super.key,
  });

  final int pedalId;
  final int patchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncListSection<Scene>(
      items: ref.watch(sceneListProvider(patchId)),
      errorTitle: 'Could not load the scenes',
      empty: const EmptyState(
        icon: Icons.graphic_eq,
        title: 'No scenes yet',
        message:
            'A scene is one part of the song - a verse, a chorus, a solo. Each '
            'one says which of the unit\'s pedals it uses.',
      ),
      itemBuilder: (context, scene) => NamedTile(
        name: scene.name,
        subtitle: scene.notes ?? 'Changed ${formatDate(scene.updatedAt)}',
        onTap: () => context.go(Routes.sceneDetail(pedalId, patchId, scene.id)),
        onEdit: () => context.go(Routes.sceneEdit(pedalId, patchId, scene.id)),
      ),
      addLabel: 'Add scene',
      onAdd: () => context.go(Routes.sceneNew(pedalId, patchId)),
    );
  }
}
