import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/enums/learning_path.dart';
import '../providers/progress_providers.dart';
import 'tally_bar.dart';

/// One of the two paths, as the choice a player makes on the way in.
///
/// A card each rather than two tabs or a segmented switch: this is the one
/// decision the Academy asks for before anything else, and a choice that looks
/// like a choice is easier to make than one that looks like a filter.
///
/// The whole path's progress sits under the summary. A player who has been through
/// half of the rhythm path is choosing between something they are part way through
/// and something they have not started, and the card is where that shows.
class LearningPathCard extends ConsumerWidget {
  const LearningPathCard({required this.path, required this.onTap, super.key});

  final LearningPath path;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tally = ref.watch(pathTotalProvider(path));

    return Card(
      // So the ripple stops at the rounded corner rather than squaring it off.
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(_icon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(path.label, style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      path.summary,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TallyBar(tally: tally),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _icon => switch (path) {
    LearningPath.rhythm => Icons.grid_on,
    LearningPath.lead => Icons.timeline,
  };
}
