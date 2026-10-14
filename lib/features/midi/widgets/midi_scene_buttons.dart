import 'package:flutter/material.dart';

import 'midi_trigger_controls.dart';

/// Three large buttons for the MG-30's Pro Scene mode.
///
/// Scene 1/2/3 rather than a raw CC value: the value each one sends is an
/// implementation detail of `MidiParameterSender`, resolved from the
/// "Scene" parameter the same way every other named parameter is.
class MidiSceneButtons extends StatelessWidget {
  const MidiSceneButtons({
    required this.onSelect,
    this.selectedScene,
    super.key,
  });

  /// Null disables every button - there is nothing to send to, or nothing
  /// the user has allowed sending yet.
  final void Function(int sceneNumber)? onSelect;

  /// The scene last sent this session, filled in primary while the other two
  /// stay outlined - not a reading from the device, only what this app last
  /// sent. Null shows all three the same way, before anything has been sent.
  final int? selectedScene;

  static const int sceneCount = 3;

  @override
  Widget build(BuildContext context) {
    return MidiTriggerRow(
      children: [
        for (var scene = 1; scene <= sceneCount; scene++)
          MidiTriggerButton(
            label: 'Scene $scene',
            selected: scene == selectedScene,
            onPressed: onSelect == null ? null : () => onSelect!(scene),
          ),
      ],
    );
  }
}
