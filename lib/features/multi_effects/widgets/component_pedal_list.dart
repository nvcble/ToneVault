import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../pedals/providers/pedal_providers.dart';
import '../../pedals/widgets/pedal_card.dart';

/// The pedals inside one multi-effects unit, whatever that unit calls them.
///
/// Each one is an ordinary pedal row, so tapping it opens the same detail screen
/// as any pedal on the floor - controls, configurations and history included -
/// and this list only has to get the user there.
class ComponentPedalList extends ConsumerWidget {
  const ComponentPedalList({
    required this.hostPedalId,
    required this.addLabel,
    required this.emptyMessage,
    super.key,
  });

  final int hostPedalId;

  /// The words the hosting mode uses, so one list serves both stomps and the
  /// pedals on a patch.
  final String addLabel;
  final String emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final components = ref.watch(componentPedalListProvider(hostPedalId));

    return Column(
      children: [
        Expanded(
          child: components.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load what is inside this unit',
              message: failureMessage(error),
            ),
            data: (components) => components.isEmpty
                ? EmptyState(
                    icon: Icons.dashboard_customize_outlined,
                    title: 'Nothing inside yet',
                    message: emptyMessage,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    itemCount: components.length,
                    itemBuilder: (context, index) {
                      final component = components[index];
                      return PedalCard(
                        pedal: component,
                        onTap: () =>
                            context.go(Routes.pedalDetail(component.id)),
                      );
                    },
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.go(Routes.componentNew(hostPedalId)),
              icon: const Icon(Icons.add),
              label: Text(addLabel),
            ),
          ),
        ),
      ],
    );
  }
}
