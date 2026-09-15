import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

/// Three large buttons for the MG-30's Pro Scene mode.
///
/// Scene 1/2/3 rather than a raw CC value: the value each one sends is an
/// implementation detail of `MidiParameterSender`, resolved from the
/// "Scene" parameter the same way every other named parameter is.
class MidiSceneButtons extends StatelessWidget {
  const MidiSceneButtons({required this.onSelect, super.key});

  /// Null disables every button - there is nothing to send to, or nothing
  /// the user has allowed sending yet.
  final void Function(int sceneNumber)? onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var scene = 1; scene <= 3; scene++) ...[
          if (scene > 1) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget * 1.4),
              ),
              onPressed: onSelect == null ? null : () => onSelect!(scene),
              child: Text('Scene $scene'),
            ),
          ),
        ],
      ],
    );
  }
}
