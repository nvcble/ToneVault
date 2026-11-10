// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hotone_ampero_mini_favorite_dao.dart';

// ignore_for_file: type=lint
mixin _$HotoneAmperoMiniFavoriteDaoMixin on DatabaseAccessor<AppDatabase> {
  $HotoneAmperoMiniFavoritesTable get hotoneAmperoMiniFavorites =>
      attachedDatabase.hotoneAmperoMiniFavorites;
  HotoneAmperoMiniFavoriteDaoManager get managers =>
      HotoneAmperoMiniFavoriteDaoManager(this);
}

class HotoneAmperoMiniFavoriteDaoManager {
  final _$HotoneAmperoMiniFavoriteDaoMixin _db;
  HotoneAmperoMiniFavoriteDaoManager(this._db);
  $$HotoneAmperoMiniFavoritesTableTableManager get hotoneAmperoMiniFavorites =>
      $$HotoneAmperoMiniFavoritesTableTableManager(
        _db.attachedDatabase,
        _db.hotoneAmperoMiniFavorites,
      );
}
