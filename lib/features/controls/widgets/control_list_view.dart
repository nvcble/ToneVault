import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/control_providers.dart';
import 'reorderable_control_list.dart';

/// The controls section of a pedal: what the pedal can be set to.
class ControlListView extends ConsumerWidget {
  const ControlListView({required this.pedalId, super.key});

  final int pedalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controls = ref.watch(controlListProvider(pedalId));

    return Column(
      children: [
        Expanded(
          child: controls.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load the controls',
              message: failureMessage(error),
            ),
            data: (controls) => controls.isEmpty
                ? const EmptyState(
                    icon: Icons.tune,
                    title: 'No controls yet',
                    message:
                        'Add one for every knob and switch on the pedal, and '
                        'configurations will ask for each of them.',
                  )
                : ReorderableControlList(
                    pedalId: pedalId,
                    controls: controls,
                    onEdit: (control) =>
                        context.go(Routes.controlEdit(pedalId, control.id)),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.go(Routes.controlNew(pedalId)),
              icon: const Icon(Icons.add),
              label: const Text('Add control'),
            ),
          ),
        ),
      ],
    );
  }
}
