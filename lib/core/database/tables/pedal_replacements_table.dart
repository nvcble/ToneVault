import 'package:drift/drift.dart';

import 'pedals_table.dart';

/// Records that one pedal took another's place in the rig.
///
/// Both pedals stay in the `pedals` table; the outgoing one is only marked
/// `replaced`, so its configurations and history remain intact.
@TableIndex(name: 'idx_pedal_replacements_old', columns: {#oldPedalId})
@TableIndex(name: 'idx_pedal_replacements_new', columns: {#newPedalId})
class PedalReplacements extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Both columns point at `pedals`, so each side needs its own reference name
  // for the generated relation accessors to stay distinguishable.
  @ReferenceName('replacementsWhereOutgoing')
  IntColumn get oldPedalId =>
      integer().references(Pedals, #id, onDelete: KeyAction.restrict)();

  @ReferenceName('replacementsWhereIncoming')
  IntColumn get newPedalId =>
      integer().references(Pedals, #id, onDelete: KeyAction.restrict)();

  TextColumn get reason => text().nullable()();

  DateTimeColumn get replacedAt => dateTime()();

  TextColumn get notes => text().nullable()();

  /// Guarded here as well as in the repository, because a pedal replacing
  /// itself would corrupt the replacement chain irrecoverably.
  @override
  List<String> get customConstraints => [
    'CHECK (old_pedal_id != new_pedal_id)',
  ];
}
