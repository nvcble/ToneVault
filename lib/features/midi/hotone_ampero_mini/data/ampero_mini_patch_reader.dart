import '../../../../core/midi/midi_engine.dart';
import '../../../../core/midi/midi_message.dart';
import '../../../../core/midi/midi_request_failure.dart';
import 'ampero_mini_patch_layout.dart';
import 'ampero_mini_patch_name.dart';
import 'ampero_mini_read_probe.dart';

/// One slot's name as read from the pedal, with the frame it came from.
class AmperoMiniPatchRead {
  const AmperoMiniPatchRead({required this.name, required this.raw});
  final String name;
  final List<int> raw;
}

/// Why a read stopped. Never guessed past: the caller stops on any of these.
class AmperoMiniReadFailure implements Exception {
  const AmperoMiniReadFailure(this.index, this.reason, {this.raw});
  final int index;
  final String reason;

  /// The reply that failed to decode, if there was one.
  final List<int>? raw;

  /// The reply as hex, for a screenshot; empty when there was none.
  String get rawHex => raw == null
      ? ''
      : raw!.take(72).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

  @override
  String toString() => 'Slot ${index + 1}: $reason';
}

/// Reads patch names with the sequence verified on hardware 2026-11-10:
/// `08` selects the slot (the pedal acknowledges with `0C`), then `0D` returns
/// the data for the slot chosen by that last `08`.
class AmperoMiniPatchReader {
  const AmperoMiniPatchReader(
    this._engine, {
    this.timeout = const Duration(seconds: 2),
  });

  final MidiEngine _engine;
  final Duration timeout;

  /// User bank, verified on hardware for all 99 slots.
  static const int userBank = 1;

  /// Factory bank. UNVERIFIED on hardware: the editor's capture reads it with
  /// the same sequence, but this app has not yet seen the pedal answer.
  static const int factoryBank = 0;

  /// Reads absolute [patchNumber] (0-98 user, 99-197 factory, as in the patch
  /// list). Throws [AmperoMiniReadFailure] on silence or a reply that does not
  /// decode for exactly that slot.
  Future<AmperoMiniPatchRead> readName(int patchNumber) async {
    final bank = amperoMiniIsUserPatch(patchNumber) ? userBank : factoryBank;
    final index = amperoMiniIsUserPatch(patchNumber)
        ? patchNumber
        : patchNumber - amperoMiniUserPatchCount;
    try {
      await _engine.request(
        buildAmperoMiniReadProbe(bank: bank, index: index),
        matches: (m) =>
            m is SysExMessage &&
            isAmperoMiniProbeAck(m.payload, bank: bank, index: index),
        timeout: timeout,
      );
      final reply = await _engine.request(
        buildAmperoMiniReadProbe(
          bank: bank,
          index: index,
          step: AmperoMiniProbeStep.request0D,
        ),
        matches: (m) => m is SysExMessage && _isFirstDataFrame(m.payload),
        timeout: timeout,
      );
      final payload = (reply as SysExMessage).payload;
      final name = decodeAmperoMiniPatchName(payload, index: index);
      if (name == null) {
        throw AmperoMiniReadFailure(
          patchNumber,
          'reply did not decode to a name',
          raw: payload,
        );
      }
      return AmperoMiniPatchRead(name: name, raw: payload);
    } on MidiRequestTimedOut {
      throw AmperoMiniReadFailure(patchNumber, 'the pedal did not answer');
    }
  }

  /// A `12 00 02 0E` frame whose chunk counter is 0 (see the decoder).
  static bool _isFirstDataFrame(List<int> p) =>
      p.length > 7 + 4 + 4 &&
      p[7] == 0x12 &&
      p[8] == 0x00 &&
      p[9] == 0x02 &&
      p[10] == 0x0E &&
      p[7 + 4 + 4] == 0;
}
