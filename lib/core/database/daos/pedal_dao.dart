import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/change_logs_table.dart';
import '../tables/configurations_table.dart';
import '../tables/midi_device_links_table.dart';
import '../tables/patches_table.dart';
import '../tables/pedal_controls_table.dart';
import '../tables/pedals_table.dart';
import '../tables/signal_blocks_table.dart';

part 'pedal_dao.g.dart';

/// Typed queries over the `pedals` table.
///
/// Timestamps, validation and error translation belong to `PedalRepository`;
/// this class only reads and writes rows.
///
/// Every other table here is for one reason: see [deletePedal].
@DriftAccessor(
  tables: [
    Pedals,
    SignalBlocks,
    Patches,
    Configurations,
    PedalControls,
    ChangeLogs,
    MidiDeviceLinks,
  ],
)
class PedalDao extends DatabaseAccessor<AppDatabase> with _$PedalDaoMixin {
  PedalDao(super.attachedDatabase);

  /// The pedals a player owns as separate pieces of gear, ordered by name.
  ///
  /// A stomp or block inside a multi-effects unit is deliberately not one of
  /// them: it is reached through its unit, and counting it here would put it in
  /// the inventory list, the dashboard tallies, the rig chain picker and the
  /// replacement list, none of which it belongs in. This is the only query the
  /// whole app lists pedals through, so excluding them once excludes them
  /// everywhere.
  ///
  /// SQLite's default collation is case-sensitive, which would sort "joyo"
  /// after "Zoom", so the ordering is explicitly case-insensitive.
  Stream<List<Pedal>> watchPedals() {
    return (select(pedals)
          ..where((row) => row.hostPedalId.isNull())
          ..orderBy([
            (row) => OrderingTerm.asc(row.name.collate(Collate.noCase)),
          ]))
        .watch();
  }

  /// The pedals inside [hostPedalId], in the order they were added to it.
  ///
  /// Which is signal-chain order: the blocks of a linked unit are seeded in the
  /// order its device profile lists them, and a block added by hand belongs
  /// after the ones already there. Name order - what this used to use - put Amp
  /// before Wah on an MG-30, a chain no unit has.
  Stream<List<Pedal>> watchComponentPedals(int hostPedalId) =>
      _componentPedalsQuery(hostPedalId).watch();

  /// The same rows as [watchComponentPedals], read once rather than
  /// subscribed to - for a one-off computation, such as a preset import, that
  /// has no reason to keep listening afterwards.
  Future<List<Pedal>> componentPedals(int hostPedalId) =>
      _componentPedalsQuery(hostPedalId).get();

  SimpleSelectStatement<$PedalsTable, Pedal> _componentPedalsQuery(
    int hostPedalId,
  ) {
    return select(pedals)
      ..where((row) => row.hostPedalId.equals(hostPedalId))
      ..orderBy([(row) => OrderingTerm.asc(row.id)]);
  }

  Stream<Pedal?> watchPedal(int pedalId) {
    return (select(
      pedals,
    )..where((row) => row.id.equals(pedalId))).watchSingleOrNull();
  }

  Future<Pedal?> findPedal(int pedalId) {
    return (select(
      pedals,
    )..where((row) => row.id.equals(pedalId))).getSingleOrNull();
  }

  Future<int> insertPedal(PedalsCompanion pedal) => into(pedals).insert(pedal);

  /// Returns whether a row matched [pedalId].
  Future<bool> updatePedal(int pedalId, PedalsCompanion changes) async {
    final changedRows = await (update(
      pedals,
    )..where((row) => row.id.equals(pedalId))).write(changes);
    return changedRows > 0;
  }

  /// Deletes [pedalId] with everything that exists only because of it, and
  /// returns whether a row matched.
  ///
  /// Everything referencing a pedal does so with ON DELETE RESTRICT, so without
  /// this sweep a pedal is deletable only while it is brand new and bare. That
  /// made a multi-effects unit undeletable outright: the pedals inside it, its
  /// patches and its MIDI link all held it in place, and clearing them by hand
  /// was not something any screen offered. What goes is what the pedal owned -
  /// the pedals it holds and all of theirs in turn, its patches (scenes and
  /// their positions cascade), its controls and configurations, its MIDI link
  /// and its history. What it shared with other gear does not: a replacement
  /// record or a rig snapshot still restricts the delete, and `PedalRepository`
  /// turns that into an offer to retire the pedal instead.
  ///
  /// A patch goes before the pedals inside the unit, because a scene of that
  /// patch is what refers to them.
  ///
  /// One transaction, so a pedal is never left half swept with itself still
  /// there.
  Future<bool> deletePedal(int pedalId) => transaction(() => _delete(pedalId));

  Future<bool> _delete(int pedalId) async {
    await _deleteByPedal(patches, (row) => row.pedalId, pedalId);

    for (final held in await componentPedals(pedalId)) {
      await _delete(held.id);
    }

    await _deleteByPedal(changeLogs, (row) => row.pedalId, pedalId);
    await _deleteByPedal(configurations, (row) => row.pedalId, pedalId);
    await _deleteByPedal(pedalControls, (row) => row.pedalId, pedalId);
    await _deleteByPedal(midiDeviceLinks, (row) => row.pedalId, pedalId);
    await _deleteByPedal(signalBlocks, (row) => row.pedalId, pedalId);

    final deletedRows = await (delete(
      pedals,
    )..where((row) => row.id.equals(pedalId))).go();

    return deletedRows > 0;
  }

  /// Deletes every row of [table] whose pedal column holds [pedalId].
  Future<void> _deleteByPedal<T extends Table, R>(
    TableInfo<T, R> table,
    Expression<int> Function(T row) pedalColumn,
    int pedalId,
  ) async {
    await (delete(
      table,
    )..where((row) => pedalColumn(row).equals(pedalId))).go();
  }
}
