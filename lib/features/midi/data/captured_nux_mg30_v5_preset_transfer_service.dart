import '../../../core/database/app_database.dart';
import '../../../core/midi/midi_message.dart';
import '../../../core/midi/midi_support_level.dart';
import '../../../core/midi/preset_transfer/imported_preset.dart';
import '../../../core/midi/preset_transfer/nux_mg30_v5_preset_transfer_service.dart';
import '../../../core/midi/profiles/nux_mg30_v5/nux_mg30_v5_preset_decoder.dart';
import 'midi_preset_capture_repository.dart';

/// Turns raw captures already saved from MIDI Diagnostics into
/// [ImportedPreset]s - see that interface's own documentation for why this
/// is not the same thing as a verified live transfer, even though it
/// satisfies the same contract.
///
/// Every preset this produces carries
/// [MidiSupportLevel.needsHardwareVerification]: decoding a capture with the
/// same logic used elsewhere does not make the MG-30 V5 protocol confirmed,
/// only reachable to review before trusting it.
class CapturedNuxMg30V5PresetTransferService implements NuxMg30V5PresetTransferService {
  const CapturedNuxMg30V5PresetTransferService(this._captures, this._unitId);

  final MidiPresetCaptureRepository _captures;
  final int _unitId;

  @override
  Future<List<ImportedPreset>> importAllPresets({
    void Function(int completed, int total)? onProgress,
  }) async {
    final rows = await _captures.watchCaptures(_unitId).first;
    final presets = <ImportedPreset>[];
    for (var i = 0; i < rows.length; i++) {
      final preset = _decode(rows[i]);
      if (preset != null) {
        presets.add(preset);
      }
      onProgress?.call(i + 1, rows.length);
    }
    return presets;
  }

  /// Null when [row]'s bytes do not decode - skipped rather than crashing
  /// the whole review list over one bad capture.
  ImportedPreset? _decode(MidiPresetCapture row) {
    try {
      final bytes = row.rawSysEx;
      final message = SysExMessage(payload: bytes.sublist(1, bytes.length - 1));
      final decoded = decodeNuxMg30V5Preset(message);
      return ImportedPreset(
        programNumber: decoded.programNumber,
        name: decoded.name ?? 'Program ${decoded.programNumber}',
        confidence: MidiSupportLevel.needsHardwareVerification,
        blocks: [
          for (final block in decoded.blocks)
            ImportedBlock(label: block.label, modelNumber: block.modelCode),
        ],
      );
    } catch (_) {
      return null;
    }
  }
}
