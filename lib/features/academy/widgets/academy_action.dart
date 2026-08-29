import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';

/// The way into the Academy, in the header of every tab.
///
/// The header rather than a fifth destination in the bottom bar: a bar of five
/// reads as a list to work through, and squeezes four labels that were already
/// tight. In the header it is in the same place on every tab, so wherever the user
/// is when they feel like practising, it is there.
class AcademyAction extends StatelessWidget {
  const AcademyAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.school_outlined),
      tooltip: 'Guitar Academy',
      // Pushed rather than gone to, so the back arrow returns to the tab the user
      // was on rather than to the home tab.
      onPressed: () => context.push(Routes.academy),
    );
  }
}
