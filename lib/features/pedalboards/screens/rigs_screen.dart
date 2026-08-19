import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/pedalboard_providers.dart';
import '../widgets/rig_card.dart';

/// The rigs built from pedals in the inventory.
class RigsScreen extends ConsumerWidget {
  const RigsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rigs')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(Routes.rigNew),
        tooltip: 'Add rig',
        child: const Icon(Icons.add),
      ),
      body: ref
          .watch(pedalboardListProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load your rigs',
              message: failureMessage(error),
              action: FilledButton(
                onPressed: () => ref.invalidate(pedalboardListProvider),
                child: const Text('Try again'),
              ),
            ),
            data: (pedalboards) => pedalboards.isEmpty
                ? const EmptyState(
                    icon: Icons.dashboard_outlined,
                    title: 'No rigs yet',
                    message:
                        'A rig is an ordered signal chain built from pedals '
                        'you own.',
                  )
                : _RigList(pedalboards: pedalboards),
          ),
    );
  }
}

class _RigList extends StatelessWidget {
  const _RigList({required this.pedalboards});

  final List<Pedalboard> pedalboards;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Builds rows on demand, so the list stays responsive however many rigs
      // there are.
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        // Clears the floating action button, which would otherwise sit on top
        // of the last card.
        bottom: AppSpacing.xl * 2,
      ),
      itemCount: pedalboards.length,
      itemBuilder: (context, index) {
        final pedalboard = pedalboards[index];
        return RigCard(
          pedalboard: pedalboard,
          onTap: () => context.go(Routes.rigDetail(pedalboard.id)),
        );
      },
    );
  }
}
