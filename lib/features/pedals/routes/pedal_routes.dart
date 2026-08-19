import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../configurations/screens/configuration_form_screen.dart';
import '../../configurations/screens/configuration_screen.dart';
import '../../controls/screens/control_form_screen.dart';
import '../screens/pedal_detail_screen.dart';
import '../screens/pedal_form_screen.dart';
import '../screens/pedals_screen.dart';

/// The `/pedals` section of the app.
///
/// The feature owns its own routes, so the router file stays a list of
/// branches. Nesting them under the list keeps the navigation bar in place and
/// gives the detail and form screens a real back stack.
List<RouteBase> pedalRoutes() {
  return [
    GoRoute(
      path: Routes.pedals,
      builder: (context, state) => const PedalsScreen(),
      routes: [
        // Declared ahead of ':pedalId' so '/pedals/new' is not matched as a
        // pedal id.
        GoRoute(
          path: Routes.pedalNewSegment,
          builder: (context, state) => const PedalFormScreen(),
        ),
        GoRoute(
          path: Routes.pedalDetailSegment,
          builder: (context, state) =>
              PedalDetailScreen(pedalId: _pedalId(state)),
          routes: [
            GoRoute(
              path: Routes.pedalEditSegment,
              builder: (context, state) =>
                  PedalFormScreen(pedalId: _pedalId(state)),
            ),
            GoRoute(
              path: Routes.controlNewSegment,
              builder: (context, state) =>
                  ControlFormScreen(pedalId: _pedalId(state)),
            ),
            GoRoute(
              path: Routes.controlEditSegment,
              builder: (context, state) => ControlFormScreen(
                pedalId: _pedalId(state),
                controlId: _controlId(state),
              ),
            ),
            // Declared ahead of ':configurationId' so
            // '/configurations/new' is not matched as a configuration id.
            GoRoute(
              path: Routes.configurationNewSegment,
              builder: (context, state) =>
                  ConfigurationFormScreen(pedalId: _pedalId(state)),
            ),
            GoRoute(
              path: Routes.configurationDetailSegment,
              builder: (context, state) => ConfigurationScreen(
                pedalId: _pedalId(state),
                configurationId: _configurationId(state),
              ),
              routes: [
                GoRoute(
                  path: Routes.configurationEditSegment,
                  builder: (context, state) => ConfigurationFormScreen(
                    pedalId: _pedalId(state),
                    configurationId: _configurationId(state),
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
int _pedalId(GoRouterState state) =>
    int.tryParse(state.pathParameters['pedalId'] ?? '') ?? -1;

int _controlId(GoRouterState state) =>
    int.tryParse(state.pathParameters['controlId'] ?? '') ?? -1;

int _configurationId(GoRouterState state) =>
    int.tryParse(state.pathParameters['configurationId'] ?? '') ?? -1;
