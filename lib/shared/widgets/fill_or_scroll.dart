import 'package:flutter/material.dart';

/// Gives [child] at least the height it is handed, and scrolls rather than
/// overflowing where the child wants more.
///
/// For a column of controls meant to use the whole page it is on - its gaps
/// opening up to fill the height - without being cut off on a screen too short
/// for it. A plain scroll view would leave the gap at the bottom; a plain
/// column would overflow.
class FillOrScroll extends StatelessWidget {
  const FillOrScroll({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.hasBoundedHeight ? constraints.maxHeight : 0,
          ),
          child: child,
        ),
      ),
    );
  }
}
