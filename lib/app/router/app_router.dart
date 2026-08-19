import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/pedalboards/screens/rigs_screen.dart';
import '../../features/pedals/routes/pedal_routes.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../shared/widgets/app_scaffold.dart';
import 'routes.dart';

final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter();
  ref.onDispose(router.dispose);
  return router;
});

/// Builds the five-tab shell.
///
/// [StatefulShellRoute.indexedStack] gives every tab its own navigation stack,
/// so moving between tabs keeps each one's scroll position and detail screens,
/// and Android's back button unwinds the active tab rather than the app.
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
                path: Routes.rigs,
                builder: (context, state) => const RigsScreen(),
              ),
            ],
          ),
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
    ],
  );
}
