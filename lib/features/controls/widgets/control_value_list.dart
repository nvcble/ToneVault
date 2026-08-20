import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/values/control_options.dart';
import '../../../core/values/control_value_label.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../../shared/widgets/section_label.dart';
import '../data/control_group.dart';

/// One row of the list: a control to set, named under its own pedal when that is
/// not the pedal the screen is already about.
typedef _ValueEntry = ({String? owner, PedalControl control});

/// Where a set of controls sits, whatever it is that holds those positions.
///
/// The controls drive the list, in their own display order, and each is looked up
/// in [values]. A control with nothing stored reads as unset rather than as its
/// default, because a setting that does not say where a knob goes has not been
/// made.
///
/// Where the controls come from several pedals, each pedal is named above the
/// controls that belong to it.
///
/// Kept for tracking: `ConfigurationValueList` spells this out inline. It is left
/// as it is rather than changed under working, tested code; anything new uses
/// this instead of adding another copy.
class ControlValueList extends StatelessWidget {
  const ControlValueList({
    required this.groups,
    required this.values,
    required this.empty,
    required this.onEdit,
    this.ownerToHide,
    super.key,
  });

  final AsyncValue<List<ControlGroup>> groups;

  /// The stored positions, by control id; a control missing from it is unset.
  final AsyncValue<Map<int, double>> values;

  /// Shown when there is not one control to set.
  final Widget empty;

  /// A pedal whose name the rows leave out, because the screen already says it.
  /// Null names every pedal.
  final int? ownerToHide;

  final void Function(PedalControl control, double? storedValue) onEdit;

  @override
  Widget build(BuildContext context) {
    final error = groups.error ?? values.error;
    if (error != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Could not load these settings',
        message: failureMessage(error),
      );
    }

    final groupList = groups.valueOrNull;
    final valueMap = values.valueOrNull;
    if (groupList == null || valueMap == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (groupList.isEmpty) {
      return empty;
    }

    final entries = <_ValueEntry>[
      for (final group in groupList)
        for (final (index, control) in group.controls.indexed)
          (
            // Only above the first control of a pedal; see [_ValueEntry].
            owner: index == 0 && group.owner.id != ownerToHide
                ? group.owner.name
                : null,
            control: control,
          ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final control = entry.control;
        final storedValue = valueMap[control.id];
        return _ValueRow(
          owner: entry.owner,
          control: control,
          storedValue: storedValue,
          onTap: () => onEdit(control, storedValue),
        );
      },
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.owner,
    required this.control,
    required this.storedValue,
    required this.onTap,
  });

  /// The pedal this control is on, when it is worth naming; see [_ValueEntry].
  final String? owner;
  final PedalControl control;
  final double? storedValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = storedValue;

    final tile = ListTile(
      title: Text(control.name),
      subtitle: Text(control.controlType.label),
      trailing: Text(
        value == null
            ? 'Not set'
            : formatControlValue(
                value,
                type: control.controlType,
                unit: control.unit,
                options: decodeControlOptions(control.options),
              ),
        style: theme.textTheme.titleMedium?.copyWith(
          color: value == null
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.primary,
        ),
      ),
      onTap: onTap,
    );

    final heading = owner;
    if (heading == null) {
      return tile;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [SectionLabel(heading), tile],
    );
  }
}
