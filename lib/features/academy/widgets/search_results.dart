import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/database/daos/academy_course_dao.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../../shared/widgets/section_label.dart';
import '../../theory/data/theory_search.dart';
import 'theory_result_tile.dart';

/// What one typed word turned up: the theory first, then the lessons.
///
/// The theory is above because it is the exact answer - somebody typing `Am7` is asking
/// for that chord, and the lessons that mention it are the reading around it. It also
/// arrives first: the engine works it out on the keystroke while the curriculum is still
/// being queried, so the list does not sit empty waiting for the slower half.
class SearchResults extends StatelessWidget {
  const SearchResults({
    required this.theory,
    required this.lessons,
    this.failure,
    super.key,
  });

  final List<TheoryFound> theory;
  final List<LessonPlace> lessons;

  /// Why the lesson half is missing, where it is. Said in the list rather than instead of
  /// it, because theory results are still worth showing when the database is not.
  final Object? failure;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (theory.isNotEmpty) const SectionLabel('Theory'),
        for (final found in theory) TheoryResultTile(found: found),
        if (failure case final failure?)
          ListTile(
            leading: const Icon(Icons.error_outline),
            title: const Text('Could not search the lessons'),
            subtitle: Text(failureMessage(failure)),
          ),
        if (lessons.isNotEmpty) const SectionLabel('Lessons'),
        for (final place in lessons) _LessonResultTile(place: place),
      ],
    );
  }
}

class _LessonResultTile extends StatelessWidget {
  const _LessonResultTile({required this.place});

  final LessonPlace place;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(place.lesson.title),
      // Where it lives, because that is what the tap is about to open.
      subtitle: Text(
        '${place.course.title} - ${place.course.level.label} '
        '${place.course.path.label}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push<void>(
        Routes.academyCourse(
          place.course.path,
          place.course.level,
          place.course.id,
        ),
      ),
    );
  }
}
