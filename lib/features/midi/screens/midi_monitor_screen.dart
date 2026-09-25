import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/empty_state.dart';
import '../providers/midi_monitor_controller.dart';
import '../widgets/midi_log_tile.dart';

/// Every MIDI message sent or received since this screen was last opened -
/// see section 13 of the MIDI module brief.
class MidiMonitorScreen extends ConsumerWidget {
  const MidiMonitorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(midiMonitorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MIDI Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear',
            onPressed: () => ref.read(midiMonitorProvider.notifier).clear(),
          ),
        ],
      ),
      body: entries.isEmpty
          ? const EmptyState(
              icon: Icons.terminal,
              title: 'Nothing logged yet',
              message:
                  'Every message sent to or received from the device will show up here.',
            )
          : ListView.builder(
              reverse: true,
              itemCount: entries.length,
              itemBuilder: (context, index) =>
                  MidiLogTile(entry: entries[entries.length - 1 - index]),
            ),
    );
  }
}
