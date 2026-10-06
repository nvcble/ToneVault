import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../providers/academy_providers.dart';
import '../widgets/lesson_view.dart';

/// One lesson, on a page of its own.
///
/// A course is forty lessons in six modules, and reading one of them inside the list
/// of the other thirty-nine meant scrolling a page of text to get back to where the
/// next one was. A lesson is now what a tap opens and a back arrow closes: the list
/// stays a list, and the lesson gets the whole screen it is written for.
///
/// Arriving is what records that the lesson was started, so a player never has to
/// tell the app what it can already see. Finishing it stays a deliberate tap, because
/// only they know whether they have.
class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({required this.lessonId, super.key});

  final int lessonId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = ref.watch(lessonProvider(widget.lessonId)).valueOrNull;
    final progress = ref
        .watch(lessonProgressProvider(widget.lessonId))
        .valueOrNull;

    return Scaffold(
      // The title waits for the row rather than showing the id. A lesson reached from
      // a bookmark or a link that no longer resolves keeps the generic word, and its
      // body says the rest.
      appBar: AppBar(title: Text(lesson?.title ?? 'Lesson')),
      body: lesson == null
          ? const EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'This lesson is not here',
              message:
                  'It may have been replaced by an import. Open the course to '
                  'see what it teaches now.',
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [LessonView(lesson: lesson, progress: progress)],
            ),
    );
  }

  /// Recorded once, on arrival. A rebuild is not a second reading, and the write is
  /// idempotent anyway - it is the lesson being in progress, not a count of visits.
  ///
  /// Waited for the row first: a bookmark or a link that outlived its lesson has
  /// nothing to record progress against, and the screen already says so.
  Future<void> _open() async {
    try {
      final lesson = await ref.read(lessonProvider(widget.lessonId).future);
      if (lesson == null) {
        return;
      }
      await ref.read(progressRepositoryProvider).markOpened(widget.lessonId);
    } catch (error) {
      if (mounted) {
        showFailureSnackBar(context, error);
      }
    }
  }
}
