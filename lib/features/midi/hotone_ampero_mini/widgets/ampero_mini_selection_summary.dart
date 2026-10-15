import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../data/ampero_mini_patch_layout.dart';

/// Shows the pre-selected patch and the last one sent as two clearly separate
/// blocks - never merged, since a single tap changing the first without sending
/// anything is the point of the pre-select/activate split.
///
/// Side by side, with the caveat on its own line underneath, and no card
/// around it: the page this heads puts twelve patch slots on the one screen
/// without scrolling, so every line of header comes out of the slots.
///
/// [sentNumber] is only ever what this app put on the wire. It is deliberately
/// not called "on device": this pedal has no confirmed way of reporting which
/// patch it has loaded, so a send is the strongest fact available and is
/// labelled as one. An earlier version of this card claimed the pedal had
/// confirmed the patch, reading its once-a-second counter as a patch report -
/// which meant the counter, not the user's own choice, drove the display.
class AmperoMiniSelectionSummary extends StatelessWidget {
  const AmperoMiniSelectionSummary({
    required this.preSelectedNumber,
    required this.sentNumber,
    super.key,
  });

  final int preSelectedNumber;
  final int? sentNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sent = sentNumber;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _Block(
                label: 'Pre-selected',
                value: _value(preSelectedNumber),
                theme: theme,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _Block(
                label: 'Last sent',
                value: sent == null ? 'Not sent yet' : _value(sent),
                theme: theme,
              ),
            ),
          ],
        ),
        if (sent != null)
          Text(
            'This pedal cannot confirm what it loaded',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
      ],
    );
  }

  /// The pedal's label and the raw index together: the first is what the
  /// hardware display shows, the second is what a MIDI capture shows.
  String _value(int number) =>
      '${amperoMiniPatchLabel(number)} · ${number.toString().padLeft(3, '0')}';
}

class _Block extends StatelessWidget {
  const _Block({required this.label, required this.value, required this.theme});

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
