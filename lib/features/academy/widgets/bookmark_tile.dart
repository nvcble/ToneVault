import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/enums/bookmark_target.dart';
import '../../../core/errors/app_failure.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/bookmark_keys.dart';
import '../providers/academy_providers.dart';
import 'theory_diagram_sheet.dart';

/// One thing the player kept, and the way back to it.
///
/// A lesson opens where it lives, which takes a lookup: a bookmark stores the slug,
/// because a slug survives the course being re-imported, and the route to a lesson names
/// the course. Everything else is theory the engine can resolve again, so it opens as a
/// diagram without anything being read from the database at all.
class BookmarkTile extends ConsumerWidget {
  const BookmarkTile({required this.bookmark, super.key});

  final AcademyBookmark bookmark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(_icon),
      title: Text(bookmark.label),
      subtitle: Text(bookmark.target.label),
      trailing: IconButton(
        onPressed: () => _remove(context, ref),
        tooltip: 'Stop keeping this',
        icon: const Icon(Icons.bookmark_remove_outlined),
      ),
      onTap: () => _open(context, ref),
    );
  }

  IconData get _icon => switch (bookmark.target) {
    BookmarkTarget.lesson => Icons.menu_book_outlined,
    BookmarkTarget.chord => Icons.piano_outlined,
    BookmarkTarget.scale => Icons.linear_scale,
    BookmarkTarget.mode => Icons.rotate_right,
    BookmarkTarget.progression => Icons.timeline,
    BookmarkTarget.substitution => Icons.swap_horiz,
  };

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    if (bookmark.target != BookmarkTarget.lesson) {
      await showModalBottomSheet<void>(
        context: context,
        // A neck is wider than it is tall but it is not short, and a sheet held to
        // nine sixteenths of the screen cuts one off. The sheet takes the height
        // its diagram needs and scrolls past that.
        isScrollControlled: true,
        builder: (context) => TheoryDiagramSheet(
          title: bookmark.label,
          theoryKeys: theoryKeysOf(bookmark.targetKey),
        ),
      );
      return;
    }

    final place = await ref
        .read(curriculumRepositoryProvider)
        .findLessonPlace(bookmark.targetKey);
    if (!context.mounted) {
      return;
    }

    // A bookmark can outlive the lesson it points at: an import that dropped the course
    // leaves the row behind, and saying so is better than a blank course screen.
    if (place == null) {
      showFailureSnackBar(
        context,
        const AppFailure('That lesson is not in the curriculum now.'),
      );
      return;
    }

    await context.push<void>(
      Routes.academyCourse(
        place.course.path,
        place.course.level,
        place.course.id,
      ),
    );
  }

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(bookmarkRepositoryProvider)
          .removeBookmark(bookmark.target, bookmark.targetKey);
    } catch (error) {
      if (context.mounted) {
        showFailureSnackBar(context, error);
      }
    }
  }
}
