import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/section_label.dart';
import '../../academy/widgets/academy_action.dart';
import '../../history/providers/history_providers.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/collection_tally_row.dart';
import '../widgets/dashboard_actions.dart';
import '../widgets/latest_changes.dart';

/// The tab the app opens on: what the collection holds, what to do next, and
/// what happened last.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToneVault'),
        actions: const [AcademyAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        children: [
          const SectionLabel('Your collection'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: CollectionTallyRow(
              tally: ref.watch(collectionTallyProvider),
              onOpenPedals: () => context.go(Routes.pedals),
            ),
          ),
          // Above the timeline: on an empty collection this is the only thing
          // worth doing, and on a full one it is still the shortest way in.
          DashboardActions(onAddPedal: () => context.go(Routes.pedalNew)),
          const SectionLabel('Lately'),
          LatestChanges(
            changes: ref.watch(recentHistoryProvider),
            onOpenPedal: (pedalId) => context.go(Routes.pedalDetail(pedalId)),
            onSeeAll: () => context.go(Routes.history),
          ),
        ],
      ),
    );
  }
}
