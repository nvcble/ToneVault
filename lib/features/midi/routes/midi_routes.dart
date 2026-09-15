import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../screens/captured_preset_import_screen.dart';
import '../screens/live_control_screen.dart';
import '../screens/midi_capture_log_screen.dart';
import '../screens/midi_connection_screen.dart';
import '../screens/midi_control_screen.dart';
import '../screens/midi_diagnostics_screen.dart';
import '../screens/midi_mapping_screen.dart';
import '../screens/midi_monitor_screen.dart';
import '../screens/midi_parameter_list_screen.dart';
import '../screens/midi_patch_browser_screen.dart';
import '../screens/midi_patch_editor_screen.dart';
import '../screens/midi_patch_scenes_screen.dart';
import '../screens/midi_patches_screen.dart';
import '../screens/midi_screen.dart';
import '../screens/preset_import_screen.dart';

/// The `/midi` section of the app.
///
/// Declared outside the tab shell, like the Academy: it covers the
/// navigation bar rather than selecting a destination that is not there, and
/// comes with a back arrow to the tab the user left.
List<RouteBase> midiRoutes() {
  return [
    GoRoute(
      path: Routes.midi,
      builder: (context, state) => const MidiScreen(),
      routes: [
        GoRoute(
          path: Routes.midiConnectSegment,
          builder: (context, state) =>
              MidiConnectionScreen(profileId: _deviceId(state)),
        ),
        GoRoute(
          path: Routes.midiControlSegment,
          builder: (context, state) =>
              MidiControlScreen(profileId: _deviceId(state)),
        ),
        GoRoute(
          path: Routes.midiParametersSegment,
          builder: (context, state) =>
              MidiParameterListScreen(profileId: _deviceId(state)),
        ),
        GoRoute(
          path: Routes.midiMappingSegment,
          builder: (context, state) =>
              MidiMappingScreen(profileId: _deviceId(state)),
        ),
        GoRoute(
          path: Routes.midiMonitorSegment,
          builder: (context, state) => const MidiMonitorScreen(),
        ),
        GoRoute(
          path: Routes.midiDiagnosticsSegment,
          builder: (context, state) => MidiDiagnosticsScreen(profileId: _deviceId(state)),
        ),
        GoRoute(
          path: Routes.midiCaptureLogSegment,
          builder: (context, state) => const MidiCaptureLogScreen(),
        ),
        GoRoute(
          path: Routes.liveControlSegment,
          builder: (context, state) => LiveControlScreen(profileId: _deviceId(state)),
        ),
        GoRoute(
          path: Routes.midiPatchBrowserSegment,
          builder: (context, state) => MidiPatchBrowserScreen(profileId: _deviceId(state)),
        ),
        GoRoute(
          path: Routes.midiPatchesSegment,
          builder: (context, state) =>
              MidiPatchesScreen(profileId: _deviceId(state)),
        ),
        GoRoute(
          path: Routes.midiPresetImportSegment,
          builder: (context, state) => PresetImportScreen(profileId: _deviceId(state)),
        ),
        GoRoute(
          path: Routes.midiCapturedPresetImportSegment,
          builder: (context, state) => CapturedPresetImportScreen(profileId: _deviceId(state)),
        ),
        GoRoute(
          path: Routes.midiPatchScenesSegment,
          builder: (context, state) => MidiPatchScenesScreen(
            profileId: _deviceId(state),
            patchId: _patchId(state),
          ),
        ),
        GoRoute(
          path: Routes.midiSceneEditorSegment,
          builder: (context, state) => MidiPatchEditorScreen(
            profileId: _deviceId(state),
            patchId: _patchId(state),
            sceneId: _sceneId(state),
          ),
        ),
      ],
    ),
  ];
}

String _deviceId(GoRouterState state) => state.pathParameters[Routes.midiDeviceIdParam] ?? '';

int _patchId(GoRouterState state) =>
    int.tryParse(state.pathParameters[Routes.midiPatchIdParam] ?? '') ?? -1;

int _sceneId(GoRouterState state) =>
    int.tryParse(state.pathParameters[Routes.midiSceneIdParam] ?? '') ?? -1;
