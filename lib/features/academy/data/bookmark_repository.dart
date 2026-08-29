import '../../../core/database/app_database.dart';
import '../../../core/database/daos/academy_bookmark_dao.dart';
import '../../../core/enums/bookmark_target.dart';
import '../../../core/errors/app_failure.dart';

/// The lessons, chords, scales and progressions the player wanted to keep.
///
/// A bookmark is named by what it points at rather than by an id, so bookmarking
/// the chord `Cmaj7` and bookmarking a lesson are the same operation. The key is
/// the caller's - a lesson's slug, or something the theory engine can resolve -
/// and it is trimmed but not otherwise interpreted here.
class BookmarkRepository {
  BookmarkRepository(this._dao, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AcademyBookmarkDao _dao;

  /// Injectable so tests can assert on exact timestamps.
  final DateTime Function() _clock;

  Stream<List<AcademyBookmark>> watchBookmarks() => _dao.watchBookmarks();

  Stream<AcademyBookmark?> watchBookmark(
    BookmarkTarget target,
    String targetKey,
  ) => _dao.watchBookmark(target, targetKey.trim());

  /// Adds a bookmark, or updates the label on the one that is already there.
  ///
  /// The same thing bookmarked twice is one bookmark, which the unique key already
  /// says; the upsert means a second tap is harmless rather than an error the user
  /// is told about for doing nothing wrong.
  Future<void> addBookmark({
    required BookmarkTarget target,
    required String targetKey,
    required String label,
  }) async {
    final key = targetKey.trim();
    final title = label.trim();
    if (key.isEmpty || title.isEmpty) {
      throw const AppFailure('A bookmark needs something to point at.');
    }

    await guardFailure(
      () => _dao.saveBookmark(
        AcademyBookmarksCompanion.insert(
          target: target,
          targetKey: key,
          label: title,
          createdAt: _clock(),
        ),
      ),
      'Could not save this bookmark.',
    );
  }

  /// Returns whether there was a bookmark to remove.
  Future<bool> removeBookmark(BookmarkTarget target, String targetKey) =>
      guardFailure(
        () => _dao.deleteBookmark(target, targetKey.trim()),
        'Could not remove this bookmark.',
      );
}
