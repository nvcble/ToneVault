// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academy_bookmark_dao.dart';

// ignore_for_file: type=lint
mixin _$AcademyBookmarkDaoMixin on DatabaseAccessor<AppDatabase> {
  $AcademyBookmarksTable get academyBookmarks =>
      attachedDatabase.academyBookmarks;
  AcademyBookmarkDaoManager get managers => AcademyBookmarkDaoManager(this);
}

class AcademyBookmarkDaoManager {
  final _$AcademyBookmarkDaoMixin _db;
  AcademyBookmarkDaoManager(this._db);
  $$AcademyBookmarksTableTableManager get academyBookmarks =>
      $$AcademyBookmarksTableTableManager(
        _db.attachedDatabase,
        _db.academyBookmarks,
      );
}
