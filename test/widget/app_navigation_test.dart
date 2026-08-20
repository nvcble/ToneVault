import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/app.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/change_log_dao.dart';
import 'package:tone_vault/features/history/providers/history_providers.dart';
import 'package:tone_vault/features/pedalboards/providers/pedalboard_providers.dart';
import 'package:tone_vault/features/pedals/providers/pedal_providers.dart';

void main() {
  /// Pumps the real app with stand-ins for the tabs that read the database: they
  /// would otherwise open the file on disk, which never resolves under the test
  /// binding and has nothing to do with navigation.
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pedalListProvider.overrideWith(
            (ref) => Stream<List<Pedal>>.value(const []),
          ),
          pedalboardListProvider.overrideWith(
            (ref) => Stream<List<Pedalboard>>.value(const []),
          ),
          recentHistoryProvider.overrideWith(
            (ref) => Stream<List<PedalChange>>.value(const []),
          ),
        ],
        child: const ToneVaultApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('bottom bar moves between all five tabs', (tester) async {
    await pumpApp(tester);

    expect(find.text('Your rig at a glance'), findsOneWidget);

    for (final (label, expectedBody) in const [
      ('Pedals', 'No pedals yet'),
      ('Rigs', 'No rigs yet'),
      ('History', 'Nothing logged yet'),
      ('Settings', 'Your gear, kept safe'),
      ('Home', 'Your rig at a glance'),
    ]) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();

      expect(
        find.text(expectedBody),
        findsOneWidget,
        reason: 'tapping $label should show the $label tab',
      );
    }
  });

  testWidgets('keeps the previous tab alive when switching away', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    // An IndexedStack shell keeps inactive branches mounted, which is what lets
    // each tab hold its own scroll position and detail stack.
    expect(
      find.text('Nothing logged yet', skipOffstage: false),
      findsOneWidget,
    );
  });
}
