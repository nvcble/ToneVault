import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tone_vault/app/router/routes.dart';
import 'package:tone_vault/features/midi/widgets/midi_module_menu.dart';

/// The module header's one overflow menu.
///
/// Worth pumping: the six destinations used to be three app-bar icons plus a
/// "More" list further down the screen, so what this widget has to prove is that
/// none of them was dropped on the way into a single menu.
void main() {
  const profileId = 'nux_mg30_v5';
  final destinations = {
    'Live Control': Routes.liveControl(profileId),
    'Patches': Routes.midiPatches(profileId),
    'All Parameters': Routes.midiParameters(profileId),
    'CC Mapping': Routes.midiMapping(profileId),
    'MIDI Monitor': Routes.midiMonitor(profileId),
    'MIDI Diagnostics': Routes.midiDiagnostics(profileId),
  };

  // The real paths, each standing in for its screen, so a route the menu names
  // and the app does not would fail to build rather than pass unnoticed.
  Widget app() => MaterialApp.router(
    routerConfig: GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            appBar: AppBar(
              actions: const [MidiModuleMenu(profileId: profileId)],
            ),
          ),
        ),
        for (final route in destinations.values)
          GoRoute(path: route, builder: (context, state) => Text('at $route')),
      ],
    ),
  );

  testWidgets('holds every MIDI screen behind one overflow button', (
    tester,
  ) async {
    await tester.pumpWidget(app());

    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    for (final label in destinations.keys) {
      expect(
        find.text(label),
        findsOneWidget,
        reason: '$label is not in the menu',
      );
    }
  });

  testWidgets('choosing a destination goes there', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.text('MIDI Diagnostics'));
    await tester.pumpAndSettle();

    expect(find.text('at ${destinations['MIDI Diagnostics']}'), findsOneWidget);
  });
}
