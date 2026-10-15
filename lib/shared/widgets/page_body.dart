import 'package:flutter/material.dart';

/// A page's body, held to a readable column and clear of the system's own
/// insets.
///
/// A phone held upright is narrower than [maxWidth], so this changes nothing
/// there. It is for every wider case - a phone held sideways, a tablet, a
/// desktop window - where a list built for one column stretches its rows the
/// full width and reads as a page shown in the wrong shape, and where in
/// landscape the notch and the rounded corners sit over the content.
class PageBody extends StatelessWidget {
  const PageBody({required this.child, this.maxWidth = 640, super.key});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // Top-aligned rather than centred: a body shorter than the page belongs
      // under the app bar, not floating in the middle of it.
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
