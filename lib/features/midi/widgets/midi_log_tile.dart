import 'package:flutter/material.dart';

import '../../../core/midi/midi_log_entry.dart';

/// One line of the MIDI Monitor.
class MidiLogTile extends StatelessWidget {
  const MidiLogTile({required this.entry, super.key});

  final MidiLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final isOutgoing = entry.direction == MidiDirection.outgoing;
    final hh = entry.timestamp.hour.toString().padLeft(2, '0');
    final mm = entry.timestamp.minute.toString().padLeft(2, '0');
    final ss = entry.timestamp.second.toString().padLeft(2, '0');

    return ListTile(
      dense: true,
      leading: Icon(isOutgoing ? Icons.arrow_upward : Icons.arrow_downward),
      title: Text(entry.message.toString()),
      trailing: Text('$hh:$mm:$ss'),
    );
  }
}
