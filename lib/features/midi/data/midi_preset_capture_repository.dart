import 'dart:typed_data';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/midi_preset_capture_dao.dart';
import '../../../core/midi/profiles/nux_mg30_v5/nux_mg30_v5_preset_decoder.dart';
import '../../../core/midi/profiles/nux_mg30_v5/nux_mg30_v5_preset_decoder_json.dart';

/// Raw SysEx preset dumps kept alongside whatever a decoder made of them -
/// see `midi_preset_captures_table.dart` for why this stays separate from
/// the Patch/Scene library.
class MidiPresetCaptureRepository {
  const MidiPresetCaptureRepository(this._dao);

  final MidiPresetCaptureDao _dao;

  Stream<List<MidiPresetCapture>> watchCaptures(int pedalId) =>
      _dao.watchCaptures(pedalId);

  Future<MidiPresetCapture?> findByProgramNumber(
    int pedalId,
    int programNumber,
  ) => _dao.findByProgramNumber(pedalId, programNumber);

  /// Replaces any earlier capture of the same [pedalId]/[programNumber] -
  /// deliberate for a single manual read (the user just asked to read this
  /// slot again), unlike a bulk capture run, which asks before replacing
  /// anything already stored.
  Future<void> saveCapture({
    required int pedalId,
    required String deviceProfileId,
    required int programNumber,
    required Uint8List rawSysEx,
    DecodedNuxMg30V5Preset? decoded,
    String? firmwareLabel,
    DateTime Function()? clock,
  }) {
    return _dao.upsertCapture(
      pedalId: pedalId,
      deviceProfileId: deviceProfileId,
      programNumber: programNumber,
      rawSysEx: rawSysEx,
      decodedName: decoded?.name,
      decodedSummaryJson: decoded == null
          ? null
          : encodeDecodedPresetAsJson(decoded),
      firmwareLabel: firmwareLabel,
      capturedAt: (clock ?? DateTime.now)(),
    );
  }

  Future<bool> deleteCapture(int id) => _dao.deleteCapture(id);
}
