import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../pedals/providers/pedal_providers.dart';
import '../providers/patch_editor.dart';
import '../providers/patch_providers.dart';

/// What to put in a scene: a pedal entered here and then, of the unit's pedals,
/// the ones this scene does not already use.
///
/// A new pedal comes first, because that is the ordinary way a scene is filled in.
/// Picking is for the pedal that is already in the unit and belongs in this sound
/// too - the same row of gear reached from both, rather than a second copy of it.
///
/// A pedal already in the scene is not offered: adding it twice is refused by the
/// repository, and offering it anyway is an invitation to be refused. Each arrives
/// at whatever defaults its controls declare, which the user then moves on the
/// scene's own screen.
class PickScenePedalSheet extends ConsumerWidget {
  const PickScenePedalSheet({
    required this.pedalId,
    required this.patchId,
    required this.sceneId,
    super.key,
  });

  /// The unit, whose pedals are the only ones a scene may reach for.
  final int pedalId;

  /// Only to build the route to the form: a scene is reached through its patch.
  final int patchId;
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
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New pedal'),
              subtitle: const Text(
                'Name it and file it, then set its controls',
              ),
              onTap: () => _addNew(context),
            ),
            const Divider(height: 1),
            if (available.isEmpty)
              EmptyState(
                icon: Icons.done_all,
                title: inside.isEmpty
                    ? 'Nothing inside this unit yet'
                    : 'Every pedal is already in this scene',
                message: 'Add a new pedal above to put one in this scene.',
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

  /// The form is a screen rather than more of this sheet: a pedal has a name and
  /// a category to enter, and it is the pedals feature's own form that asks for
  /// them.
  void _addNew(BuildContext context) {
    Navigator.pop(context);
    context.go(Routes.scenePedalNew(pedalId, patchId, sceneId));
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
