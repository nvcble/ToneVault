import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/enums/learning_path.dart';
import '../../../core/enums/skill_level.dart';
import '../../theory/data/theory_tab.dart';
import '../../theory/screens/nashville_screen.dart';
import '../../theory/screens/theory_screen.dart';
import '../data/ear_drill.dart';
import '../screens/academy_screen.dart';
import '../screens/bookmarks_screen.dart';
import '../screens/course_screen.dart';
import '../screens/curriculum_screen.dart';
import '../screens/ear_drill_screen.dart';
import '../screens/ear_training_screen.dart';
import '../screens/learning_path_screen.dart';
import '../screens/lesson_search_screen.dart';
import '../screens/level_screen.dart';

/// The `/academy` section of the app.
///
/// Declared outside the tab shell, so it covers the navigation bar rather than
/// selecting a destination that is not there, and comes with a back arrow to the
/// tab the user left.
List<RouteBase> academyRoutes() {
  return [
    GoRoute(
      path: Routes.academy,
      builder: (context, state) => const AcademyScreen(),
      routes: [
        // Before the path segment, which would otherwise take `ear`, `theory`,
        // `bookmarks` or `search` for the name of a learning path and land on rhythm.
        GoRoute(
          path: Routes.academyTheorySegment,
          builder: (context, state) =>
              TheoryScreen(tab: _tab(state) ?? TheoryTab.chords),
          routes: [
            GoRoute(
              path: Routes.academyNashvilleSegment,
              builder: (context, state) => const NashvilleScreen(),
            ),
          ],
        ),
        GoRoute(
          path: Routes.academyBookmarksSegment,
          builder: (context, state) => const BookmarksScreen(),
        ),
        GoRoute(
          path: Routes.academySearchSegment,
          builder: (context, state) => const LessonSearchScreen(),
        ),
        GoRoute(
          path: Routes.academyCurriculumSegment,
          builder: (context, state) => const CurriculumScreen(),
        ),
        GoRoute(
          path: Routes.academyEarSegment,
          builder: (context, state) => const EarTrainingScreen(),
          routes: [
            GoRoute(
              path: Routes.academyEarDrillSegment,
              builder: (context, state) =>
                  EarDrillScreen(drill: _drill(state) ?? EarDrill.majorOrMinor),
            ),
          ],
        ),
        GoRoute(
          path: Routes.academyPathSegment,
          builder: (context, state) =>
              LearningPathScreen(path: _path(state) ?? LearningPath.rhythm),
          routes: [
            GoRoute(
              path: Routes.academyLevelSegment,
              builder: (context, state) => LevelScreen(
                path: _path(state) ?? LearningPath.rhythm,
                level: _level(state) ?? SkillLevel.beginner,
              ),
              routes: [
                GoRoute(
                  path: Routes.academyCourseSegment,
                  builder: (context, state) => CourseScreen(
                    courseId: _courseId(state),
                    openLessonId: _lessonId(state),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ];
}

/// A path named in the URL, or null where the name is not one of the two.
///
/// A typed or stale link is the only way to get here with something else, and
/// falling back to the first path shows a real screen instead of an error about a
/// string the user never typed.
LearningPath? _path(GoRouterState state) => LearningPath.values
    .where((path) => path.name == state.pathParameters['path'])
    .firstOrNull;

/// The tab a link asked the theory browser to open on, or null where it asked for
/// nothing or for something that is not a tab.
TheoryTab? _tab(GoRouterState state) => TheoryTab.values
    .where(
      (tab) => tab.name == state.uri.queryParameters[Routes.theoryTabQuery],
    )
    .firstOrNull;

EarDrill? _drill(GoRouterState state) => EarDrill.values
    .where((drill) => drill.name == state.pathParameters['drill'])
    .firstOrNull;

SkillLevel? _level(GoRouterState state) => SkillLevel.values
    .where((level) => level.name == state.pathParameters['level'])
    .firstOrNull;

/// No row can have id -1, so a malformed link lands on the ordinary "nothing in
/// this course" state instead of throwing.
int _courseId(GoRouterState state) =>
    int.tryParse(state.pathParameters['courseId'] ?? '') ?? -1;

/// The lesson to arrive with open, where the link named one. Null is the ordinary
/// case: a course opened from a level, with every lesson closed.
int? _lessonId(GoRouterState state) =>
    int.tryParse(state.uri.queryParameters[Routes.lessonQuery] ?? '');
