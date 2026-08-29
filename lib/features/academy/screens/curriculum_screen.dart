import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/section_label.dart';
import '../widgets/curriculum_export_tile.dart';
import '../widgets/curriculum_import_tile.dart';

/// Courses and lessons in and out of the app as files.
///
/// Its own screen rather than two more tiles on the Academy: importing a curriculum
/// is a rare, deliberate thing that needs a sentence of explanation, and the way in
/// to the Academy is meant to be the two paths and what to practise.
///
/// Not an editor. There is no way here to write a course, rename a lesson or delete
/// one - a curriculum is authored in a file, and this screen checks a file and puts
/// it in. The note at the bottom says so, because a screen with "import" on it
/// invites the question.
class CurriculumScreen extends StatelessWidget {
  const CurriculumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Courses and lessons')),
      body: ListView(
        children: [
          const SectionLabel('Sharing a curriculum'),
          const CurriculumExportTile(),
          const CurriculumImportTile(),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'A curriculum file holds whole courses: their modules, lessons and '
              'exercises. Importing one adds the courses it holds, and asks first '
              'about any this app already has.\n\n'
              'Your progress is yours and stays here. It is never written into a '
              'file you share, and importing a course you are part way through '
              'keeps the practice you have put in.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
