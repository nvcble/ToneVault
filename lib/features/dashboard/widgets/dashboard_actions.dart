import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

/// The thing a person does most, without hunting for the right tab first.
///
/// Full width rather than sitting in a row: a button cannot crowd its own label
/// off the edge on a narrow phone.
class DashboardActions extends StatelessWidget {
  const DashboardActions({this.onAddPedal, super.key});

  final VoidCallback? onAddPedal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: FilledButton.icon(
        onPressed: onAddPedal,
        icon: const Icon(Icons.add),
        label: const Text('Add a pedal'),
      ),
    );
  }
}
