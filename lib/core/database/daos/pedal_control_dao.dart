import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/pedal_controls_table.dart';

part 'pedal_control_dao.g.dart';

/// Typed queries over the `pedal_controls` table.
///
/// Validation, domain rules and error translation belong to
/// `ControlRepository`; this class only reads and writes rows.
@DriftAccessor(tables: [PedalControls])
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
