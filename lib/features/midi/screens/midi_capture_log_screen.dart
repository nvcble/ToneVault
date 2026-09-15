import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/midi/midi_log_entry.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../data/midi_capture_export.dart';
import '../providers/midi_capture_controller.dart';
import '../widgets/midi_log_tile.dart';

/// Everything the open capture has recorded, on a page of its own.
///
/// Kept off MIDI Diagnostics deliberately: a 218-byte preset reply is one row
/// here, and a capture of a few seconds of real traffic buried every other
/// diagnostic control under it. Diagnostics starts and stops a capture; this
/// is where the bytes are read and exported.
class MidiCaptureLogScreen extends ConsumerWidget {
  const MidiCaptureLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capture = ref.watch(midiCaptureProvider);
    final entries = capture.entries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Export capture',
            onPressed: entries.isEmpty ? null : () => _export(context, entries),
          ),
        ],
      ),
      body: entries.isEmpty
          ? EmptyState(
              icon: Icons.cable,
              title: 'Nothing captured yet',
              message: capture.isCapturing
                  ? 'Capturing. Use the device - change a patch, tap a footswitch - '
                        'and whatever it sends will appear here.'
                  : 'Start a capture on the Diagnostics screen first.',
            )
          : ListView.builder(
              // Newest first: the reply to whatever was just tried is the row
              // being looked for.
              itemCount: entries.length,
              itemBuilder: (context, index) =>
                  MidiLogTile(entry: entries[entries.length - 1 - index]),
            ),
    );
  }

  Future<void> _export(BuildContext context, List<MidiLogEntry> entries) async {
    final choice = await showModalBottomSheet<_ExportFormat>(
      context: context,
      builder: (context) => const _ExportFormatSheet(),
    );
    if (choice == null) {
      return;
    }
    try {
      switch (choice) {
        case _ExportFormat.json:
          await shareCaptureFile(
            utf8.encode(encodeCaptureAsJson(entries)),
            fileName: 'tonevault-capture.json',
            mimeType: 'application/json',
          );
        case _ExportFormat.text:
          await shareCaptureFile(
            utf8.encode(encodeCaptureAsText(entries)),
            fileName: 'tonevault-capture.txt',
            mimeType: 'text/plain',
          );
        case _ExportFormat.syx:
          await shareCaptureFile(
            encodeCaptureAsSyx(entries),
            fileName: 'tonevault-capture.syx',
            mimeType: 'application/octet-stream',
          );
      }
    } catch (error) {
      if (context.mounted) showFailureSnackBar(context, error);
    }
  }
}

enum _ExportFormat { json, text, syx }

class _ExportFormatSheet extends StatelessWidget {
  const _ExportFormatSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('JSON'),
            onTap: () => Navigator.of(context).pop(_ExportFormat.json),
          ),
          ListTile(
            title: const Text('Plain text'),
            onTap: () => Navigator.of(context).pop(_ExportFormat.text),
          ),
          ListTile(
            title: const Text('.syx (raw bytes)'),
            onTap: () => Navigator.of(context).pop(_ExportFormat.syx),
          ),
        ],
      ),
    );
  }
}
