import 'dart:convert';
import 'dart:typed_data';

import 'package:share_plus/share_plus.dart' show SharePlus, ShareParams, XFile;

import '../../../core/errors/app_failure.dart';
import '../../../core/midi/midi_log_entry.dart';
import '../../../core/midi/midi_message.dart';

/// Turns one capture into the diagnostic file formats the brief asks for -
/// never an interpretation of what the bytes mean, only what they were.
///
/// [encodeCaptureAsJson] and [encodeCaptureAsText] are for reading a capture
/// back later (by a person, or eventually a decoder); [encodeCaptureAsSyx]
/// is the raw wire bytes only, the shape a `.syx` file editor or another MIDI
/// tool expects.
String encodeCaptureAsJson(List<MidiLogEntry> entries) => const JsonEncoder.withIndent(
  '  ',
).convert([
  for (final entry in entries)
    {
      'timestamp': entry.timestamp.toIso8601String(),
      'direction': entry.direction.name,
      'type': midiMessageTypeLabel(entry.message),
      'channel': midiMessageChannel(entry.message),
      'bytes': hexBytes(entry.message.toBytes()),
      // Present only when a send was refused, so a capture shows the failures
      // as well as the traffic - see [MidiLogEntry.failure].
      if (entry.failure != null) 'failure': entry.failure,
    },
]);

String encodeCaptureAsText(List<MidiLogEntry> entries) => entries
    .map((entry) {
      final direction = entry.direction == MidiDirection.outgoing ? 'TX' : 'RX';
      return '${entry.timestamp.toIso8601String()}  $direction  '
          '${midiMessageTypeLabel(entry.message)}  ${hexBytes(entry.message.toBytes())}'
          '${entry.failure == null ? '' : '  NOT SENT: ${entry.failure}'}';
    })
    .join('\n');

/// Raw SysEx frames only, concatenated in capture order - what a `.syx` file
/// holds, and nothing else.
///
/// Channel messages are left out deliberately: a real capture is mostly
/// Program Change and Control Change, and interleaving those `C0`/`B0` bytes
/// between frames produces a file no SysEx tool can read. Use
/// [encodeCaptureAsJson] or [encodeCaptureAsText] for the full capture.
Uint8List encodeCaptureAsSyx(List<MidiLogEntry> entries) => Uint8List.fromList([
  for (final entry in entries)
    if (entry.message is SysExMessage) ...entry.message.toBytes(),
]);

/// Hands a capture to the system share sheet, the same way
/// `lib/features/backup/data/backup_files.dart` shares a backup - no storage
/// permission, no folder of ToneVault's own.
Future<void> shareCaptureFile(
  Uint8List bytes, {
  required String fileName,
  required String mimeType,
}) async {
  try {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: mimeType)],
        fileNameOverrides: [fileName],
        subject: fileName,
      ),
    );
  } catch (error) {
    throw AppFailure('Could not pass the capture on to be saved.', cause: error);
  }
}
