import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

/// The two things a person does most, without hunting for the right tab first.
///
/// Stacked rather than side by side: full-width buttons cannot crowd their own
/// labels off the edge on a narrow phone.
class DashboardActions extends StatelessWidget {
  const DashboardActions({this.onAddPedal, this.onBuildRig, super.key});

  final VoidCallback? onAddPedal;
  final VoidCallback? onBuildRig;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: onAddPedal,
            icon: const Icon(Icons.add),
            label: const Text('Add a pedal'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: onBuildRig,
            icon: const Icon(Icons.dashboard_customize_outlined),
            label: const Text('Build a rig'),
          ),
        ],
      ),
    );
  }
}
