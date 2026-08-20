import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/values/control_options.dart';
import '../../../core/values/control_value_label.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../../shared/widgets/section_label.dart';
import '../../controls/providers/control_providers.dart';
import '../providers/configuration_providers.dart';
import 'value_editor_sheet.dart';

/// One row of the list: a control to set, named under its own pedal when that is
/// not the pedal being configured.
typedef _ValueEntry = ({String? owner, PedalControl control});

/// Where every control this configuration covers sits.
///
/// The controls drive the list, in their own display order, and each is looked up
/// in the stored values. A control with nothing stored reads as unset rather than
/// as its default, because a configuration that does not say where a knob goes
/// has not been finished.
///
/// For an ordinary pedal those are its own controls and the list is flat. For a
/// multi-effects unit in scene mode they are the controls of the pedals on its
/// patch, so each pedal is named above the controls that belong to it.
class ConfigurationValueList extends ConsumerWidget {
  const ConfigurationValueList({
    required this.pedalId,
    required this.configurationId,
    super.key,
  });

  final int pedalId;
  final int configurationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(settableControlsProvider(pedalId));
    final values = ref.watch(configurationValuesProvider(configurationId));

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
      return const EmptyState(
        icon: Icons.tune,
        title: 'Nothing to set yet',
        message:
            'A configuration sets the controls of the pedal it is on, and of the '
            'pedals inside it. Add those controls and they will show up here.',
      );
    }

    final entries = <_ValueEntry>[
      for (final group in groupList)
        for (final (index, control) in group.controls.indexed)
          (
            // Only above the first control of a pedal, and never for the pedal
            // being configured: that one is already the title of the screen.
            owner: index == 0 && group.owner.id != pedalId
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
        return _ValueRow(
          owner: entry.owner,
          control: control,
          storedValue: valueMap[control.id],
          onTap: () => _edit(context, control, valueMap[control.id]),
        );
      },
    );
  }

  Future<void> _edit(
    BuildContext context,
    PedalControl control,
    double? storedValue,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => ValueEditorSheet(
        configurationId: configurationId,
        control: control,
        storedValue: storedValue,
      ),
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
