import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

/// A line of explanation between the lists of a sheet, in the shape of a heading.
///
/// Shared by the sheets a block is built with, so a heading in one reads the same
/// weight and colour as a heading in the next.
class SheetNote extends StatelessWidget {
  const SheetNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
