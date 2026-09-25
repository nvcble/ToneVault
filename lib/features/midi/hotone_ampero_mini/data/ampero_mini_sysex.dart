import '../../../../core/midi/midi_message.dart';

/// The constant prefix every SysEx message captured from an Ampero Mini
/// starts with, taken as the bytes after the 0xF0 start byte.
///
/// REVERSE-ENGINEERED from two captures on the user's own unit. `4D 50` is
/// ASCII "MP", which matches how sibling Ampero units identify themselves,
/// but the remaining bytes are treated as one opaque constant rather than
/// guessed at as manufacturer/model/firmware fields - nothing observed so far
/// distinguishes them.
const List<int> amperoMiniSysExPrefix = [
  0x21,
  0x25,
  0x7F,
  0x4D,
  0x50,
  0x2D,
  0x32,
  0x12,
  0x00,
  0x02,
  0x06,
];

/// Message type byte that follows [amperoMiniSysExPrefix].
const int _typeTick = 0x04;
const int _typeStatus = 0x05;

/// Something an Ampero Mini said, unprompted.
///
/// The pedal broadcasts these on its own; none of them is a reply to a
/// request, because no request command for this model has been confirmed.
sealed class AmperoMiniReport {
  const AmperoMiniReport();
}

/// The counter the pedal emits with every [AmperoMiniStatusReport].
///
/// `04 <hi> <lo>`, read as the 14-bit `hi * 128 + lo` that the two captures
/// show it to be.
///
/// VERIFIED ON HARDWARE that this is a counter and **not** a patch index. Both
/// captures pair it one-for-one with the status broadcast, within a few
/// milliseconds, and it rises by exactly 1 every beat: 130..140 in the capture
/// of 20:08, and 1..10 in the capture of 23:17, which is lower because the
/// pedal had been restarted in between. In that second capture the value
/// advanced ten times while at most two patches were changed - so it tracks
/// time, not patches. What it counts is UNKNOWN.
///
/// This replaces an earlier reading of `04 01 <index>` as "the patch I have
/// loaded". That was wrong: the capture it came from was ten footswitch presses
/// made at roughly one per second, so a once-a-second counter matched them by
/// coincidence. The consequence is that **the pedal is not known to report its
/// patch at all**, and nothing may claim its state is confirmed.
class AmperoMiniTickReport extends AmperoMiniReport {
  const AmperoMiniTickReport(this.counter);

  final int counter;

  @override
  String toString() => 'AmperoMiniTickReport($counter)';
}

/// The pedal's roughly-once-a-second status broadcast.
///
/// UNKNOWN meaning. Its payload was `00 00 00 78` on every message of both
/// captures except one, which carried `00 00 01 16`; nothing observed
/// explains the difference, so [payload] is kept verbatim rather than decoded
/// into fields that would only be invented.
class AmperoMiniStatusReport extends AmperoMiniReport {
  const AmperoMiniStatusReport(this.payload);

  final List<int> payload;

  @override
  String toString() => 'AmperoMiniStatusReport(${hexBytes(payload)})';
}

/// A SysEx message that carries the Ampero Mini's prefix but a body nothing
/// here recognises.
///
/// Exists so an unfamiliar message is visibly unfamiliar instead of being
/// forced into one of the shapes above. [body] is everything after the
/// prefix, so a later capture can be re-read without re-running it.
class AmperoMiniUnrecognizedReport extends AmperoMiniReport {
  const AmperoMiniUnrecognizedReport(this.body);

  final List<int> body;

  @override
  String toString() => 'AmperoMiniUnrecognizedReport(${hexBytes(body)})';
}

/// Decodes [message] if it is an Ampero Mini SysEx broadcast, or returns null
/// if it is anything else - a Program Change, a CC, or another device's SysEx.
///
/// Returning null rather than throwing is deliberate: this reads a live stream
/// that legitimately carries traffic this device knows nothing about.
AmperoMiniReport? decodeAmperoMiniReport(MidiMessage message) {
  if (message is! SysExMessage) {
    return null;
  }
  final payload = message.payload;
  if (!_startsWithPrefix(payload)) {
    return null;
  }

  final body = payload.sublist(amperoMiniSysExPrefix.length);
  if (body.isEmpty) {
    return AmperoMiniUnrecognizedReport(body);
  }

  if (body[0] == _typeTick && body.length == 3) {
    return AmperoMiniTickReport(body[1] * 128 + body[2]);
  }
  if (body[0] == _typeStatus) {
    return AmperoMiniStatusReport(body.sublist(1));
  }
  return AmperoMiniUnrecognizedReport(body);
}

bool _startsWithPrefix(List<int> payload) {
  if (payload.length < amperoMiniSysExPrefix.length) {
    return false;
  }
  for (var i = 0; i < amperoMiniSysExPrefix.length; i++) {
    if (payload[i] != amperoMiniSysExPrefix[i]) {
      return false;
    }
  }
  return true;
}
