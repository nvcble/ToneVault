import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../../shared/widgets/notes_banner.dart';
import '../providers/patch_providers.dart';
import '../widgets/scene_list_view.dart';

/// One patch: the scenes it holds.
class PatchScreen extends ConsumerWidget {
  const PatchScreen({required this.pedalId, required this.patchId, super.key});

  final int pedalId;
  final int patchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patchValue = ref.watch(patchProvider(patchId));
    final patch = patchValue.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(patch?.name ?? 'Patch'),
        actions: patch == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Rename',
                  onPressed: () =>
                      context.go(Routes.patchEdit(pedalId, patchId)),
                ),
              ],
      ),
      body: patchValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not open this patch',
          message: failureMessage(error),
        ),
        data: (patch) => patch == null
            ? const EmptyState(
                icon: Icons.help_outline,
                title: 'That patch no longer exists',
                message: 'It may have been deleted on another screen.',
              )
            : Column(
                children: [
                  if (patch.notes != null) NotesBanner(patch.notes!),
                  Expanded(
                    child: SceneListView(pedalId: pedalId, patchId: patchId),
                  ),
                ],
              ),
      ),
    );
  }
}
