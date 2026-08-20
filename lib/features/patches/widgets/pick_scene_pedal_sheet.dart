import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../pedals/providers/pedal_providers.dart';
import '../providers/patch_editor.dart';
import '../providers/patch_providers.dart';

/// Which of the unit's pedals to add to a scene.
///
/// Only the ones it does not already use are offered: adding a pedal twice is
/// refused by the repository, and offering it anyway is an invitation to be
/// refused. Each arrives at whatever defaults its controls declare, which the
/// user then moves on the scene's own screen.
class PickScenePedalSheet extends ConsumerWidget {
  const PickScenePedalSheet({
    required this.pedalId,
    required this.sceneId,
    super.key,
  });

  /// The unit, whose pedals are the only ones a scene may reach for.
  final int pedalId;
  final int sceneId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inside =
        ref.watch(componentPedalListProvider(pedalId)).valueOrNull ?? const [];
    final used = ref.watch(scenePedalListProvider(sceneId)).valueOrNull;
    final usedIds = {for (final pedal in used ?? const <Pedal>[]) pedal.id};
    final available = [
      for (final pedal in inside)
        if (!usedIds.contains(pedal.id)) pedal,
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add a pedal to this scene',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (available.isEmpty)
              EmptyState(
                icon: Icons.done_all,
                title: inside.isEmpty
                    ? 'Nothing inside this unit yet'
                    : 'Every pedal is already in this scene',
                message: inside.isEmpty
                    ? 'Add the pedals the unit holds on its Patch tab first, '
                          'under Pedals.'
                    : null,
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final pedal in available)
                      ListTile(
                        title: Text(pedal.name),
                        subtitle: Text(pedal.brand ?? pedal.category.label),
                        onTap: () => _add(context, ref, pedal.id),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref, int chosen) async {
    // Closed first, so the sheet is not left over a scene that has changed
    // behind it. A refusal is reported on the screen underneath.
    Navigator.pop(context);

    try {
      await ref
          .read(patchEditorProvider)
          .addPedal(sceneId: sceneId, pedalId: chosen);
    } catch (error) {
      if (context.mounted) {
        showFailureSnackBar(context, error);
      }
    }
  }
}
