import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/app/app.dart';

void main() {
  testWidgets('bottom bar moves between all five tabs', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ToneVaultApp()));

    expect(find.text('Your rig at a glance'), findsOneWidget);

    for (final (label, expectedBody) in const [
      ('Pedals', 'No pedals yet'),
      ('Rigs', 'No rigs yet'),
      ('History', 'Nothing logged yet'),
      ('Settings', 'No settings yet'),
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
    await tester.pumpWidget(const ProviderScope(child: ToneVaultApp()));

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    // An IndexedStack shell keeps inactive branches mounted, which is what lets
    // each tab hold its own scroll position and detail stack.
    expect(find.text('Nothing logged yet', skipOffstage: false), findsOneWidget);
  });
}
