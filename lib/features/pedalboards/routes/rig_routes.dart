import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../screens/rig_form_screen.dart';
import '../screens/rig_screen.dart';
import '../screens/rigs_screen.dart';

/// The `/rigs` section of the app.
///
/// The feature owns its own routes, so the router file stays a list of
/// branches. Nesting them under the list keeps the navigation bar in place and
/// gives the rig and form screens a real back stack.
List<RouteBase> rigRoutes() {
  return [
    GoRoute(
      path: Routes.rigs,
      builder: (context, state) => const RigsScreen(),
      routes: [
        // Declared ahead of ':rigId' so '/rigs/new' is not matched as a rig id.
        GoRoute(
          path: Routes.rigNewSegment,
          builder: (context, state) => const RigFormScreen(),
        ),
        GoRoute(
          path: Routes.rigDetailSegment,
          builder: (context, state) =>
              RigScreen(pedalboardId: _pedalboardId(state)),
          routes: [
            GoRoute(
              path: Routes.rigEditSegment,
              builder: (context, state) =>
                  RigFormScreen(pedalboardId: _pedalboardId(state)),
            ),
          ],
        ),
      ],
    ),
  ];
}

/// No row can have id -1, so a malformed link lands on the ordinary "no longer
/// exists" state instead of throwing.
int _pedalboardId(GoRouterState state) =>
    int.tryParse(state.pathParameters['rigId'] ?? '') ?? -1;
