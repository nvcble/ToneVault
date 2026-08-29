import 'package:drift/drift.dart';

import '../../enums/bookmark_target.dart';
import '../app_database.dart';
import '../tables/academy_bookmarks_table.dart';

part 'academy_bookmark_dao.g.dart';

/// Typed queries over the things the player wanted to come back to.
@DriftAccessor(tables: [AcademyBookmarks])
class AcademyBookmarkDao extends DatabaseAccessor<AppDatabase>
    with _$AcademyBookmarkDaoMixin {
  AcademyBookmarkDao(super.attachedDatabase);

  /// Newest first: a bookmark is a note to self, and the last one made is the one
  /// most likely to be wanted.
  Stream<List<AcademyBookmark>> watchBookmarks() {
    return (select(
      academyBookmarks,
    )..orderBy([(row) => OrderingTerm.desc(row.createdAt)])).watch();
  }

  Stream<AcademyBookmark?> watchBookmark(
    BookmarkTarget target,
    String targetKey,
  ) {
    return (select(academyBookmarks)..where(
          (row) =>
              row.target.equalsValue(target) & row.targetKey.equals(targetKey),
        ))
        .watchSingleOrNull();
  }

  /// Upsert, so bookmarking the same thing twice is one bookmark rather than an
  /// error the user has to be told about for doing something harmless.
  ///
  /// The conflict is aimed at what makes a bookmark the same bookmark rather than
  /// at the primary key, because the caller passes a target and a key and does not
  /// know the id. The second save freshens `createdAt`, which is what puts the
  /// thing they have just asked to keep at the top of the list.
  Future<void> saveBookmark(AcademyBookmarksCompanion bookmark) {
    return into(academyBookmarks).insert(
      bookmark,
      onConflict: DoUpdate(
        (_) => bookmark,
        target: [academyBookmarks.target, academyBookmarks.targetKey],
      ),
    );
  }

  /// Returns whether a row matched.
  Future<bool> deleteBookmark(BookmarkTarget target, String targetKey) async {
    final deletedRows =
        await (delete(academyBookmarks)..where(
              (row) =>
                  row.target.equalsValue(target) &
                  row.targetKey.equals(targetKey),
            ))
            .go();
    return deletedRows > 0;
  }
}
