import 'package:drift/drift.dart';

/// A patch slot of the Hotone Ampero Mini the user has starred.
///
/// Keyed by the slot index rather than by a row of `hotone_ampero_mini_patches`
/// on purpose: that table only holds slots a sync has read, and the Mini has no
/// confirmed patch-read command yet, so it is empty. A star has to work today,
/// and it has to keep pointing at the same slot once names arrive.
@DataClassName('HotoneAmperoMiniFavorite')
class HotoneAmperoMiniFavorites extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Named rather than assumed, as in `HotoneAmperoMiniPatches`.
  TextColumn get deviceProfileId => text()();

  /// The pedal's own zero-based slot index, 0-197 - see
  /// `HotoneAmperoMiniPatches.patchNumber`.
  IntColumn get patchNumber => integer()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  List<Set<Column>>? get uniqueKeys => [
    {deviceProfileId, patchNumber},
  ];
}
