import '../../../../core/midi/midi_device_profile.dart';
import '../../../../core/midi/midi_engine.dart';
import '../../../../core/midi/midi_message.dart';
import '../../../../core/midi/midi_patch_selection.dart';
import 'ampero_mini_bank_select_probe.dart';
import 'ampero_mini_read_probe.dart';
import 'ampero_mini_sysex.dart';

/// The Ampero Mini's own MIDI operations, built on the generic [MidiEngine] -
/// nothing NUX-specific, and nothing protocol-specific beyond what has
/// actually been confirmed on hardware. See `HotoneAmperoMiniProfile` for
/// what that is.
class HotoneAmperoMiniMidiService {
  const HotoneAmperoMiniMidiService(this._engine);

  final MidiEngine _engine;

  /// Sends a plain Program Change for [patchNumber] (0-127) - the one patch
  /// selection mechanism confirmed on real hardware. Throws
  /// [ArgumentError] for anything outside the range the wire can carry, and
  /// whatever [MidiEngine.send] throws (for example when nothing is
  /// connected) for anything else.
  Future<void> selectPatch({
    required MidiDeviceProfile profile,
    required int patchNumber,
  }) async {
    if (patchNumber < 0 || patchNumber > 127) {
      throw ArgumentError.value(
        patchNumber,
        'patchNumber',
        'Program Change only carries 0-127.',
      );
    }
    final defaults = profile.patchSelectionDefaults;
    if (defaults == null) {
      throw StateError(
        '${profile.displayName} has no confirmed patch selection mechanism.',
      );
    }
    final messages = buildPatchSelectionMessages(
      defaults: defaults,
      channel: profile.defaultChannel,
      patchNumber: patchNumber,
    );
    await _engine.sendAll(messages);
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
