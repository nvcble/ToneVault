import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/daos/academy_course_dao.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/failure_snack_bar.dart';
import '../../theory/data/theory_search.dart';
import '../providers/academy_providers.dart';
import '../widgets/search_results.dart';

/// Searching the Academy: the lessons and the theory, from one field.
///
/// The whole curriculum at once, across both paths and all four levels: a player who
/// remembers a lesson about barre chords does not remember which level filed it, and a
/// search that made them choose first would be a worse table of contents than the one
/// they already have. The theory browser is searched alongside it for the same reason -
/// `dorian` is a scale, a mode, a tab and a lesson, and which of those the app calls it
/// is not the player's problem.
class LessonSearchScreen extends ConsumerStatefulWidget {
  const LessonSearchScreen({super.key});

  @override
  ConsumerState<LessonSearchScreen> createState() => _LessonSearchScreenState();
}

class _LessonSearchScreenState extends ConsumerState<LessonSearchScreen> {
  final TextEditingController _typed = TextEditingController();

  @override
  void initState() {
    super.initState();
    // The query outlives this screen, so coming back to a search shows it again rather
    // than an empty field over the results it produced.
    _typed.text = ref.read(lessonSearchQueryProvider);
  }

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessons = ref.watch(lessonSearchProvider);
    final theory = ref.watch(theorySearchProvider);
    final query = ref.watch(lessonSearchQueryProvider).trim();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _typed,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search lessons, chords and scales',
            border: InputBorder.none,
          ),
          onChanged: (text) =>
              ref.read(lessonSearchQueryProvider.notifier).state = text,
        ),
      ),
      body: _body(query, theory, lessons),
    );
  }

  Widget _body(
    String query,
    List<TheoryFound> theory,
    AsyncValue<List<LessonPlace>> lessons,
  ) {
    // A short query is not a search yet, so it is asked for rather than answered with
    // everything the curriculum has.
    if (query.length < 2) {
      return const EmptyState(
        icon: Icons.search,
        title: 'What are you looking for?',
        message:
            'Type a couple of letters: a lesson, a chord, a scale or a '
            'course.',
      );
    }

    final found = lessons.valueOrNull ?? const <LessonPlace>[];
    if (theory.isNotEmpty || found.isNotEmpty) {
      return SearchResults(
        theory: theory,
        lessons: found,
        failure: lessons.error,
      );
    }

    return switch (lessons) {
      AsyncValue<List<LessonPlace>>(:final error?) => EmptyState(
        icon: Icons.error_outline,
        title: 'Could not search the lessons',
        message: failureMessage(error),
      ),
      AsyncValue<List<LessonPlace>>(hasValue: true) => EmptyState(
        icon: Icons.search_off,
        title: 'Nothing matches',
        message: 'Nothing in the lessons or the theory mentions "$query".',
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}
