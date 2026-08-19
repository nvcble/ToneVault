import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/pedal_providers.dart';
import '../widgets/pedal_card.dart';

/// The pedal inventory.
class PedalsScreen extends ConsumerWidget {
  const PedalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedals')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(Routes.pedalNew),
        tooltip: 'Add pedal',
        child: const Icon(Icons.add),
      ),
      body: ref
          .watch(pedalListProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load your pedals',
              message: failureMessage(error),
              action: FilledButton(
                onPressed: () => ref.invalidate(pedalListProvider),
                child: const Text('Try again'),
              ),
            ),
            data: (pedals) => pedals.isEmpty
                ? const EmptyState(
                    icon: Icons.tune,
                    title: 'No pedals yet',
                    message:
                        'Add the gear you own to start documenting its '
                        'controls and settings.',
                  )
                : _PedalList(pedals: pedals),
          ),
    );
  }
}

class _PedalList extends StatelessWidget {
  const _PedalList({required this.pedals});

  final List<Pedal> pedals;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Builds rows on demand, so the list stays responsive however large the
      // collection gets.
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        // Clears the floating action button, which would otherwise sit on top
        // of the last card.
        bottom: AppSpacing.xl * 2,
      ),
      itemCount: pedals.length,
      itemBuilder: (context, index) {
        final pedal = pedals[index];
        return PedalCard(
          pedal: pedal,
          onTap: () => context.go(Routes.pedalDetail(pedal.id)),
        );
      },
    );
  }
}
