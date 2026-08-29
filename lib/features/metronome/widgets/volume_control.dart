import 'package:flutter/material.dart';

/// How loud the click is, against the guitar it is being played over.
///
/// Its own control rather than the device's, because a metronome is nearly always too
/// loud or too quiet next to whatever else is making a noise, and turning the whole
/// device down turns the chord being checked against down with it.
class VolumeControl extends StatelessWidget {
  const VolumeControl({
    required this.volume,
    required this.onChanged,
    super.key,
  });

  final double volume;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(volume == 0 ? Icons.volume_off : Icons.volume_up_outlined),
        Expanded(
          child: Slider(
            value: volume,
            label: '${(volume * 100).round()}%',
            divisions: 20,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
