import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import 'lesson_theory.dart';

/// A kept chord, scale or progression, on the neck.
///
/// A sheet rather than a screen: a bookmark is looked at and put down again, and the list
/// it was opened from is the thing to go back to. What draws it is the same widget a
/// lesson uses, so a chord kept from a lesson is drawn the way the lesson drew it.
///
/// It scrolls, because what goes in it is not one fixed height: a chord is a neck and a
/// chip, and a progression of four is the same neck with four chips to pick between. On a
/// short phone the taller of those does not fit, and a diagram cut off at the bottom is
/// the half of the neck a player needs.
class TheoryDiagramSheet extends StatelessWidget {
  const TheoryDiagramSheet({
    required this.title,
    required this.theoryKeys,
    super.key,
  });

  final String title;
  final List<String> theoryKeys;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            LessonTheory(theoryKeys: theoryKeys),
          ],
        ),
      ),
    );
  }
}
