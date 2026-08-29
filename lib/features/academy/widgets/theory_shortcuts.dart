import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../theory/data/theory_topics.dart';

/// The theory the browser teaches, each named and one tap away.
///
/// Six names rather than one tile called "Theory": a player with a question about the
/// circle of fifths does not know that the app filed the circle of fifths behind a tab of
/// a screen called Theory, and a list of what is in there is the answer to that.
class TheoryShortcuts extends StatelessWidget {
  const TheoryShortcuts({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final topic in theoryTopics)
            Tooltip(
              message: topic.blurb,
              child: OutlinedButton(
                onPressed: () => context.push(topic.route),
                child: Text(topic.title),
              ),
            ),
        ],
      ),
    );
  }
}
