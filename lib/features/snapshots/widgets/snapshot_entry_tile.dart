import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/rig_snapshot_dao.dart';
import '../../../core/values/control_options.dart';
import '../../../core/values/control_value_label.dart';

/// One pedal as a snapshot recorded it: where it sat, and what it was set to.
///
/// The readings are the snapshot's own copies, so they read out exactly as they
/// did on the day whatever the pedal has been turned to since. Nothing here is
/// tappable: a record of a day gone by is not something to edit.
class SnapshotEntryTile extends StatelessWidget {
  const SnapshotEntryTile({required this.entry, super.key});

  final SnapshotEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final configurationName = entry.entry.configurationName;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  child: Text(
                    '${entry.entry.position + 1}',
                    style: theme.textTheme.labelMedium,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.pedal.name,
                        style: theme.textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        // The name as it read that day, copied rather than
                        // looked up, so a rename since cannot change it.
                        configurationName ?? 'Settings not recorded',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (entry.values.isNotEmpty) const SizedBox(height: AppSpacing.sm),
            for (final value in entry.values) _Reading(value: value),
          ],
        ),
      ),
    );
  }
}

/// Where one control stood, read in its own notation.
class _Reading extends StatelessWidget {
  const _Reading({required this.value});

  final RigSnapshotValue value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(value.controlName, style: theme.textTheme.bodyMedium),
          ),
          Text(
            formatControlValue(
              value.value,
              type: value.controlType,
              unit: value.unit,
              options: decodeControlOptions(value.options),
            ),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
