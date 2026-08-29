import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/metronome_providers.dart';
import '../widgets/meter_control.dart';
import '../widgets/tempo_control.dart';
import '../widgets/volume_control.dart';

/// The metronome.
///
/// It keeps counting when the screen is left, which is the point of it: a player sets a
/// tempo, goes back to the lesson they are working on, and plays along to it while they
/// read. The transport is the only thing that stops it.
class MetronomeScreen extends ConsumerStatefulWidget {
  const MetronomeScreen({super.key});

  @override
  ConsumerState<MetronomeScreen> createState() => _MetronomeScreenState();
}

class _MetronomeScreenState extends ConsumerState<MetronomeScreen> {
  /// The tempo under the finger while the slider is moving.
  ///
  /// Kept here rather than in the metronome, because a bar of clicks is rendered every
  /// time the tempo is set and a slider being dragged across the range would render two
  /// hundred and seventy of them. The number follows the finger; the count follows the
  /// finger being lifted.
  int? _dragging;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(metronomeSettingsProvider);
    final controller = ref.read(metronomeSettingsProvider.notifier);
    final settings = state.settings;

    ref.listen(metronomeSettingsProvider, (previous, next) {
      final failure = next.failure;
      if (failure != null && failure != previous?.failure) {
        showFailureSnackBar(context, failure);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Metronome')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          TempoControl(
            bpm: _dragging ?? settings.bpm,
            onDragged: (bpm) => setState(() => _dragging = bpm),
            onSet: (bpm) {
              setState(() => _dragging = null);
              controller.setBpm(bpm);
            },
            onNudge: controller.nudge,
            onTap: controller.tap,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            onPressed: controller.toggle,
            icon: Icon(state.playing ? Icons.pause : Icons.play_arrow),
            label: Text(state.playing ? 'Stop' : 'Start'),
          ),
          const SizedBox(height: AppSpacing.lg),
          MeterControl(
            signature: settings.signature,
            accentFirst: settings.accentFirst,
            onSignature: controller.setSignature,
            onAccent: controller.setAccent,
          ),
          const SizedBox(height: AppSpacing.md),
          VolumeControl(
            volume: settings.volume,
            onChanged: controller.setVolume,
          ),
        ],
      ),
    );
  }
}
