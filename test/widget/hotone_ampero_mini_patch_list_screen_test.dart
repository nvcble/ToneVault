import 'package:drift/native.dart';
import 'package:flutter/gestures.dart' show kDoubleTapTimeout;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/theme/app_theme.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/database_provider.dart';
import 'package:tone_vault/core/midi/midi_endpoint.dart';
import 'package:tone_vault/core/midi/midi_engine.dart';
import 'package:tone_vault/core/midi/midi_transport_type.dart';
import 'package:tone_vault/core/midi/profiles/hotone_ampero_mini/hotone_ampero_mini_profile.dart';
import 'package:tone_vault/features/midi/hotone_ampero_mini/providers/hotone_ampero_mini_patch_selection_providers.dart';
import 'package:tone_vault/features/midi/hotone_ampero_mini/screens/hotone_ampero_mini_patch_list_screen.dart';
import 'package:tone_vault/features/midi/hotone_ampero_mini/widgets/ampero_mini_patch_grid_tile.dart';
import 'package:tone_vault/features/midi/providers/midi_connection_controller.dart';
import 'package:tone_vault/features/midi/providers/midi_engine_providers.dart';

import '../support/ampero_mini_captures.dart';
import '../support/fake_midi_transport.dart';

void main() {
  const profile = HotoneAmperoMiniProfile();
  const endpoint = MidiEndpoint(
    id: 'dev-1',
    name: 'Ampero Mini',
    type: MidiTransportType.usb,
  );

  late AppDatabase database;
  late MidiEngine engine;
  late FakeMidiTransport transport;
  late ProviderContainer container;

  void prepare() {
    database = AppDatabase(NativeDatabase.memory());
    transport = FakeMidiTransport(endpoints: const [endpoint]);
    engine = MidiEngine()
      ..attach(profile: profile, transportBuilder: () => transport);
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        midiEngineProvider.overrideWithValue(engine),
      ],
    );
    addTearDown(() async {
      container.dispose();
      engine.dispose();
      await database.close();
    });
  }

  /// A phone held upright, which is the only way this page is held - and the
  /// shape it has to fit everything into, since it does not scroll.
  Future<void> pump(
    WidgetTester tester, {
    Size size = const Size(400, 800),
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const HotoneAmperoMiniPatchListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> doubleTap(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pump(kDoubleTapTimeout ~/ 2);
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  /// Puts the grid on the page holding [number] the way the app itself does:
  /// the grid opens where the selection is, so pre-selecting a patch before
  /// the first build is how a test reaches one 17 pages in.
  void openOn(int number) =>
      container
              .read(hotoneAmperoMiniPreSelectedPatchNumberProvider.notifier)
              .state =
          number;

  testWidgets('a single tap only pre-selects; nothing is sent', (tester) async {
    prepare();
    await container.read(midiConnectionProvider(profile.id).notifier).connect();
    await pump(tester);

    await tester.tap(find.text('P01-3'));
    await tester.pumpAndSettle(kDoubleTapTimeout);

    expect(transport.sent, isEmpty);
    expect(find.text('Not sent yet'), findsOneWidget);
  });

  testWidgets('a double tap sends Program Change and marks the patch active', (
    tester,
  ) async {
    prepare();
    await container.read(midiConnectionProvider(profile.id).notifier).connect();
    await pump(tester);

    await doubleTap(tester, 'P01-3');

    expect(transport.sent, isNotEmpty);
    expect(find.text('Not sent yet'), findsNothing);
  });

  testWidgets('while disconnected, a double tap does not send anything', (
    tester,
  ) async {
    prepare();
    await pump(tester);

    await doubleTap(tester, 'P01-3');

    expect(transport.sent, isEmpty);
    expect(find.textContaining('Connect to the Ampero Mini'), findsOneWidget);
  });

  testWidgets('a send is never presented as confirmed by the pedal', (
    tester,
  ) async {
    prepare();
    await container.read(midiConnectionProvider(profile.id).notifier).connect();
    await pump(tester);

    await doubleTap(tester, 'P01-3');

    expect(
      find.text('This pedal cannot confirm what it loaded'),
      findsOneWidget,
    );
  });

  testWidgets('the pedal\'s tick never moves the selection', (tester) async {
    prepare();
    await container.read(midiConnectionProvider(profile.id).notifier).connect();
    await pump(tester);

    // The bug this pins: the once-a-second `04 <hi> <lo>` counter was read as
    // "the patch I have loaded", so after a couple of minutes of uptime it
    // drove the display and the user's own choice stopped showing. Both the
    // low-counter and high-counter forms are fed in here.
    await doubleTap(tester, 'P01-3');
    transport.receive(amperoMiniSysEx(amperoMiniTick0001));
    transport.receive(amperoMiniSysEx(amperoMiniTick0103));
    await tester.pumpAndSettle();

    // Still the patch that was double-tapped, and not either counter value:
    // 1 would have read as P01-2, and 131 as F11-3.
    expect(find.textContaining('P01-3 · 002'), findsWidgets);
    expect(find.textContaining('· 001'), findsNothing);
    expect(find.textContaining('· 131'), findsNothing);
  });

  testWidgets('the status broadcast never moves the selection', (tester) async {
    prepare();
    await container.read(midiConnectionProvider(profile.id).notifier).connect();
    await pump(tester);

    transport.receive(amperoMiniSysEx(amperoMiniStatus));
    await tester.pumpAndSettle();

    expect(find.text('Not sent yet'), findsOneWidget);
  });

  testWidgets('unread patches show no invented name, and say why', (
    tester,
  ) async {
    prepare();
    await pump(tester);

    // Nothing has been read off the device, so no tile may claim a name.
    expect(find.textContaining('Patch 0'), findsNothing);
    expect(find.text('(name unknown)'), findsWidgets);
    expect(find.text('Names cannot be read from this pedal'), findsOneWidget);

    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('No such command has been confirmed for this model'),
      findsOneWidget,
    );
  });

  testWidgets('twelve slots and the pager fit one upright screen', (
    tester,
  ) async {
    prepare();

    await pump(tester);

    // The MG-30's landing page in this device's own terms: three by four,
    // filling the screen, with nothing below the fold and no scrolling. An
    // overflow fails the test rather than only striping the screen.
    expect(find.byType(AmperoMiniPatchGridTile), findsNWidgets(12));
    expect(tester.getRect(find.text('Page 1 of 17')).bottom, lessThan(800));
  });

  testWidgets('and on a small screen too, with smaller slots', (tester) async {
    prepare();

    await pump(tester, size: const Size(320, 560));

    expect(find.byType(AmperoMiniPatchGridTile), findsNWidgets(12));
    expect(tester.getRect(find.text('Page 1 of 17')).bottom, lessThan(560));
    // Still a target worth hitting mid-song, not a sliver.
    expect(
      tester.getSize(find.byType(AmperoMiniPatchGridTile).first).height,
      greaterThan(48),
    );
  });

  testWidgets('searching jumps the grid to the patch, sending nothing', (
    tester,
  ) async {
    prepare();
    await container.read(midiConnectionProvider(profile.id).notifier).connect();
    await pump(tester);

    // The search is an app-bar icon rather than a field on the page: the page
    // is twelve slots on one screen, and a field costs two rows of them.
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'F33-3');
    await tester.pumpAndSettle();
    await tester.tap(find.text('F33-3').last);
    await tester.pumpAndSettle();

    // The last page of the grid, with nothing on the wire: finding a patch is
    // not choosing it.
    expect(find.text('Page 17 of 17'), findsOneWidget);
    expect(find.text('F33-3'), findsOneWidget);
    expect(transport.sent, isEmpty);
  });

  testWidgets('the grid pages through all 198 patches', (tester) async {
    prepare();
    await pump(tester);

    // 198 patches at 12 to a page. The first page starts at P01-1 and the
    // second at P05-1, which is what proves the paging is over the whole
    // collection rather than over one page's worth.
    expect(find.text('Page 1 of 17'), findsOneWidget);
    expect(find.text('P01-1'), findsOneWidget);
    expect(find.text('P05-1'), findsNothing);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    expect(find.text('Page 2 of 17'), findsOneWidget);
    expect(find.text('P05-1'), findsOneWidget);
    expect(find.text('P01-1'), findsNothing);
  });

  testWidgets('the grid reaches the pedal\'s last patch, F33-3', (
    tester,
  ) async {
    prepare();
    // 198 patches is the whole point, and the last one existing is what
    // proves the count is not the MG-30's 128.
    openOn(197);
    await pump(tester);

    expect(find.text('F33-3'), findsOneWidget);
  });

  testWidgets('a factory patch offers experimental attempts, sending none', (
    tester,
  ) async {
    prepare();
    await container.read(midiConnectionProvider(profile.id).notifier).connect();
    // F01-1, the patch the user double-tapped on hardware to no effect.
    openOn(99);
    await pump(tester);

    expect(find.text('F01-1'), findsOneWidget);
    // Its own tile says so - the rest of this page is factory patches too.
    expect(
      find.descendant(
        of: find.widgetWithText(AmperoMiniPatchGridTile, 'F01-1'),
        matching: find.text('tap twice to try'),
      ),
      findsOneWidget,
    );

    await doubleTap(tester, 'F01-1');
    await tester.pumpAndSettle();

    // Opening the sheet must not put anything on the wire, and it must not
    // claim any of the layouts works.
    expect(transport.sent, isEmpty);
    expect(find.text('Try to reach F01-1'), findsOneWidget);
    expect(find.textContaining('nothing here can tell'), findsOneWidget);
  });

  testWidgets('a Bank Select attempt is sent only when the user asks', (
    tester,
  ) async {
    prepare();
    await container.read(midiConnectionProvider(profile.id).notifier).connect();
    openOn(99);
    await pump(tester);

    await doubleTap(tester, 'F01-1');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Send').first);
    await tester.pumpAndSettle();

    // CC 0, CC 32, then the Program Change - and reported as sent, never as
    // selected, because only the pedal's display can settle that.
    expect(transport.sent, hasLength(3));
    expect(find.text('Sent. Did the pedal move?'), findsOneWidget);
  });

  testWidgets('the last user patch, P33-3, is still sent', (tester) async {
    prepare();
    await container.read(midiConnectionProvider(profile.id).notifier).connect();
    openOn(98);
    await pump(tester);

    await doubleTap(tester, 'P33-3');

    expect(transport.sent, isNotEmpty);
  });

  testWidgets('the grid agrees with the pedal at the user/factory boundary', (
    tester,
  ) async {
    prepare();
    // The mismatch the user found on hardware: the app called index 98
    // "P32-3" while the pedal called it P33-3, and the pedal's next patch was
    // F01-1. Both are checked here so the fix cannot regress on one side -
    // one page holds the two of them.
    openOn(98);
    await pump(tester);

    expect(find.text('P33-3'), findsOneWidget);
    expect(find.text('P32-3'), findsNothing);
    expect(find.text('F01-1'), findsOneWidget);
  });

  testWidgets(
    'the overflow menu reaches MIDI Monitor and MIDI Diagnostics only',
    (tester) async {
      prepare();
      await pump(tester);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('MIDI Monitor'), findsOneWidget);
      expect(find.text('MIDI Diagnostics'), findsOneWidget);
      // No NUX-only destination (Live Control's Scenes) leaks into this
      // device's own menu.
      expect(find.text('Live Control'), findsNothing);
    },
  );
}
