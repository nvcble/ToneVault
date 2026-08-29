import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../theory/data/theory_tab.dart';

/// The four things a player might do in ten minutes without opening a lesson.
///
/// Buttons in a wrap rather than a column of rows: these are not a list to work through
/// but four doors, and a player who picked up the guitar to run some scales for a few
/// minutes should not have to read four subtitles to find the one they meant.
class QuickPractice extends StatelessWidget {
  const QuickPractice({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final choice in _choices)
            OutlinedButton.icon(
              onPressed: () => context.push(choice.route),
              icon: Icon(choice.icon),
              label: Text(choice.label),
            ),
        ],
      ),
    );
  }
}

/// Chords and scales open the browser on the tab that has the shapes on it, because a
/// player practising chords wants the fingerings and not the family they belong to.
final List<({String label, IconData icon, String route})> _choices = [
  (
    label: 'Chords',
    icon: Icons.piano_outlined,
    route: Routes.academyTheoryTab(TheoryTab.shapes),
  ),
  (
    label: 'Scales',
    icon: Icons.linear_scale,
    route: Routes.academyTheoryTab(TheoryTab.scales),
  ),
  (label: 'Ear training', icon: Icons.hearing, route: Routes.academyEar),
  (label: 'Metronome', icon: Icons.av_timer, route: Routes.metronome),
];
