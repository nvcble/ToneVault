import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/pedal_filter.dart';
import '../providers/pedal_filter_providers.dart';
import '../providers/pedal_providers.dart';
import '../widgets/pedal_card.dart';
import '../widgets/pedal_filter_bar.dart';

/// The pedal inventory, with a way to narrow it down.
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
          .watch(pedalSearchProvider)
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
            data: (search) => _Inventory(search: search),
          ),
    );
  }
}

/// The filter bar and the list under it, or a placeholder in place of both.
class _Inventory extends ConsumerWidget {
  const _Inventory({required this.search});

  final PedalSearch search;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Nothing owned at all: a search box over an empty collection would only be
    // in the way.
    if (search.total == 0) {
      return const EmptyState(
        icon: Icons.tune,
        title: 'No pedals yet',
        message:
            'Add the gear you own to start documenting its '
            'controls and settings.',
      );
    }

    return Column(
      children: [
        PedalFilterBar(search: search),
        Expanded(
          child: search.matches.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  title: 'No pedals match',
                  message:
                      'All ${search.total} of your pedals are still here; '
                      'this search just does not reach them.',
                  action: FilledButton(
                    onPressed: () =>
                        ref.read(pedalFilterProvider.notifier).state =
                            everyPedal,
                    child: const Text('Clear filters'),
                  ),
                )
              : _PedalList(pedals: search.matches),
        ),
      ],
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
