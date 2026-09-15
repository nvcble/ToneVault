import 'midi_message.dart';

enum MidiDirection { incoming, outgoing }

/// One message the [MidiEngine] sent or received, for the MIDI Monitor.
///
/// A record of what happened on the wire, not a decision about it - the
/// Monitor is read-only.
class MidiLogEntry {
  const MidiLogEntry({required this.direction, required this.message, required this.timestamp});

  final MidiDirection direction;
  final MidiMessage message;
  final DateTime timestamp;
}
