import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import 'midi_scene_buttons.dart';

/// Everything that acts on whichever patch is loaded, in one column beside the
/// patch grid: the Pro Scene the player is on.
///
/// Scenes only. Tap tempo and the two assignable footswitches stood here too
/// and came off: the MG-30 exposes no CC that reaches any of the three, so the
/// buttons sent nothing - see `nuxMg30V5AssignableParameters`. They are still
/// listed on the CC Mapping screen for anyone who finds a route to them.
///
/// Callbacks in and nothing else - no provider, no device profile - so it lays
/// out the same whatever is on the other end of the cable, and a test can drive
/// it without one.
class MidiPerformanceRail extends StatelessWidget {
  const MidiPerformanceRail({
    required this.selectedScene,
    required this.onSelectScene,
    super.key,
  });

  final int? selectedScene;

  /// Null disables the buttons - the device is not connected, so there is
  /// nothing to send to.
  final void Function(int sceneNumber)? onSelectScene;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      // Centred in whatever height the rail is given - see `FillOrScroll` -
      // so one group of buttons sits beside the grid rather than clinging to
      // the top of a column of empty space.
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Flush with the buttons rather than using `SectionLabel`, whose own
        // indent is meant for full-width settings rows.
        Text(
          'Scenes',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        MidiSceneButtons(selectedScene: selectedScene, onSelect: onSelectScene),
      ],
    );
  }
}
