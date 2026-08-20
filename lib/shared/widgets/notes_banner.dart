import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

/// The user's own words about the thing on screen, across the top of it.
///
/// Kept for tracking: `ConfigurationScreen` has a private copy of this. It is
/// left as it is rather than changed under working, tested code.
class NotesBanner extends StatelessWidget {
  const NotesBanner(this.notes, {super.key});

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
