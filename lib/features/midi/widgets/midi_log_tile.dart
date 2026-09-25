import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/midi/midi_log_entry.dart';
import '../../../core/midi/midi_message.dart';

/// One line of the MIDI Monitor: timestamp, direction, message type, channel
/// and the exact bytes sent or received - see section 13 of the MIDI module
/// brief. Tapping copies the raw bytes, since that's what someone
/// reverse-engineering the device against a spec sheet or a capture from
/// NUX's own software actually needs to paste elsewhere.
class MidiLogTile extends StatelessWidget {
  const MidiLogTile({required this.entry, super.key});

  final MidiLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final isOutgoing = entry.direction == MidiDirection.outgoing;
    final hh = entry.timestamp.hour.toString().padLeft(2, '0');
    final mm = entry.timestamp.minute.toString().padLeft(2, '0');
    final ss = entry.timestamp.second.toString().padLeft(2, '0');
    final ms = entry.timestamp.millisecond.toString().padLeft(3, '0');

    final channel = midiMessageChannel(entry.message);
    final failure = entry.failure;
    final subtitle = [
      midiMessageTypeLabel(entry.message),
      if (channel != null) 'Channel ${channel + 1}',
      if (failure != null) 'NOT SENT: $failure',
    ].join(' · ');
    final bytes = hexBytes(entry.message.toBytes());

    return ListTile(
      dense: true,
      leading: Icon(
        failure != null
            ? Icons.error_outline
            : isOutgoing
            ? Icons.arrow_upward
            : Icons.arrow_downward,
        color: failure != null ? Theme.of(context).colorScheme.error : null,
      ),
      title: Text(bytes, style: const TextStyle(fontFamily: 'monospace')),
      subtitle: Text(subtitle),
      trailing: Text('$hh:$mm:$ss.$ms'),
      onTap: () => _copyBytes(context, bytes),
    );
  }

  Future<void> _copyBytes(BuildContext context, String bytes) async {
    await Clipboard.setData(ClipboardData(text: bytes));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied raw bytes'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}
