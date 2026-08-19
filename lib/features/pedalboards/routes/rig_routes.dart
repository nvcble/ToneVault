import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../snapshots/screens/capture_snapshot_screen.dart';
import '../../snapshots/screens/snapshot_edit_screen.dart';
import '../../snapshots/screens/snapshot_screen.dart';
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
            GoRoute(
              path: Routes.snapshotNewSegment,
              builder: (context, state) =>
                  CaptureSnapshotScreen(pedalboardId: _pedalboardId(state)),
            ),
            // Declared after 'snapshots/new' so that path is not matched as a
            // snapshot id.
            GoRoute(
              path: Routes.snapshotDetailSegment,
              builder: (context, state) => SnapshotScreen(
                pedalboardId: _pedalboardId(state),
                snapshotId: _snapshotId(state),
              ),
              routes: [
                GoRoute(
                  path: Routes.snapshotEditSegment,
                  builder: (context, state) => SnapshotEditScreen(
                    pedalboardId: _pedalboardId(state),
                    snapshotId: _snapshotId(state),
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

/// No row can have id -1, so a malformed link lands on the ordinary "no longer
/// exists" state instead of throwing.
int _pedalboardId(GoRouterState state) =>
    int.tryParse(state.pathParameters['rigId'] ?? '') ?? -1;

int _snapshotId(GoRouterState state) =>
    int.tryParse(state.pathParameters['snapshotId'] ?? '') ?? -1;
