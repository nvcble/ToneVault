import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/values/clock_value.dart';
import '../../../shared/widgets/knob_dial.dart';
import '../data/control_value_range.dart';

/// Sets a knob by turning it.
///
/// Read back both ways a player names a position: the clock face the pointer
/// aims at, and how far along the sweep that is out of 100. Neither reading is
/// stored - only the normalized position underneath them is.
class KnobValueEditor extends StatelessWidget {
  const KnobValueEditor({
    required this.control,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final PedalControl control;
  final double value;

  /// Null while a save is in flight, which greys the pointer out rather than
  /// letting a second position be set on the way.
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final turned = normalizedValueFor(control, value);
    final handler = onChanged;

    return Column(
      children: [
        KnobDial(
          value: turned,
          divisions: sliderDivisionsFor(control),
          onChanged: handler == null
              ? null
              : (position) => handler(valueFromNormalized(control, position)),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          ClockValue.fromNormalized(turned).label,
          style: theme.textTheme.headlineSmall,
        ),
        Text(
          '${(turned * 100).round()} of 100',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
