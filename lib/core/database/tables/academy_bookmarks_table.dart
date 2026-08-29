import 'package:drift/drift.dart';

import '../../enums/bookmark_target.dart';

/// Something the player wanted to come back to.
///
/// [targetKey] is deliberately not a foreign key. A bookmarked lesson is a row and
/// could have been one, but a bookmarked chord or scale is not: the theory engine
/// works those out on demand and there is no table of them to point at. One table
/// with a string key holds both, where a foreign key would have meant either a
/// second table for the theory bookmarks or a table of every chord in music.
///
/// The cost is that a bookmark can outlive what it named - a lesson removed by an
/// import leaves one behind. That is handled where bookmarks are read, by showing
/// only the ones that still resolve, rather than by a constraint: a stale row is
/// cheap, and losing the bookmark to a chord because a lesson went is not.
@DataClassName('AcademyBookmark')
class AcademyBookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get target => textEnum<BookmarkTarget>()();

  /// How to find the thing again: a lesson's slug, or a key the theory engine can
  /// resolve such as `Cmaj7` or `A dorian`.
  TextColumn get targetKey => text().withLength(min: 1, max: 120)();

  /// What to call it in the list, so a bookmark reads as itself without every
  /// screen that shows one having to resolve it first.
  TextColumn get label => text().withLength(min: 1, max: 120)();

  DateTimeColumn get createdAt => dateTime()();

  /// The same thing bookmarked twice is one bookmark.
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {target, targetKey},
  ];
}
