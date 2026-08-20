import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/app.dart';
import '../support/app_tabs.dart';
import '../support/home_streams.dart';

void main() {
  /// Pumps the real app with stand-ins for the streams that read the database:
  /// they would otherwise open the file on disk, which never resolves under the
  /// test binding and has nothing to do with navigation.
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: homeStreamOverrides(),
        child: const ToneVaultApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('bottom bar moves between all five tabs', (tester) async {
    await pumpApp(tester);

    expect(find.text('Your collection'), findsOneWidget);

    for (final (label, expectedBody) in const [
      ('Pedals', 'No pedals yet'),
      ('Rigs', 'No rigs yet'),
      ('History', 'Nothing logged yet'),
      ('Settings', 'Your gear, kept safe'),
      ('Home', 'Your collection'),
    ]) {
      await openTab(tester, label);

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

    await openTab(tester, 'History');
    await openTab(tester, 'Home');

    // An IndexedStack shell keeps inactive branches mounted, which is what lets
    // each tab hold its own scroll position and detail stack.
    expect(
      find.text('Nothing logged yet', skipOffstage: false),
      findsOneWidget,
    );
  });
}
