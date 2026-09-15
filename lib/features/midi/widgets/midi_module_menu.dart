import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';

/// Every other MIDI screen, behind one overflow button in the module header.
///
/// One menu rather than a row of app-bar icons plus a "More" list further down:
/// six destinations is more than an app bar holds as icons without squeezing
/// the title out, and splitting the same kind of navigation across two
/// different widgets meant looking in two places for it.
class MidiModuleMenu extends StatelessWidget {
  const MidiModuleMenu({required this.profileId, super.key});

  final String profileId;

  @override
  Widget build(BuildContext context) {
    final destinations = <(String, IconData, String)>[
      ('Live Control', Icons.play_circle_outline, Routes.liveControl(profileId)),
      ('Patches', Icons.folder_copy_outlined, Routes.midiPatches(profileId)),
      ('All Parameters', Icons.list, Routes.midiParameters(profileId)),
      ('CC Mapping', Icons.tune, Routes.midiMapping(profileId)),
      ('MIDI Monitor', Icons.terminal, Routes.midiMonitor(profileId)),
      ('MIDI Diagnostics', Icons.biotech, Routes.midiDiagnostics(profileId)),
    ];

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'More',
      onSelected: (route) => context.push(route),
      itemBuilder: (context) => [
        for (final (label, icon, route) in destinations)
          PopupMenuItem<String>(
            value: route,
            child: Row(
              children: [
                // A popup menu is only so wide, and the longest label here plus
                // an icon at its default size does not fit: it overflowed, which
                // clips the end of the word. The smaller icon buys the room, and
                // Expanded keeps a larger font size shortening the label rather
                // than overflowing again.
                Icon(icon, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
      ],
    );
  }
}
