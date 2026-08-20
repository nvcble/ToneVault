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

/// The patches of one multi-effects unit: the sounds it can be switched to.
class PatchListView extends ConsumerWidget {
  const PatchListView({required this.pedalId, super.key});

  final int pedalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncListSection<Patch>(
      items: ref.watch(patchListProvider(pedalId)),
      errorTitle: 'Could not load the patches',
      empty: const EmptyState(
        icon: Icons.library_music_outlined,
        title: 'No patches yet',
        message:
            'A patch is what the unit is switched to for a song. Each one holds '
            'the scenes you change between while it plays.',
      ),
      itemBuilder: (context, patch) => NamedTile(
        name: patch.name,
        subtitle: patch.notes ?? 'Changed ${formatDate(patch.updatedAt)}',
        onTap: () => context.go(Routes.patchDetail(pedalId, patch.id)),
        onEdit: () => context.go(Routes.patchEdit(pedalId, patch.id)),
      ),
      addLabel: 'Add patch',
      onAdd: () => context.go(Routes.patchNew(pedalId)),
    );
  }
}
