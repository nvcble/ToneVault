import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/enums/bookmark_target.dart';
import '../../../core/music/scale_type.dart';
import '../../../shared/widgets/fretboard_view.dart';
import '../../academy/widgets/bookmark_button.dart';
import '../providers/theory_providers.dart';
import 'scale_facts_card.dart';

/// Every scale and mode the engine knows, on the key's root and on the neck.
///
/// One root and seventeen formulas rather than a list of scales: the modes are the major
/// scale started somewhere else, and seeing them all on the same root is what makes that
/// obvious. The degrees are what the neck is marked with by default, because a shape
/// learned as numbers moves to any key and a shape learned as letters does not.
class ScaleExplorer extends ConsumerStatefulWidget {
  const ScaleExplorer({super.key});

  @override
  ConsumerState<ScaleExplorer> createState() => _ScaleExplorerState();
}

class _ScaleExplorerState extends ConsumerState<ScaleExplorer> {
  FretMarking _marking = FretMarking.degree;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = ref.watch(theoryScaleTypeProvider);
    final scale = ref.watch(theoryScaleProvider);
    final notes = ref.watch(theoryScaleNotesProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final type in ScaleType.values)
              ChoiceChip(
                label: Text(type.label),
                selected: type == selected,
                onSelected: (_) =>
                    ref.read(theoryScaleTypeProvider.notifier).state = type,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: Text(scale.label, style: theme.textTheme.titleMedium),
            ),
            // Its own name is all the engine needs to draw it again, so a kept scale
            // costs one string and no lookup. Kept as a mode where it is one, so a
            // player working through the modes of a key gets a list they can read.
            BookmarkButton(
              target: scale.type.isMode
                  ? BookmarkTarget.mode
                  : BookmarkTarget.scale,
              targetKey: scale.label,
              label: scale.label,
            ),
          ],
        ),
        Wrap(
          spacing: AppSpacing.md,
          children: [
            for (final note in notes)
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: note.note,
                      style: theme.textTheme.titleSmall,
                    ),
                    TextSpan(
                      text: ' ${note.degree}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        FretboardView(
          diagram: ref.watch(theoryScaleDiagramProvider),
          marking: _marking,
          showTitle: false,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => setState(
              () => _marking = _marking == FretMarking.degree
                  ? FretMarking.note
                  : FretMarking.degree,
            ),
            child: Text(
              _marking == FretMarking.degree ? 'Note names' : 'Degrees',
            ),
          ),
        ),
        // Below the neck rather than above it: a player picks a scale, looks at the
        // shape, and then wants to know what it is and what to do with it.
        const ScaleFactsCard(),
      ],
    );
  }
}
