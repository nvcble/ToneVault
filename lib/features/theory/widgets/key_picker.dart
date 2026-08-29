import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/music/pitch_class.dart';
import '../../../core/music/scale.dart';
import '../../../core/music/scale_type.dart';
import '../providers/theory_providers.dart';

/// The key everything below it is read in.
///
/// A root and a flavour, and only the two flavours a key comes in: the modes are on the
/// scales tab, where they belong. Twelve roots in a dropdown rather than twelve chips,
/// because this sits above the tabs on every one of them and a block of chips would push
/// the theory off the screen.
///
/// A plain dropdown rather than a form field, because the key is also set from the
/// circle of fifths: this shows what the key is, and a field that remembered its own
/// idea of it would stop agreeing with the wheel.
class KeyPicker extends ConsumerWidget {
  const KeyPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = ref.watch(theoryKeyProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text('Key', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(width: AppSpacing.md),
          DropdownButton<int>(
            value: key.root.semitone,
            items: [
              for (var semitone = 0; semitone < 12; semitone++)
                DropdownMenuItem<int>(
                  value: semitone,
                  child: Text(
                    PitchClass(semitone).name(flats: key.prefersFlats),
                  ),
                ),
            ],
            onChanged: (semitone) => _set(
              ref,
              Scale(PitchClass(semitone ?? key.root.semitone), key.type),
            ),
          ),
          const Spacer(),
          SegmentedButton<ScaleType>(
            segments: const [
              ButtonSegment<ScaleType>(
                value: ScaleType.major,
                label: Text('Major'),
              ),
              ButtonSegment<ScaleType>(
                value: ScaleType.minor,
                label: Text('Minor'),
              ),
            ],
            selected: {key.type},
            onSelectionChanged: (selection) =>
                _set(ref, Scale(key.root, selection.first)),
          ),
        ],
      ),
    );
  }

  void _set(WidgetRef ref, Scale key) =>
      ref.read(theoryKeyProvider.notifier).state = key;
}
