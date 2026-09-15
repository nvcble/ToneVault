import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/midi_patch_program_numbers_table.dart';
import '../tables/patches_table.dart';

part 'midi_patch_program_number_dao.g.dart';

/// A patch with the number it has been given, together - what Live Control's
/// Previous/Next cycle through.
typedef NumberedPatch = ({Patch patch, int programNumber});

/// Typed queries over `midi_patch_program_numbers`.
@DriftAccessor(tables: [MidiPatchProgramNumbers, Patches])
class MidiPatchProgramNumberDao extends DatabaseAccessor<AppDatabase>
    with _$MidiPatchProgramNumberDaoMixin {
  MidiPatchProgramNumberDao(super.attachedDatabase);

  /// Every numbered patch of [pedalId], ordered by the number it loads as.
  ///
  /// A patch with no number is left out: there is nothing to cycle to for
  /// one that has never been told which of the device's slots it is.
  Stream<List<NumberedPatch>> watchNumberedPatches(int pedalId) =>
      _numberedPatchesQuery(pedalId).watch().map(_toNumberedPatches);

  /// The same rows as [watchNumberedPatches], read once rather than
  /// subscribed to - for a one-off computation that has no reason to keep
  /// listening afterwards.
  Future<List<NumberedPatch>> numberedPatches(int pedalId) async =>
      _toNumberedPatches(await _numberedPatchesQuery(pedalId).get());

  JoinedSelectStatement<Object?, Object?> _numberedPatchesQuery(int pedalId) {
    return select(midiPatchProgramNumbers).join([
      innerJoin(patches, patches.id.equalsExp(midiPatchProgramNumbers.patchId)),
    ])
      ..where(patches.pedalId.equals(pedalId))
      ..orderBy([OrderingTerm.asc(midiPatchProgramNumbers.programNumber)]);
  }

  List<NumberedPatch> _toNumberedPatches(List<TypedResult> rows) => [
    for (final row in rows)
      (patch: row.readTable(patches), programNumber: row.readTable(midiPatchProgramNumbers).programNumber),
  ];

  Stream<MidiPatchProgramNumber?> watchNumber(int patchId) {
    return (select(
      midiPatchProgramNumbers,
    )..where((row) => row.patchId.equals(patchId))).watchSingleOrNull();
  }

  Future<MidiPatchProgramNumber?> findNumber(int patchId) {
    return (select(
      midiPatchProgramNumbers,
    )..where((row) => row.patchId.equals(patchId))).getSingleOrNull();
  }

  /// Stores [programNumber] for [patchId], replacing whatever was there
  /// before.
  Future<void> upsertNumber({
    required int patchId,
    required int programNumber,
    required DateTime updatedAt,
  }) {
    return into(midiPatchProgramNumbers).insert(
      MidiPatchProgramNumbersCompanion.insert(
        patchId: patchId,
        programNumber: programNumber,
        updatedAt: updatedAt,
      ),
      onConflict: DoUpdate(
        (_) => MidiPatchProgramNumbersCompanion(
          programNumber: Value(programNumber),
          updatedAt: Value(updatedAt),
        ),
        target: [midiPatchProgramNumbers.patchId],
      ),
    );
  }

  /// Returns whether a row existed to remove.
  Future<bool> deleteNumber(int patchId) async {
    final deletedRows = await (delete(
      midiPatchProgramNumbers,
    )..where((row) => row.patchId.equals(patchId))).go();
    return deletedRows > 0;
  }
}
