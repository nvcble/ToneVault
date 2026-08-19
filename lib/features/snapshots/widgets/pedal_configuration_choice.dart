import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../configurations/providers/configuration_providers.dart';

/// Which configuration one pedal was set to when the snapshot was taken.
///
/// "Not recorded" is a real answer and the one it starts on: a wah has no preset
/// worth naming, and a pedal whose settings nobody wrote down should not be
/// given some other day's readings by default.
class PedalConfigurationChoice extends ConsumerWidget {
  const PedalConfigurationChoice({
    required this.pedal,
    required this.position,
    required this.configurationId,
    required this.onChanged,
    super.key,
  });

  final Pedal pedal;

  /// Zero-based place in the chain, shown one-based.
  final int position;
  final int? configurationId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configurations =
        ref.watch(configurationListProvider(pedal.id)).valueOrNull ?? const [];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: DropdownButtonFormField<int?>(
        // A configuration deleted while this screen sat open is no longer a
        // choice, so the field falls back to "Not recorded" rather than holding
        // an id the dropdown cannot show.
        initialValue: configurations.any((one) => one.id == configurationId)
            ? configurationId
            : null,
        decoration: InputDecoration(
          labelText: '${position + 1}. ${pedal.name}',
          helperText: configurations.isEmpty
              ? 'This pedal has no configurations to record'
              : null,
        ),
        items: [
          const DropdownMenuItem<int?>(child: Text('Not recorded')),
          for (final configuration in configurations)
            DropdownMenuItem<int?>(
              value: configuration.id,
              child: Text(configuration.name),
            ),
        ],
        onChanged: configurations.isEmpty ? null : onChanged,
      ),
    );
  }
}
