import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/failure_snack_bar.dart';

/// Something on the home screen that could not be loaded, said plainly.
///
/// Left on screen rather than shown once and dismissed: the home screen is all
/// counts and summaries, and a summary that quietly omits half its subject reads
/// as a fact about the collection instead of a fault.
class ProblemCard extends StatelessWidget {
  const ProblemCard({required this.title, required this.error, super.key});

  final String title;
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  Text(failureMessage(error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
