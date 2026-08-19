import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/configuration_providers.dart';
import '../widgets/configuration_value_list.dart';

/// One configuration: where every control on the pedal is set.
class ConfigurationScreen extends ConsumerWidget {
  const ConfigurationScreen({
    required this.pedalId,
    required this.configurationId,
    super.key,
  });

  final int pedalId;
  final int configurationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configurationValue = ref.watch(
      configurationProvider(configurationId),
    );
    final configuration = configurationValue.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(configuration?.name ?? 'Configuration'),
        actions: configuration == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Rename',
                  onPressed: () => context.go(
                    Routes.configurationEdit(pedalId, configurationId),
                  ),
                ),
              ],
      ),
      body: configurationValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not open this configuration',
          message: failureMessage(error),
        ),
        data: (configuration) => configuration == null
            ? const EmptyState(
                icon: Icons.help_outline,
                title: 'That configuration no longer exists',
                message: 'It may have been deleted on another screen.',
              )
            : Column(
                children: [
                  if (configuration.notes != null) _Notes(configuration.notes!),
                  Expanded(
                    child: ConfigurationValueList(
                      pedalId: pedalId,
                      configurationId: configurationId,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Notes extends StatelessWidget {
  const _Notes(this.notes);

  final String notes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(notes, style: theme.textTheme.bodyMedium),
    );
  }
}
