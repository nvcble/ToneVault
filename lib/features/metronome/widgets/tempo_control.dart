import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/values/tempo_range.dart';

/// The tempo: read big, set three ways.
///
/// Three ways because a player arrives at a tempo differently depending on why: the
/// slider to sweep, the buttons to nudge a beat at a time, and tapping it in when the
/// number is not the point and the feel is.
///
/// The slider reports while it is being dragged and again when it is let go. Only the
/// second one is worth acting on where acting means rendering a bar of clicks, so the
/// caller is told which is which.
class TempoControl extends StatelessWidget {
  const TempoControl({
    required this.bpm,
    required this.onDragged,
    required this.onSet,
    required this.onNudge,
    required this.onTap,
    super.key,
  });

  final int bpm;

  /// While the slider is moving: the number changes and nothing is rendered.
  final ValueChanged<int> onDragged;

  /// Where the slider was let go, or a nudge - a tempo to count at.
  final ValueChanged<int> onSet;
  final ValueChanged<int> onNudge;

  /// A tap of the tempo, timed against the ones before it.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Nudge(by: -1, onNudge: onNudge),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                children: [
                  Text('$bpm', style: theme.textTheme.displayMedium),
                  Text('BPM', style: theme.textTheme.labelMedium),
                ],
              ),
            ),
            _Nudge(by: 1, onNudge: onNudge),
          ],
        ),
        Slider(
          value: bpm.toDouble(),
          min: minBpm.toDouble(),
          max: maxBpm.toDouble(),
          // One stop a beat, so the slider can land on the tempo a chart asks for.
          divisions: maxBpm - minBpm,
          label: '$bpm',
          onChanged: (value) => onDragged(value.round()),
          onChangeEnd: (value) => onSet(value.round()),
        ),
        OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.touch_app_outlined),
          label: const Text('Tap tempo'),
        ),
      ],
    );
  }
}

class _Nudge extends StatelessWidget {
  const _Nudge({required this.by, required this.onNudge});

  final int by;
  final ValueChanged<int> onNudge;

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      icon: Icon(by < 0 ? Icons.remove : Icons.add),
      tooltip: by < 0 ? 'A beat slower' : 'A beat faster',
      onPressed: () => onNudge(by),
    );
  }
}
