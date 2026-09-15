import 'midi_message.dart';

enum MidiDirection { incoming, outgoing }

/// One message the [MidiEngine] sent or received, for the MIDI Monitor.
///
/// A record of what happened on the wire, not a decision about it - the
/// Monitor is read-only.
class MidiLogEntry {
  const MidiLogEntry({
    required this.direction,
    required this.message,
    required this.timestamp,
    this.failure,
  });

  final MidiDirection direction;
  final MidiMessage message;
  final DateTime timestamp;

  /// Why this message never made it to the device, when it didn't.
  ///
  /// An attempted send is logged either way: a capture that only shows what
  /// succeeded cannot tell "ToneVault never sent anything" apart from "every
  /// send was refused", and those need completely different fixes.
  final String? failure;
}
