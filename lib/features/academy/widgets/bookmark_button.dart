import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/bookmark_target.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/academy_providers.dart';

/// Keep this, or stop keeping it.
///
/// One button for lessons, chords, scales and progressions alike: a bookmark is a target
/// and a key, so the thing being kept only has to say what it is and what to call it.
/// The filled icon is the state, read from the database rather than held here, so the
/// same lesson bookmarked from a course reads as bookmarked in the theory browser too.
class BookmarkButton extends ConsumerWidget {
  const BookmarkButton({
    required this.target,
    required this.targetKey,
    required this.label,
    super.key,
  });

  final BookmarkTarget target;

  /// What the bookmark points at: a lesson's slug, or something the theory engine can
  /// resolve again.
  final String targetKey;

  /// What to call it in the list of bookmarks.
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final at = (target: target, targetKey: targetKey);
    final kept = ref.watch(bookmarkProvider(at)).valueOrNull != null;

    return IconButton(
      onPressed: () => _toggle(context, ref, kept: kept),
      tooltip: kept ? 'Stop keeping this' : 'Keep this',
      icon: Icon(kept ? Icons.bookmark : Icons.bookmark_border),
    );
  }

  /// A failure here is worth a snack bar and nothing else: the thing being looked at is
  /// still on the screen, and not keeping it is no reason to take it away.
  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref, {
    required bool kept,
  }) async {
    final bookmarks = ref.read(bookmarkRepositoryProvider);

    try {
      if (kept) {
        await bookmarks.removeBookmark(target, targetKey);
      } else {
        await bookmarks.addBookmark(
          target: target,
          targetKey: targetKey,
          label: label,
        );
      }
    } catch (error) {
      if (context.mounted) {
        showFailureSnackBar(context, error);
      }
    }
  }
}
