import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/bookmark_target.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/academy/data/bookmark_repository.dart';
import '../support/repositories.dart';

/// The things a player asked to come back to.
void main() {
  late AppDatabase database;
  late BookmarkRepository bookmarks;
  var now = DateTime.utc(2026, 8, 20, 10);

  setUp(() {
    // Reset, because the tests that move the clock forward move this one.
    now = DateTime.utc(2026, 8, 20, 10);
    database = AppDatabase(NativeDatabase.memory());
    bookmarks = bookmarkRepository(database, clock: () => now);
  });

  tearDown(() => database.close());

  test('a chord and a lesson are bookmarked the same way', () async {
    await bookmarks.addBookmark(
      target: BookmarkTarget.chord,
      targetKey: 'Cmaj7',
      label: 'C major 7',
    );
    now = DateTime.utc(2026, 8, 21, 10);
    await bookmarks.addBookmark(
      target: BookmarkTarget.lesson,
      targetKey: 'rhythm-beginner-first-chords',
      label: 'First Chords',
    );

    // Newest first: the last one kept is the one most likely to be wanted.
    final kept = await bookmarks.watchBookmarks().first;
    expect(kept.map((bookmark) => bookmark.label), [
      'First Chords',
      'C major 7',
    ]);
    expect(kept.last.target, BookmarkTarget.chord);
  });

  test('the same thing bookmarked twice is one bookmark', () async {
    await bookmarks.addBookmark(
      target: BookmarkTarget.scale,
      targetKey: 'A dorian',
      label: 'A dorian',
    );
    now = DateTime.utc(2026, 8, 22, 10);
    await bookmarks.addBookmark(
      target: BookmarkTarget.scale,
      targetKey: 'A dorian',
      label: 'A dorian mode',
    );

    final kept = await bookmarks.watchBookmarks().first;
    expect(kept, hasLength(1));
    expect(kept.single.label, 'A dorian mode');
    expect(kept.single.createdAt, DateTime.utc(2026, 8, 22, 10));
  });

  test('the same key under a different target is a different bookmark', () async {
    // A lesson slug and a chord name could read alike, and one is not the other.
    await bookmarks.addBookmark(
      target: BookmarkTarget.chord,
      targetKey: 'Am',
      label: 'A minor',
    );
    await bookmarks.addBookmark(
      target: BookmarkTarget.progression,
      targetKey: 'Am',
      label: 'The Am vamp',
    );

    expect(await bookmarks.watchBookmarks().first, hasLength(2));
  });

  test('a bookmark is found by what it points at', () async {
    await bookmarks.addBookmark(
      target: BookmarkTarget.chord,
      targetKey: ' Cmaj7 ',
      label: 'C major 7',
    );

    // Trimmed on the way in and on the way back out, so a stray space cannot make
    // a screen show an unmarked star over a bookmark that is there.
    expect(
      (await bookmarks.watchBookmark(BookmarkTarget.chord, 'Cmaj7').first)
          ?.label,
      'C major 7',
    );
    expect(
      await bookmarks.watchBookmark(BookmarkTarget.chord, 'Cm').first,
      isNull,
    );
  });

  test('a bookmark with nothing to point at is refused', () async {
    await expectLater(
      bookmarks.addBookmark(
        target: BookmarkTarget.chord,
        targetKey: '   ',
        label: 'C major 7',
      ),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.message,
          'message',
          'A bookmark needs something to point at.',
        ),
      ),
    );
    expect(await bookmarks.watchBookmarks().first, isEmpty);
  });

  test('removing a bookmark says whether there was one', () async {
    await bookmarks.addBookmark(
      target: BookmarkTarget.chord,
      targetKey: 'Cmaj7',
      label: 'C major 7',
    );

    expect(
      await bookmarks.removeBookmark(BookmarkTarget.chord, 'Cmaj7'),
      isTrue,
    );
    expect(
      await bookmarks.removeBookmark(BookmarkTarget.chord, 'Cmaj7'),
      isFalse,
    );
    expect(await bookmarks.watchBookmarks().first, isEmpty);
  });
}
