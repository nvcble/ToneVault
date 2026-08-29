import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/enums/time_signature.dart';

/// The meter: which signature, whether the first beat is accented, and the bar drawn
/// out as the clicks it will play.
///
/// The row of dots is what a player checks the setting against. Twelve of them with the
/// first one filled says 12/8 accented more plainly than the numbers do, and it makes
/// the difference between the compound signatures visible - 6/8 is six clicks here,
/// counted as written.
class MeterControl extends StatelessWidget {
  const MeterControl({
    required this.signature,
    required this.accentFirst,
    required this.onSignature,
    required this.onAccent,
    super.key,
  });

  final TimeSignature signature;
  final bool accentFirst;
  final ValueChanged<TimeSignature> onSignature;
  final ValueChanged<bool> onAccent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final each in TimeSignature.values)
              ChoiceChip(
                label: Text(each.label),
                selected: each == signature,
                onSelected: (_) => onSignature(each),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _Bar(signature: signature, accentFirst: accentFirst),
        SwitchListTile(
          title: const Text('Accent the first beat'),
          subtitle: const Text(
            'Off for a flat pulse, with the bar left to you.',
          ),
          value: accentFirst,
          onChanged: onAccent,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

/// The bar as its clicks, the accented one larger and filled.
class _Bar extends StatelessWidget {
  const _Bar({required this.signature, required this.accentFirst});

  final TimeSignature signature;
  final bool accentFirst;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (var beat = 0; beat < signature.beats; beat++)
          _Dot(
            accented: accentFirst && beat == 0,
            colour: accentFirst && beat == 0
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.accented, required this.colour});

  final bool accented;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    final size = accented ? 18.0 : 12.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accented ? colour : null,
        border: Border.all(color: colour, width: 2),
      ),
    );
  }
}
