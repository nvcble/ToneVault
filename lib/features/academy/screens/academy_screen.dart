import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/enums/learning_path.dart';
import '../../../shared/widgets/section_label.dart';
import '../providers/academy_providers.dart';
import '../widgets/continue_learning.dart';
import '../widgets/learning_path_card.dart';
import '../widgets/quick_practice.dart';
import '../widgets/theory_shortcuts.dart';

/// The way into the Academy: which of the two paths, and nothing else.
///
/// It is a screen of its own rather than a tab, reached from the header of
/// whichever tab the user was on, so it comes with a back arrow to what they were
/// doing. Learning is something you go and do and then come back from; the tabs
/// are the collection, which is always there.
///
/// This is also where the curriculum gets loaded. Watching the seed here rather
/// than in `main` means the work happens when somebody opens the Academy instead
/// of on every cold start, and it is done by the time they have chosen a path.
class AcademyScreen extends ConsumerWidget {
  const AcademyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(curriculumSeedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guitar Academy'),
        actions: [
          // In the header rather than a tile, because searching is a way of getting
          // anywhere in the curriculum and not one more thing to practise.
          IconButton(
            onPressed: () => context.push(Routes.academySearch),
            tooltip: 'Search the Academy',
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        children: [
          // Above the paths, and nothing at all where there is nothing underway.
          const ContinueLearning(),
          const SectionLabel('Choose a path'),
          for (final path in LearningPath.values)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: LearningPathCard(
                path: path,
                onTap: () => context.push(Routes.academyPath(path)),
              ),
            ),
          // Outside the paths, all of it: ears, scales and a tempo are not rhythm or
          // lead, and a player drills them whichever way they came in.
          const SectionLabel('Quick practice'),
          const QuickPractice(),
          const SectionLabel('Theory'),
          const TheoryShortcuts(),
          const SectionLabel('Yours'),
          ListTile(
            leading: const Icon(Icons.bookmark_border),
            title: const Text('Bookmarks'),
            subtitle: const Text('The lessons and shapes you kept.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.academyBookmarks),
          ),
          // Last, and away from the paths: importing a curriculum is a rare,
          // deliberate thing and not one of the ways in.
          ListTile(
            leading: const Icon(Icons.folder_shared_outlined),
            title: const Text('Courses and lessons'),
            subtitle: const Text('Import a curriculum, or pass yours on.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.academyCurriculum),
          ),
        ],
      ),
    );
  }
}
