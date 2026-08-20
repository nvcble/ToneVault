import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

/// The actions along the bottom of a sheet or a dialog, ending on the right.
///
/// The app theme stretches a [FilledButton] across its column, which is what a
/// form wants and what a [Row] cannot give: an infinite minimum width is not a
/// constraint a row can satisfy, and laying one out throws before anything
/// reaches the screen. Buttons placed here get a finite minimum back, so an
/// action bar reads the same everywhere without each screen repeating the
/// override.
class ActionRow extends StatelessWidget {
  const ActionRow({required this.children, this.leading, super.key});

  /// Sits at the far left, away from the confirming action, which is where a
  /// destructive choice such as Clear belongs.
  final Widget? leading;

  /// Right-aligned in reading order, with the confirming action last.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final themed = Theme.of(context).filledButtonTheme.style;

    return FilledButtonTheme(
      data: FilledButtonThemeData(
        style: (themed ?? const ButtonStyle()).copyWith(
          // Material's own minimum width, with the app's taller touch target.
          minimumSize: const WidgetStatePropertyAll(
            Size(64, AppSpacing.minTouchTarget),
          ),
        ),
      ),
      child: Row(
        children: [
          ?leading,
          const Spacer(),
          for (final (index, child) in children.indexed) ...[
            if (index > 0) const SizedBox(width: AppSpacing.sm),
            child,
          ],
        ],
      ),
    );
  }
}
