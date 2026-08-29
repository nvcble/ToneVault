import 'package:flutter/material.dart';

import '../data/curriculum_importer.dart';
import '../data/curriculum_model.dart';
import '../data/curriculum_summary.dart';

/// Asks what to do with a curriculum file that has been read but not written.
///
/// The file is described first, and the courses this app already has are named, so
/// the user is answering about a particular import rather than about the idea of one.
/// Returns null where they backed out, and nothing has been written either way.
///
/// Two answers where something clashes, because there are two reasonable things to
/// want and neither is safe to assume. A teacher re-sending a corrected course means
/// "bring it up to date"; a player handed a bundle that happens to include courses
/// they already have means "leave mine alone". Guessing wrong rewrites lessons
/// underneath somebody.
Future<CurriculumConflict?> askAboutCurriculum(
  BuildContext context, {
  required List<CourseSpec> courses,
  required List<String> alreadyStored,
}) {
  final clashes = alreadyStored.isNotEmpty;

  return showDialog<CurriculumConflict>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(clashes ? 'Some of this is already here' : 'Import this?'),
      content: Text(
        clashes
            ? '${describeCurriculum(courses)}\n\n'
                  '${describeOverwrite(alreadyStored)}'
            : describeCurriculum(courses),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        if (clashes)
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, CurriculumConflict.keep),
            child: const Text('Keep mine'),
          ),
        FilledButton(
          onPressed: () => Navigator.pop(
            dialogContext,
            clashes ? CurriculumConflict.update : CurriculumConflict.refuse,
          ),
          child: Text(clashes ? 'Bring up to date' : 'Import'),
        ),
      ],
    ),
  );
}
