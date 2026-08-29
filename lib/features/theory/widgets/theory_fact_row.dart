import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

/// One labelled fact about a chord or a scale: `Formula   1 3 5 b7`.
///
/// A row with a fixed label column rather than a paragraph, so a stack of these lines up
/// down the page and can be read as a table. Shared by the chord library and the scale
/// browser, because the two are answering the same kind of question and a player should
/// not have to learn two layouts to read them.
class TheoryFactRow extends StatelessWidget {
  const TheoryFactRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
