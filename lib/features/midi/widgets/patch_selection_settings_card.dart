import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/midi/patch_selection_defaults.dart';

/// The Bank Select / Program Change strategy a patch load will use, and the
/// controls to change it.
class PatchSelectionSettingsCard extends StatelessWidget {
  const PatchSelectionSettingsCard({
    required this.defaults,
    required this.strategyOverride,
    required this.onUsesBankSelectChanged,
    required this.onBankSelectMsbChanged,
    required this.onBankSelectLsbChanged,
    super.key,
  });

  final PatchSelectionDefaults defaults;
  final PatchSelectionOverride? strategyOverride;
  final void Function(bool usesBankSelect) onUsesBankSelectChanged;
  final void Function(int? bankSelectMsb) onBankSelectMsbChanged;
  final void Function(int? bankSelectLsb) onBankSelectLsbChanged;

  @override
  Widget build(BuildContext context) {
    final usesBankSelect =
        strategyOverride?.usesBankSelect ?? defaults.usesBankSelect;
    final bankSelectMsb =
        strategyOverride?.bankSelectMsb ?? defaults.bankSelectMsb;
    final bankSelectLsb =
        strategyOverride?.bankSelectLsb ?? defaults.bankSelectLsb;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Send Bank Select first'),
              value: usesBankSelect,
              onChanged: onUsesBankSelectChanged,
            ),
            Row(
              children: [
                Expanded(
                  child: _NumberField(
                    label: 'Bank Select MSB',
                    value: bankSelectMsb,
                    onChanged: onBankSelectMsbChanged,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _NumberField(
                    label: 'Bank Select LSB',
                    value: bankSelectLsb,
                    onChanged: onBankSelectLsbChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int? value;
  final void Function(int? value) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value?.toString() ?? '',
      decoration: InputDecoration(labelText: label, hintText: 'None'),
      keyboardType: TextInputType.number,
      onFieldSubmitted: (text) =>
          onChanged(text.isEmpty ? null : int.tryParse(text)),
    );
  }
}
