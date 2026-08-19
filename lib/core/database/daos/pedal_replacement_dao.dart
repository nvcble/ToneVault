import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/pedal_replacements_table.dart';
import '../tables/pedals_table.dart';

part 'pedal_replacement_dao.g.dart';

/// One recorded swap together with both pedals it names.
///
/// A replacement only means anything as a pair, and neither side can go
/// missing - both foreign keys restrict the delete - so the two pedals are read
/// along with the row rather than looked up afterwards.
typedef PedalSwap = ({
  PedalReplacement replacement,
  Pedal outgoing,
  Pedal incoming,
});

/// Typed queries over the `pedal_replacements` table.
///
/// Validation, timestamps and error translation belong to
/// `ReplacementRepository`; this class only reads and writes rows.
@DriftAccessor(tables: [PedalReplacements, Pedals])
class PedalReplacementDao extends DatabaseAccessor<AppDatabase>
    with _$PedalReplacementDaoMixin {
  PedalReplacementDao(super.attachedDatabase);

  /// Every swap [pedalId] takes part in, newest first, whichever side of it the
  /// pedal is on.
  ///
  /// One query covers both directions because a pedal can have been retired by
  /// a newer one and have taken over from an older one, and its screen says so
  /// both ways.
  Stream<List<PedalSwap>> watchSwaps(int pedalId) {
    // The same table twice in one query, so each side needs its own name.
    final outgoing = alias(pedals, 'outgoing');
    final incoming = alias(pedals, 'incoming');

    final query =
        select(pedalReplacements).join([
            innerJoin(
              outgoing,
              outgoing.id.equalsExp(pedalReplacements.oldPedalId),
            ),
            innerJoin(
              incoming,
              incoming.id.equalsExp(pedalReplacements.newPedalId),
            ),
          ])
          ..where(
            pedalReplacements.oldPedalId.equals(pedalId) |
                pedalReplacements.newPedalId.equals(pedalId),
          )
          // Same-day swaps still read in the order they were entered.
          ..orderBy([
            OrderingTerm.desc(pedalReplacements.replacedAt),
            OrderingTerm.desc(pedalReplacements.id),
          ]);

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => (
              replacement: row.readTable(pedalReplacements),
              outgoing: row.readTable(outgoing),
              incoming: row.readTable(incoming),
            ),
          )
          .toList(),
    );
  }

  /// The swap that retired [outgoingPedalId], if it has already been replaced.
  Future<PedalReplacement?> findReplacementOf(int outgoingPedalId) {
    return (select(pedalReplacements)
          ..where((row) => row.oldPedalId.equals(outgoingPedalId)))
        .getSingleOrNull();
  }

  Future<int> insertSwap(PedalReplacementsCompanion swap) =>
      into(pedalReplacements).insert(swap);
}
