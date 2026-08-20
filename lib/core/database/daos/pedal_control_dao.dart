import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/pedal_controls_table.dart';
import '../tables/pedals_table.dart';

part 'pedal_control_dao.g.dart';

/// One control, with the pedal it is on.
///
/// The owner is carried alongside because a configuration of a multi-effects
/// unit can set controls that live on several pedals, and a bare control cannot
/// say which.
typedef OwnedControl = ({Pedal owner, PedalControl control});

/// Typed queries over the `pedal_controls` table.
///
/// Validation, domain rules and error translation belong to
/// `ControlRepository`; this class only reads and writes rows.
@DriftAccessor(tables: [PedalControls, Pedals])
class PedalControlDao extends DatabaseAccessor<AppDatabase>
    with _$PedalControlDaoMixin {
  PedalControlDao(super.attachedDatabase);

  /// One pedal's controls in the order the user arranged them.
  ///
  /// Name is the tie-breaker so a pedal whose controls were all inserted at the
  /// same order never lists them differently between two reads.
  Stream<List<PedalControl>> watchControls(int pedalId) {
    return (select(pedalControls)
          ..where((row) => row.pedalId.equals(pedalId))
          ..orderBy([
            (row) => OrderingTerm.asc(row.displayOrder),
            (row) => OrderingTerm.asc(row.name.collate(Collate.noCase)),
          ]))
        .watch();
  }

  Future<List<PedalControl>> controlsOf(int pedalId) {
    return (select(pedalControls)
          ..where((row) => row.pedalId.equals(pedalId))
          ..orderBy([(row) => OrderingTerm.asc(row.displayOrder)]))
        .get();
  }

  /// Every control a configuration of [pedalId] can set, each with its pedal.
  ///
  /// One query covers both shapes a configuration takes. An ordinary pedal holds
  /// no other pedals, so only its own controls match and this is exactly
  /// [watchControls]. A multi-effects unit in scene mode has no controls of its
  /// own, so what comes back is the controls of the pedals on its patch - which
  /// is what a scene sets.
  Stream<List<OwnedControl>> watchSettableControls(int pedalId) =>
      _settable(pedalId).watch().map(_owned);

  Future<List<PedalControl>> settableControlsOf(int pedalId) async {
    final rows = await _settable(pedalId).get();
    return [for (final row in _owned(rows)) row.control];
  }

  /// [controlId] with the pedal it is on, but only when a configuration of
  /// [pedalId] may set it.
  ///
  /// Null covers both a control that is gone and one that belongs to neither
  /// this pedal nor a pedal inside it; the caller cannot act differently on the
  /// two, so they read the same.
  ///
  /// The pedal comes back with it because the join has it already, and the
  /// history of a scene needs it: it names the pedal on the patch the control
  /// belongs to.
  Future<OwnedControl?> findSettableControl({
    required int controlId,
    required int pedalId,
  }) async {
    final query = _settable(pedalId)..where(pedalControls.id.equals(controlId));
    final row = await query.getSingleOrNull();
    return row == null ? null : _owned([row]).single;
  }

  /// The controls of [pedalId] and of the pedals inside it, the pedal's own
  /// first and then the others by name, so a scene reads down the patch the same
  /// way every time.
  JoinedSelectStatement<HasResultSet, dynamic> _settable(int pedalId) {
    return select(
        pedalControls,
      ).join([innerJoin(pedals, pedals.id.equalsExp(pedalControls.pedalId))])
      ..where(pedals.id.equals(pedalId) | pedals.hostPedalId.equals(pedalId))
      ..orderBy([
        OrderingTerm.desc(pedals.id.equals(pedalId)),
        OrderingTerm.asc(pedals.name.collate(Collate.noCase)),
        OrderingTerm.asc(pedalControls.displayOrder),
        OrderingTerm.asc(pedalControls.name.collate(Collate.noCase)),
      ]);
  }

  List<OwnedControl> _owned(List<TypedResult> rows) => [
    for (final row in rows)
      (owner: row.readTable(pedals), control: row.readTable(pedalControls)),
  ];

  Stream<PedalControl?> watchControl(int controlId) {
    return (select(
      pedalControls,
    )..where((row) => row.id.equals(controlId))).watchSingleOrNull();
  }

  Future<PedalControl?> findControl(int controlId) {
    return (select(
      pedalControls,
    )..where((row) => row.id.equals(controlId))).getSingleOrNull();
  }

  Future<int> insertControl(PedalControlsCompanion control) =>
      into(pedalControls).insert(control);

  /// Returns whether a row matched [controlId].
  Future<bool> updateControl(
    int controlId,
    PedalControlsCompanion changes,
  ) async {
    final changedRows = await (update(
      pedalControls,
    )..where((row) => row.id.equals(controlId))).write(changes);
    return changedRows > 0;
  }

  Future<bool> deleteControl(int controlId) async {
    final deletedRows = await (delete(
      pedalControls,
    )..where((row) => row.id.equals(controlId))).go();
    return deletedRows > 0;
  }

  /// The order a newly added control takes, which is the end of the list.
  Future<int> nextDisplayOrder(int pedalId) async {
    final highest = pedalControls.displayOrder.max();
    final query = selectOnly(pedalControls)
      ..addColumns([highest])
      ..where(pedalControls.pedalId.equals(pedalId));

    final row = await query.getSingle();
    return (row.read(highest) ?? -1) + 1;
  }

  /// Renumbers [controlIdsInOrder] to 0, 1, 2 and so on.
  ///
  /// A batch is one statement round-trip and one transaction, so the list is
  /// never observed half-renumbered by the watching query.
  Future<void> applyOrder(List<int> controlIdsInOrder) async {
    await batch((batch) {
      for (final (index, controlId) in controlIdsInOrder.indexed) {
        batch.update(
          pedalControls,
          PedalControlsCompanion(displayOrder: Value(index)),
          where: (row) => row.id.equals(controlId),
        );
      }
    });
  }
}
