import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/features/pedalboards/widgets/rig_options_menu.dart';

/// What a rig as a whole offers, and what it hands back.
///
/// Nothing is written here, so what each action does is rigs_navigation_test.dart
/// and signal_chain_test.dart's job.
void main() {
  RigOption? chosen;

  setUp(() => chosen = null);

  Future<void> openMenu(WidgetTester tester, {int blockCount = 3}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              RigOptionsMenu(
                blockCount: blockCount,
                onSelected: (option) => chosen = option,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byType(RigOptionsMenu));
    await tester.pumpAndSettle();
  }

  testWidgets('offers everything that can be done to the rig itself', (
    tester,
  ) async {
    await openMenu(tester);

    expect(find.text('Edit rig'), findsOne);
    expect(find.text('Clear chain'), findsOne);
    expect(find.text('Save snapshot'), findsOne);
    expect(find.text('Delete rig'), findsOne);
  });

  testWidgets('the choice goes back to the caller, unwritten', (tester) async {
    await openMenu(tester);

    await tester.tap(find.text('Clear chain'));
    await tester.pumpAndSettle();

    expect(chosen, RigOption.clearChain);
  });

  testWidgets('a bare rig has no chain to clear', (tester) async {
    await openMenu(tester, blockCount: 0);

    // Offered greyed rather than hidden, so the menu does not change shape from
    // one rig to the next.
    expect(find.text('Clear chain'), findsOne);

    await tester.tap(find.text('Clear chain'));
    await tester.pumpAndSettle();

    expect(chosen, isNull);
    // Still open, because nothing was chosen.
    expect(find.text('Delete rig'), findsOne);
  });
}
