import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

/// Puts a finite minimum width back on the [FilledButton]s inside [child], for
/// the places a button sits beside something rather than spanning a column.
///
/// The app theme gives every filled button an infinite minimum width, which is
/// what makes a form's primary action fill its column. A [Row] offers its
/// non-flex children unbounded width and cannot satisfy that, and a [Wrap]
/// would stretch each button across a line of its own. The row case is the
/// dangerous one: it throws during layout, which aborts the whole frame and
/// leaves the screen entirely blank - not a red error box, because
/// `ErrorWidget.builder` only catches build failures, never layout ones.
///
/// [ActionRow] is the right choice for a trailing bar of actions; this is for
/// anything else that lays buttons out horizontally.
class InlineButtonTheme extends StatelessWidget {
  const InlineButtonTheme({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FilledButtonTheme(
      data: FilledButtonThemeData(
        style: (Theme.of(context).filledButtonTheme.style ?? const ButtonStyle())
            .copyWith(minimumSize: minimumSize),
      ),
      child: child,
    );
  }

  /// Material's own minimum width, with the app's taller touch target.
  static const WidgetStatePropertyAll<Size> minimumSize =
      WidgetStatePropertyAll(Size(64, AppSpacing.minTouchTarget));
}
