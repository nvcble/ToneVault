import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import 'midi_footswitch_buttons.dart';
import 'midi_scene_buttons.dart';
import 'tap_tempo_button.dart';

/// Everything that acts on whichever patch is loaded, in one column beside the
/// patch grid: find a patch, pick a scene, set the tempo, work the two
/// footswitches.
///
/// Callbacks in and nothing else - no provider, no device profile - so it lays
/// out the same whatever is on the other end of the cable, and a test can drive
/// it without one.
class MidiPerformanceRail extends StatelessWidget {
  const MidiPerformanceRail({
    required this.onSelectPatch,
    required this.selectedScene,
    required this.onSelectScene,
    required this.onTapTempo,
    required this.onToggleSwitch,
    this.onTappedBpm,
    this.switchesOn = const {},
    super.key,
  });

  final VoidCallback onSelectPatch;
  final int? selectedScene;

  /// Null on each of these three disables that group - the device is not
  /// connected, so there is nothing to send to.
  final void Function(int sceneNumber)? onSelectScene;
  final VoidCallback? onTapTempo;
  final void Function(String parameterName, bool on)? onToggleSwitch;

  /// The tempo the tapping implies, for whoever wants the reading as well as
  /// the taps - the MIDI Clock stream, when the user has turned it on. Null
  /// unless something is listening; see [TapTempoButton.onBpm].
  final void Function(int bpm)? onTappedBpm;

  final Set<String> switchesOn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      // Spread down whatever height the rail is given - see `FillOrScroll`.
      // On a page this gets a column of its own, the room goes into the gaps
      // between the groups rather than sitting unused at the bottom.
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget * 1.4),
          ),
          icon: const Icon(Icons.search),
          label: const Text('Select Patch'),
          onPressed: onSelectPatch,
        ),
        _RailSection(
          title: 'Scenes',
          child: MidiSceneButtons(
            selectedScene: selectedScene,
            onSelect: onSelectScene,
          ),
        ),
        _RailSection(
          title: 'Tempo',
          child: TapTempoButton(onTap: onTapTempo, onBpm: onTappedBpm),
        ),
        _RailSection(
          title: 'Footswitches',
          child: MidiFootswitchButtons(
            on: switchesOn,
            onToggle: onToggleSwitch,
          ),
        ),
      ],
    );
  }
}

/// A heading and its controls. Flush with the buttons rather than using
/// `SectionLabel`, whose own indent is meant for full-width settings rows.
class _RailSection extends StatelessWidget {
  const _RailSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}
