import '../../../core/midi/midi_engine.dart';
import '../../../core/midi/midi_message.dart';
import '../../../core/midi/midi_request_failure.dart';
import '../../../core/midi/profiles/nux_mg30_v5/nux_mg30_v5_sysex.dart';

/// Reads one MG-30 preset by program number over the experimental SysEx
/// protocol in [NuxMg30V5SysEx] - see that class for why this is unverified
/// for V5. Isolated here so nothing device-specific leaks into [MidiEngine]
/// or a widget.
class NuxMg30V5PresetReader {
  const NuxMg30V5PresetReader(this._engine);

  final MidiEngine _engine;

  /// Throws [MidiRequestTimedOut] if the device does not answer within
  /// [timeout] - a real possibility given this command has never been tried
  /// against this app's own hardware.
  Future<MidiMessage> readPreset(int programNumber, {Duration timeout = const Duration(seconds: 5)}) {
    return _engine.request(
      NuxMg30V5SysEx.getPresetDataRequest(programNumber),
      matches: (message) =>
          NuxMg30V5SysEx.isPresetDataResponse(message) &&
          NuxMg30V5SysEx.presetResponseProgramNumber(message) == programNumber,
      timeout: timeout,
    );
  }
}
