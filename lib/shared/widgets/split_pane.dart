import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import 'fill_or_scroll.dart';

/// Two panes side by side once there is width for both, stacked when there is
/// not.
///
/// [side] takes a fixed width rather than a share of the row: a column of
/// buttons wants a comfortable thumb width, not whatever is left over. It
/// scrolls on its own, so it overflowing is not [main]'s problem - which is
/// what makes this safe on a phone held sideways, where height is scarce.
///
/// Side by side, [main] is handed the full height and is expected to adapt to
/// it rather than scroll: it is the pane worth filling the screen with.
/// Stacked, both size themselves and the whole column scrolls.
class SplitPane extends StatelessWidget {
  const SplitPane({
    required this.main,
    required this.side,
    this.sideWidth = 280,
    this.breakpoint = 560,
    super.key,
  });

  final Widget main;
  final Widget side;
  final double sideWidth;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return SingleChildScrollView(
            child: Column(
              children: [main, const SizedBox(height: AppSpacing.md), side],
            ),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: main),
            const SizedBox(width: AppSpacing.md),
            SizedBox(width: sideWidth, child: FillOrScroll(child: side)),
          ],
        );
      },
    );
  }
}
