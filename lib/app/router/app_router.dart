import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/academy/routes/academy_routes.dart';
import '../../features/academy/screens/practice_metronome_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/pedals/routes/pedal_routes.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../shared/widgets/app_scaffold.dart';
import 'routes.dart';

final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter();
  ref.onDispose(router.dispose);
  return router;
});

/// Builds the four-tab shell, and the Academy alongside it.
///
/// [StatefulShellRoute.indexedStack] gives every tab its own navigation stack,
/// so moving between tabs keeps each one's scroll position and detail screens,
/// and Android's back button unwinds the active tab rather than the app.
///
/// The Academy is a route beside the shell rather than a branch inside it. A
/// branch would need a destination in the navigation bar to select, and a
/// selected index past the end of the destinations is an error; and it is not a
/// place to keep coming back to a tab of, but somewhere to go and then leave.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: Routes.dashboard,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(routes: pedalRoutes()),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      ...academyRoutes(),
      // Through the Academy's wrapper rather than straight to the metronome, so the
      // time it counts is credited to the lesson that opened it - and so the time it
      // counted for nobody is cleared instead of landing on the next lesson.
      GoRoute(
        path: Routes.metronome,
        builder: (context, state) => PracticeMetronomeScreen(
          lessonId: int.tryParse(
            state.uri.queryParameters[Routes.lessonQuery] ?? '',
          ),
        ),
      ),
    ],
  );
}
