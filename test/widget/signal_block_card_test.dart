import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/daos/signal_chain_dao.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/features/pedalboards/widgets/signal_block_card.dart';
import 'package:tone_vault/features/pedalboards/widgets/signal_block_menu.dart';
import '../support/chain_rows.dart';

/// One block of a chain: how it reads whether or not there is a pedal in it, and
/// what it offers when it is tapped.
void main() {
  Future<void> pumpCard(
    WidgetTester tester,
    ChainBlock entry, {
    int position = 0,
    String? edge,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SignalBlockCard(
            block: entry.block,
            pedal: entry.pedal,
            position: position,
            edge: edge,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('SignalBlockCard', () {
    testWidgets('an empty block reads as a place waiting to be filled', (
      tester,
    ) async {
      await pumpCard(tester, chainBlock(10, type: SignalBlockType.delay));

      // What it is for, and that nothing is in it yet - not a row with something
      // missing.
      expect(find.text('Delay'), findsOne);
      expect(find.text('Empty'), findsOne);
    });

    testWidgets('a label the user chose leads, and the type follows', (
      tester,
    ) async {
      await pumpCard(
        tester,
        chainBlock(10, type: SignalBlockType.delay, label: 'Slapback'),
      );

      expect(find.text('Slapback'), findsOne);
      expect(find.text('Delay · Empty'), findsOne);
    });

    testWidgets('a filled block says what is in it, and whose it is', (
      tester,
    ) async {
      await pumpCard(
        tester,
        chainBlock(10, pedal: chainPedal(1, 'PureSky', brand: 'Caline')),
      );

      expect(find.text('PureSky'), findsOne);
      // Only what the title did not already say: the pedal's own name is not
      // repeated under itself.
      expect(find.text('Overdrive · Caline'), findsOne);
    });

    testWidgets('a pedal that is not the active one says so', (tester) async {
      await pumpCard(
        tester,
        chainBlock(
          10,
          pedal: chainPedal(1, 'Spare OD', status: PedalStatus.backup),
        ),
      );

      // Worth knowing before a gig: this block is filled by a pedal in a drawer.
      expect(find.text('Overdrive · Backup'), findsOne);
    });

    testWidgets('numbered by where signal reaches it, counting from one', (
      tester,
    ) async {
      await pumpCard(tester, chainBlock(10, position: 2), position: 2);

      expect(find.text('3'), findsOne);
    });

    testWidgets('an empty block is an outline, a filled one a solid card', (
      tester,
    ) async {
      await pumpCard(tester, chainBlock(10, type: SignalBlockType.delay));

      // A space the user has set aside, rather than a card pretending to hold
      // gear.
      final outlined = tester.widget<Card>(find.byType(Card));
      expect(outlined.elevation, 0);
      expect(outlined.shape, isA<RoundedRectangleBorder>());

      await pumpCard(tester, chainBlock(10, pedal: chainPedal(1, 'PureSky')));

      // Left to the theme, so a filled block looks like every other card in the
      // app.
      final solid = tester.widget<Card>(find.byType(Card));
      expect(solid.elevation, isNull);
      expect(solid.shape, isNull);
    });

    testWidgets('an edge of the rig says what it reaches, on its own line', (
      tester,
    ) async {
      await pumpCard(
        tester,
        chainBlock(10, label: 'To the amp', type: SignalBlockType.send),
        edge: 'To Amp input · Marshall JVM · back in at Return',
      );

      // What the block is, and then where the rig leaves off - which is what the
      // user came to this card to read.
      expect(find.text('Send · Empty'), findsOne);
      expect(
        find.text('To Amp input · Marshall JVM · back in at Return'),
        findsOne,
      );
    });

    testWidgets('a block in the middle of the chain has no such line', (
      tester,
    ) async {
      await pumpCard(tester, chainBlock(10, type: SignalBlockType.delay));

      expect(find.textContaining('To '), findsNothing);
    });

    testWidgets('a bypassed block is faded rather than hidden', (tester) async {
      await pumpCard(tester, chainBlock(10, isEnabled: false));

      // Still on the board, and still taking its turn in the chain.
      expect(find.text('Overdrive'), findsOne);
      expect(find.byIcon(Icons.flash_off_outlined), findsOne);
      expect(
        tester.widget<Opacity>(find.byType(Opacity).first).opacity,
        lessThan(1),
      );
    });
  });

  group('showSignalBlockMenu', () {
    SignalBlockAction? chosen;

    setUp(() => chosen = null);

    /// Opens the menu for [entry] by tapping the button that shows it.
    Future<void> openMenu(WidgetTester tester, ChainBlock entry) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  chosen = await showSignalBlockMenu(context, entry);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets('an empty block is not offered settings to view', (
      tester,
    ) async {
      await openMenu(tester, chainBlock(10, type: SignalBlockType.delay));

      // Settings are a pedal's own, so there are none to read off here.
      expect(find.text('View settings'), findsNothing);
      expect(find.text('Put a pedal here'), findsOne);
      expect(find.text('Edit block'), findsOne);
      expect(find.text('Bypass'), findsOne);
      expect(find.text('Remove from chain'), findsOne);
    });

    testWidgets('a filled block offers the pedal it would open', (
      tester,
    ) async {
      await openMenu(tester, chainBlock(10, pedal: chainPedal(1, 'PureSky')));

      expect(find.text('View settings'), findsOne);
      expect(find.text('Change pedal'), findsOne);
      // Removing the block does not remove the pedal, which is worth saying
      // before the tap rather than after it.
      expect(find.text('The pedal stays in your inventory'), findsOne);
    });

    testWidgets('a bypassed block is offered its way back in', (tester) async {
      await openMenu(tester, chainBlock(10, isEnabled: false));

      expect(find.text('Bring back in'), findsOne);
      expect(find.text('Bypass'), findsNothing);
    });

    testWidgets('the choice goes back to the caller, unwritten', (
      tester,
    ) async {
      await openMenu(tester, chainBlock(10, pedal: chainPedal(1, 'PureSky')));

      await tester.tap(find.text('View settings'));
      await tester.pumpAndSettle();

      expect(chosen, SignalBlockAction.viewSettings);
    });

    testWidgets('editing the block is offered whether or not it is filled', (
      tester,
    ) async {
      await openMenu(tester, chainBlock(10, pedal: chainPedal(1, 'PureSky')));

      await tester.tap(find.text('Edit block'));
      await tester.pumpAndSettle();

      expect(chosen, SignalBlockAction.editBlock);
    });

    testWidgets('a send is asked where it goes and what brings it back', (
      tester,
    ) async {
      await openMenu(tester, chainBlock(10, type: SignalBlockType.send));

      expect(find.text('Where this goes'), findsOne);
      expect(find.text('Comes back through'), findsOne);
      // Signal has already left the rig here, so nothing on the board follows it
      // and there is no cable to run.
      expect(find.text('Cables'), findsNothing);
    });

    testWidgets('a return is asked where signal comes from, and still cabled', (
      tester,
    ) async {
      await openMenu(tester, chainBlock(10, type: SignalBlockType.fxReturn));

      expect(find.text('Where this comes from'), findsOne);
      expect(find.text('Cables'), findsOne);
      // The far half of the same answer: being asked from both ends is how the two
      // get muddled.
      expect(find.text('Comes back through'), findsNothing);
    });

    testWidgets('a block in the middle of the chain is asked neither', (
      tester,
    ) async {
      await openMenu(tester, chainBlock(10, type: SignalBlockType.delay));

      expect(find.textContaining('Where this'), findsNothing);
      expect(find.text('Cables'), findsOne);
    });

    testWidgets('dismissing it chooses nothing', (tester) async {
      await openMenu(tester, chainBlock(10));

      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      expect(chosen, isNull);
    });
  });
}
