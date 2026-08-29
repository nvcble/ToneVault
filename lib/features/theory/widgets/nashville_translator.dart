import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/music/scale.dart';
import '../data/nashville_reading.dart';
import '../providers/theory_providers.dart';

/// Type a chart and see it the other way round, in the key the browser is in.
///
/// The explaining above this is worth one read; this is worth using. A player with a
/// chart in numbers and no idea what to play, or a song they worked out by ear and want
/// to write down in a form that survives a change of key, has the same question in two
/// directions - so the switch turns the answer back into the question and reads it again.
class NashvilleTranslator extends ConsumerStatefulWidget {
  const NashvilleTranslator({super.key});

  @override
  ConsumerState<NashvilleTranslator> createState() =>
      _NashvilleTranslatorState();
}

class _NashvilleTranslatorState extends ConsumerState<NashvilleTranslator> {
  final TextEditingController _controller = TextEditingController(
    text: NashvilleDirection.numbersToChords.example,
  );

  NashvilleDirection _direction = NashvilleDirection.numbersToChords;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final key = ref.watch(theoryKeyProvider);
    final reading = readNashville(_controller.text, key, _direction);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<NashvilleDirection>(
          segments: [
            for (final direction in NashvilleDirection.values)
              ButtonSegment<NashvilleDirection>(
                value: direction,
                label: Text(direction.label),
              ),
          ],
          selected: {_direction},
          onSelectionChanged: (selection) => _turnRound(selection.first, key),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: _direction.prompt,
            hintText: _direction.example,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.md),
        _Answer(reading: reading),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Read in ${key.label}. The key is the one the theory browser is set to, so '
          'changing it there changes what these numbers mean.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Turning the switch reads the answer back the other way, so the two directions
  /// demonstrate each other instead of clearing the field and starting again.
  void _turnRound(NashvilleDirection direction, Scale key) {
    final reading = readNashville(_controller.text, key, _direction);
    setState(() {
      _direction = direction;
      if (reading != null && reading.isRead) {
        _controller.text = reading.answer!;
      }
    });
  }
}

/// The reading, or what was wrong with the line, or nothing where nothing was typed.
class _Answer extends StatelessWidget {
  const _Answer({required this.reading});

  final NashvilleReading? reading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final found = reading;

    if (found == null) {
      return Text(
        'Nothing typed yet.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    if (!found.isRead) {
      return Text(
        found.problem!,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
      );
    }

    return Text(found.answer!, style: theme.textTheme.headlineSmall);
  }
}
