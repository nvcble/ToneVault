import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

/// One control on the performance page: a button big enough to hit without
/// looking, filled while it is the setting in force and outlined otherwise.
///
/// Every button on that page is this one - scenes, tap tempo, the two
/// footswitches - so they stay the same size and say "on" the same way.
class MidiTriggerButton extends StatelessWidget {
  const MidiTriggerButton({
    required this.label,
    required this.onPressed,
    this.selected = false,
    super.key,
  });

  final String label;

  /// Null disables it - there is nothing to send to.
  final VoidCallback? onPressed;

  /// Whether this is the setting currently in force. Only ever what the app
  /// last sent, never a reading back from the device.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    const style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size.fromHeight(AppSpacing.minTouchTarget * 1.4),
      ),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      ),
    );
    final child = Text(
      label,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return selected
        ? FilledButton(style: style, onPressed: onPressed, child: child)
        : OutlinedButton(style: style, onPressed: onPressed, child: child);
  }
}

/// Lays [children] across a row, each taking an equal share of the width.
class MidiTriggerRow extends StatelessWidget {
  const MidiTriggerRow({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) const SizedBox(width: AppSpacing.md),
          Expanded(child: children[index]),
        ],
      ],
    );
  }
}
