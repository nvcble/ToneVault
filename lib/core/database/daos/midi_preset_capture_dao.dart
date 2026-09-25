import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/midi_preset_captures_table.dart';

part 'midi_preset_capture_dao.g.dart';

/// Typed queries over `midi_preset_captures` - see that table's own
/// documentation for why raw and decoded data are kept side by side.
@DriftAccessor(tables: [MidiPresetCaptures])
class MidiPresetCaptureDao extends DatabaseAccessor<AppDatabase>
    with _$MidiPresetCaptureDaoMixin {
  MidiPresetCaptureDao(super.attachedDatabase);

  Stream<List<MidiPresetCapture>> watchCaptures(int pedalId) {
    return (select(midiPresetCaptures)
          ..where((row) => row.pedalId.equals(pedalId))
          ..orderBy([(row) => OrderingTerm.asc(row.programNumber)]))
        .watch();
  }

  Future<MidiPresetCapture?> findByProgramNumber(
    int pedalId,
    int programNumber,
  ) {
    return (select(midiPresetCaptures)..where(
          (row) =>
              row.pedalId.equals(pedalId) &
              row.programNumber.equals(programNumber),
        ))
        .getSingleOrNull();
  }

  /// Replaces whatever was captured for [pedalId]/[programNumber] before -
  /// one program number holds at most one capture, the most recent read of
  /// it.
  Future<void> upsertCapture({
    required int pedalId,
    required String deviceProfileId,
    required int programNumber,
    required Uint8List rawSysEx,
    String? decodedName,
    String? decodedSummaryJson,
    String? firmwareLabel,
    required DateTime capturedAt,
  }) {
    return into(midiPresetCaptures).insert(
      MidiPresetCapturesCompanion.insert(
        pedalId: pedalId,
        deviceProfileId: deviceProfileId,
        programNumber: programNumber,
        rawSysEx: rawSysEx,
        decodedName: Value(decodedName),
        decodedSummaryJson: Value(decodedSummaryJson),
        firmwareLabel: Value(firmwareLabel),
        capturedAt: capturedAt,
      ),
      onConflict: DoUpdate(
        (_) => MidiPresetCapturesCompanion(
          rawSysEx: Value(rawSysEx),
          decodedName: Value(decodedName),
          decodedSummaryJson: Value(decodedSummaryJson),
          firmwareLabel: Value(firmwareLabel),
          capturedAt: Value(capturedAt),
        ),
        target: [midiPresetCaptures.pedalId, midiPresetCaptures.programNumber],
      ),
    );
  }

  /// Returns whether a row existed to remove.
  Future<bool> deleteCapture(int id) async {
    final deletedRows = await (delete(
      midiPresetCaptures,
    )..where((row) => row.id.equals(id))).go();
    return deletedRows > 0;
  }
}
