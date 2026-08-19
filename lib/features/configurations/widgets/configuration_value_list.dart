import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/values/control_options.dart';
import '../../../core/values/control_value_label.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../controls/providers/control_providers.dart';
import '../providers/configuration_providers.dart';
import 'value_editor_sheet.dart';

/// Where every control on the pedal sits in one configuration.
///
/// The pedal's controls drive the list, in their own display order, and each is
/// looked up in the stored values. A control with nothing stored reads as unset
/// rather than as its default, because a configuration that does not say where a
/// knob goes has not been finished.
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
    final controls = ref.watch(controlListProvider(pedalId));
    final values = ref.watch(configurationValuesProvider(configurationId));

    final error = controls.error ?? values.error;
    if (error != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Could not load these settings',
        message: failureMessage(error),
      );
    }

    final controlList = controls.valueOrNull;
    final valueMap = values.valueOrNull;
    if (controlList == null || valueMap == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controlList.isEmpty) {
      return const EmptyState(
        icon: Icons.tune,
        title: 'This pedal has no controls yet',
        message:
            'Add the pedal\'s knobs and switches on the Controls tab, and they '
            'will show up here to be set.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      itemCount: controlList.length,
      itemBuilder: (context, index) {
        final control = controlList[index];
        return _ValueRow(
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
    required this.control,
    required this.storedValue,
    required this.onTap,
  });

  final PedalControl control;
  final double? storedValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = storedValue;

    return ListTile(
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
  }
}
