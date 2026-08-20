import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/section_label.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/collection_tally_row.dart';

/// The tab the app opens on: what the collection holds, and the way into it.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('ToneVault')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        children: [
          const SectionLabel('Your collection'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: CollectionTallyRow(
              tally: ref.watch(collectionTallyProvider),
              onOpenPedals: () => context.go(Routes.pedals),
              onOpenRigs: () => context.go(Routes.rigs),
            ),
          ),
        ],
      ),
    );
  }
}
