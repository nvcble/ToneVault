import '../../../../core/midi/midi_device_profile.dart';
import '../../../../core/midi/midi_engine.dart';
import '../../../../core/midi/midi_message.dart';
import '../../../../core/midi/midi_patch_selection.dart';
import 'ampero_mini_bank_select_probe.dart';
import 'ampero_mini_patch_layout.dart';
import 'ampero_mini_read_probe.dart';
import 'ampero_mini_sysex.dart';

/// The Ampero Mini's own MIDI operations, built on the generic [MidiEngine] -
/// nothing NUX-specific, and nothing protocol-specific beyond what has
/// actually been confirmed on hardware. See `HotoneAmperoMiniProfile` for
/// what that is.
class HotoneAmperoMiniMidiService {
  const HotoneAmperoMiniMidiService(this._engine);

  final MidiEngine _engine;

  /// Selects [patchNumber] (0-197: 0-98 user, 99-197 factory).
  ///
  /// VERIFIED ON HARDWARE (2026-11-10, user report): CC 0 picks the bank
  /// (0 factory, 1 user) and Program Change the slot within it. Factory
  /// patches are sent as the editor does, `CC61=20, CC0=0, PC slot`; user
  /// patches as `CC0=1, PC slot`. The bank is always sent so a factory
  /// selection cannot leave a later user selection in the wrong bank. Only
  /// slot 0 of each bank was seen to move the pedal; other slots follow the
  /// same pattern but are not individually checked. Throws [ArgumentError]
  /// outside 0-197, and whatever [MidiEngine.send] throws (for example when
  /// nothing is connected).
  Future<void> selectPatch({
    required MidiDeviceProfile profile,
    required int patchNumber,
  }) async {
    if (patchNumber < 0 || patchNumber >= amperoMiniPatchCount) {
      throw ArgumentError.value(
        patchNumber,
        'patchNumber',
        'The Ampero Mini has patches 0-${amperoMiniPatchCount - 1}.',
      );
    }
    final channel = profile.defaultChannel;
    final isUser = amperoMiniIsUserPatch(patchNumber);
    await _engine.sendAll([
      if (!isUser)
        ControlChangeMessage(channel: channel, controller: 61, value: 20),
      ControlChangeMessage(
        channel: channel,
        controller: bankSelectMsbCc,
        value: isUser ? 1 : 0,
      ),
      ProgramChangeMessage(
        channel: channel,
        program: isUser ? patchNumber : patchNumber - amperoMiniUserPatchCount,
      ),
    ]);
  }

  /// Puts one EXPERIMENTAL Bank Select [attempt] on the wire and nothing else.
  ///
  /// Deliberately not called from [selectPatch] and deliberately returns
  /// nothing: no layout in [amperoMiniBankSelectAttempts] is confirmed, so this
  /// is only ever run because a user asked to try it while watching the pedal.
  /// Whether it worked is not knowable from here - this pedal has no confirmed
  /// way of reporting the patch it loaded.
  Future<void> sendBankSelectAttempt({
    required MidiDeviceProfile profile,
    required AmperoMiniBankSelectAttempt attempt,
  }) => _engine.sendAll(attempt.messages(profile.defaultChannel));

  /// Sends the one read-only request copied from Hotone's editor and records
  /// every Ampero SysEx that arrives within [listenFor]. See
  /// `ampero_mini_read_probe.dart` for what is and is not known.
  ///
  /// The pedal's unprompted tick/status broadcasts are left out of the result,
  /// since they would bury the reply. Throws whatever [MidiEngine.send] throws
  /// when nothing is connected.
  Future<AmperoMiniReadProbeResult> probeRead({
    required int bank,
    required int index,
    AmperoMiniProbeStep step = AmperoMiniProbeStep.request08,
    Duration listenFor = const Duration(seconds: 3),
  }) async {
    final request = buildAmperoMiniReadProbe(
      bank: bank,
      index: index,
      step: step,
    );
    final replies = <List<int>>[];
    final subscription = _engine.incoming.listen((message) {
      if (message is! SysExMessage) return;
      final payload = message.payload;
      if (payload.length < amperoMiniSysExHeader.length) return;
      for (var i = 0; i < amperoMiniSysExHeader.length; i++) {
        if (payload[i] != amperoMiniSysExHeader[i]) return;
      }
      if (decodeAmperoMiniReport(message) != null) return;
      replies.add(payload);
    });
    try {
      await _engine.send(request);
      await Future<void>.delayed(listenFor);
    } finally {
      await subscription.cancel();
    }
    return AmperoMiniReadProbeResult(
      sent: request.payload,
      replies: replies,
      acknowledged: replies.any(
        (payload) => isAmperoMiniProbeAck(payload, bank: bank, index: index),
      ),
    );
  }
}
