import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var scene = 1; scene <= 3; scene++) ...[
          if (scene > 1) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _SceneButton(
              scene: scene,
              selected: scene == selectedScene,
              onSelect: onSelect,
            ),
          ),
        ],
      ],
    );
  }
}

class _SceneButton extends StatelessWidget {
  const _SceneButton({
    required this.scene,
    required this.selected,
    required this.onSelect,
  });

  final int scene;
  final bool selected;
  final void Function(int sceneNumber)? onSelect;

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(
        Size.fromHeight(AppSpacing.minTouchTarget * 1.4),
      ),
    );
    final onPressed = onSelect == null ? null : () => onSelect!(scene);
    final label = Text('Scene $scene');

    return selected
        ? FilledButton(style: style, onPressed: onPressed, child: label)
        : OutlinedButton(style: style, onPressed: onPressed, child: label);
  }
}
