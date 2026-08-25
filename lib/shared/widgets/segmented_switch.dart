import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

/// Two lists behind one screen, with a switch above them.
///
/// The caller keeps [showingSecond], because which half is open is that screen's
/// state and not this widget's.
class SegmentedSwitch extends StatelessWidget {
  const SegmentedSwitch({
    required this.firstLabel,
    required this.secondLabel,
    required this.showingSecond,
    required this.onChanged,
    required this.child,
    super.key,
  });

  final String firstLabel;
  final String secondLabel;
  final bool showingSecond;
  final ValueChanged<bool> onChanged;

  /// Whichever half [showingSecond] says.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SegmentedButton<bool>(
            segments: [
              ButtonSegment<bool>(value: false, label: Text(firstLabel)),
              ButtonSegment<bool>(value: true, label: Text(secondLabel)),
            ],
            selected: {showingSecond},
            onSelectionChanged: (selection) => onChanged(selection.first),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
