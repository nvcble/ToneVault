import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/enums/lesson_kind.dart';
import '../../../core/music/fretboard_diagram.dart';
import '../../../core/values/lesson_media.dart';
import '../../../core/values/theory_keys.dart';
import '../../../shared/widgets/fretboard_view.dart';

/// A picture of the lesson, at the top of it.
///
/// Three things in order of how much they say, so no lesson opens on a wall of text:
/// the picture the curriculum named, the still of the video it named, or - for every
/// lesson the app ships, which names neither - a banner drawn from what the lesson
/// already knows about itself. That last one is the first shape it teaches on a neck,
/// and its kind's icon where it teaches no shape.
///
/// A network picture that will not load falls back to the same drawing. A lesson on a
/// phone with no signal is a lesson, and an error box where its picture should be
/// would be the app showing off its own plumbing.
class LessonHero extends StatelessWidget {
  const LessonHero({required this.lesson, this.onWatch, super.key});

  final AcademyLesson lesson;

  /// What tapping it does, where there is something to watch. The banner does not
  /// know what that is: opening a link is [LessonVideoButton]'s business, and the
  /// picture is the second way to reach the same video rather than a second route to
  /// it.
  final VoidCallback? onWatch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = lesson.imageUrl ?? youTubeThumbnailUrl(lesson.videoUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: AspectRatio(
        // The shape a video is, because half of these are a still of one.
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image == null)
              _Drawn(lesson: lesson)
            else
              Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, _, _) => _Drawn(lesson: lesson),
              ),
            // Dark at the foot of it, so the words below read against a photograph as
            // well as they do against a drawing.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.sm,
              bottom: AppSpacing.sm,
              child: Text(
                _caption,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            if (onWatch case final onWatch?) ...[
              Center(
                child: Icon(
                  Icons.play_circle_fill,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              // Above the badge rather than around it, so the whole banner is the
              // target: it is aimed at with a thumb, often with a guitar in the way.
              Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: onWatch),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// What the lesson asks of the player, over the picture of it. The same two facts
  /// the closed lesson row carries, so the page opens saying what was tapped.
  String get _caption => [
    lesson.kind.label.toUpperCase(),
    if (lesson.estimatedMinutes case final minutes?) '$minutes min',
  ].join('  ·  ');
}

/// The banner for a lesson with no picture of its own: its first shape on a neck, or
/// its kind, over the app's own colours.
class _Drawn extends StatelessWidget {
  const _Drawn({required this.lesson});

  final AcademyLesson lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diagram = diagramsForKeys(
      decodeTheoryKeys(lesson.theoryKeys),
    ).firstOrNull;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.surfaceContainerHighest,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: diagram == null
            ? Icon(
                lessonKindIcon(lesson.kind),
                size: 48,
                color: theme.colorScheme.onPrimaryContainer,
              )
            // Scaled to fit rather than laid out at the width it is given: a neck is
            // taller than a banner, and one drawn at full size would be cut in half.
            : FittedBox(
                child: SizedBox(
                  width: 320,
                  child: FretboardView(diagram: diagram, showTitle: false),
                ),
              ),
      ),
    );
  }
}

/// What each kind of lesson looks like in one glyph. Here rather than on [LessonKind],
/// which is plain Dart and knows nothing about Material.
IconData lessonKindIcon(LessonKind kind) => switch (kind) {
  LessonKind.concept => Icons.lightbulb_outline,
  LessonKind.technique => Icons.pan_tool_outlined,
  LessonKind.theory => Icons.account_tree_outlined,
  LessonKind.genre => Icons.library_music_outlined,
  LessonKind.earTraining => Icons.hearing,
  LessonKind.practice => Icons.timer_outlined,
};
