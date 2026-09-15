import 'imported_preset.dart';

/// Reads saved presets off a real NUX MG-30 (V5), read-only.
///
/// No implementation of this backed by a real transport exists yet. NUX has
/// not published a SysEx protocol for the V5, and the unit's own MIDI
/// implementation chart names no command for reading a saved patch back -
/// see `nuxMg30V5Capabilities[MidiFeature.patchTransfer]`, which is
/// [MidiSupportLevel.unknown] for exactly this reason.
///
/// Confirming this needs one of: an official SysEx specification from NUX
/// for V5 firmware, or a MIDI capture of NUX's own editor software reading a
/// saved patch off a real unit, byte-decoded and verified against known
/// patch contents before any of it is trusted.
///
/// [MockNuxMg30V5PresetTransferService] exists so the import pipeline and its
/// screens can be built and tested against this contract now. Nothing
/// implementing this interface may be wired into a *live* device connection
/// until that protocol is confirmed - see that class's own documentation.
///
/// `CapturedNuxMg30V5PresetTransferService`
/// (`lib/features/midi/data/captured_nux_mg30_v5_preset_transfer_service.dart`)
/// is the one exception, and not really an exception at all: it never talks
/// to the device. It replays raw SysEx bytes the user already captured and
/// chose to save in MIDI Diagnostics, through the same experimental decoder -
/// still marked [MidiSupportLevel.needsHardwareVerification] throughout, and
/// reachable only from an explicitly "Experimental" screen.
abstract class NuxMg30V5PresetTransferService {
  /// Every preset saved on the connected device, read-only.
  ///
  /// [onProgress] reports how many of [total] have been read so far, for a
  /// progress bar.
  Future<List<ImportedPreset>> importAllPresets({
    void Function(int completed, int total)? onProgress,
  });
}
