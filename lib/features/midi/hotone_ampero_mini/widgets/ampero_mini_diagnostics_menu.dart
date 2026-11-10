import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import 'ampero_mini_name_sync_sheet.dart';
import 'ampero_mini_read_probe_sheet.dart';

/// Not a route: picks the read-probe sheet instead of pushing a screen.
const _probeValue = 'ampero_mini_read_probe';
const _syncValue = 'ampero_mini_name_sync';

/// Reaches the generic MIDI Monitor and MIDI Diagnostics screens only -
/// deliberately not the full `MidiModuleMenu`, which also links to
/// NUX-specific destinations (Live Control's Scenes, the pedal-linked
/// Patches screen) that do not apply to the Ampero Mini.
///
/// This is how a capture like the one used to reverse-engineer the device's
/// SysEx broadcasts gets made: Diagnostics starts/stops it and exports the
/// same JSON shape used for that capture.
class AmperoMiniDiagnosticsMenu extends StatelessWidget {
  const AmperoMiniDiagnosticsMenu({required this.profileId, super.key});

  final String profileId;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'More',
      onSelected: (value) => switch (value) {
        _probeValue => AmperoMiniReadProbeSheet.show(context),
        _syncValue => AmperoMiniNameSyncSheet.show(context),
        _ => context.push(value),
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: _syncValue,
          child: Row(
            children: [
              Icon(Icons.download, size: 20),
              SizedBox(width: 8),
              Text('Read pedal names'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: _probeValue,
          child: Row(
            children: [
              Icon(Icons.science, size: 20),
              SizedBox(width: 8),
              Text('Patch read probe'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: Routes.midiMonitor(profileId),
          child: const Row(
            children: [
              Icon(Icons.terminal, size: 20),
              SizedBox(width: 8),
              Text('MIDI Monitor'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: Routes.midiDiagnostics(profileId),
          child: const Row(
            children: [
              Icon(Icons.biotech, size: 20),
              SizedBox(width: 8),
              Text('MIDI Diagnostics'),
            ],
          ),
        ),
      ],
    );
  }
}
