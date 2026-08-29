import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/widgets/async_list_section.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/academy_providers.dart';
import '../widgets/bookmark_tile.dart';

/// Everything the player kept, newest first.
///
/// One list rather than a section per kind. A player looking for the thing they kept
/// yesterday remembers when they kept it, not whether the app filed it as a chord or as a
/// lesson, and the row says which it is.
class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: AsyncListSection<AcademyBookmark>(
        items: ref.watch(bookmarkListProvider),
        errorTitle: 'Could not load your bookmarks',
        empty: const EmptyState(
          icon: Icons.bookmark_border,
          title: 'Nothing kept yet',
          message:
              'The bookmark on a lesson, a chord or a scale keeps it here, so '
              'the thing you are working on is one tap away.',
        ),
        itemBuilder: (context, bookmark) => BookmarkTile(bookmark: bookmark),
      ),
    );
  }
}
