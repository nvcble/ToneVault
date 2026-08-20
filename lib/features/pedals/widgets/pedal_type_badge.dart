import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/enums/pedal_type.dart';

/// Compact marker for a pedal's [PedalType].
///
/// Type decides how a pedal's settings are read - clock positions on analog
/// knobs, numbers on digital displays - so it earns a glance-level label
/// wherever pedals are listed.
class PedalTypeBadge extends StatelessWidget {
  const PedalTypeBadge(this.type, {super.key});

  final PedalType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final (Color background, Color foreground) = switch (type) {
      PedalType.analog => (colors.primaryContainer, colors.onPrimaryContainer),
      PedalType.digital => (
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
      ),
      PedalType.hybrid => (
        colors.secondaryContainer,
        colors.onSecondaryContainer,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs / 2,
        ),
        child: Text(
          type.label,
          style: theme.textTheme.labelSmall?.copyWith(color: foreground),
        ),
      ),
    );
  }
}
