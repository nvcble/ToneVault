import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/configuration_providers.dart';
import 'configuration_tile.dart';

/// The configurations section of a pedal: the settings worth keeping.
class ConfigurationListView extends ConsumerWidget {
  const ConfigurationListView({required this.pedalId, super.key});

  final int pedalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configurations = ref.watch(configurationListProvider(pedalId));

    return Column(
      children: [
        Expanded(
          child: configurations.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load the configurations',
              message: failureMessage(error),
            ),
            data: (configurations) => configurations.isEmpty
                ? const EmptyState(
                    icon: Icons.bookmark_border,
                    title: 'No configurations yet',
                    message:
                        'Save one for every setting you want to come back to, '
                        'such as a rhythm sound and a lead sound.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    itemCount: configurations.length,
                    itemBuilder: (context, index) {
                      final configuration = configurations[index];
                      return ConfigurationTile(
                        configuration: configuration,
                        onTap: () => context.go(
                          Routes.configurationDetail(pedalId, configuration.id),
                        ),
                        onEdit: () => context.go(
                          Routes.configurationEdit(pedalId, configuration.id),
                        ),
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
              onPressed: () => context.go(Routes.configurationNew(pedalId)),
              icon: const Icon(Icons.add),
              label: const Text('Add configuration'),
            ),
          ),
        ),
      ],
    );
  }
}
