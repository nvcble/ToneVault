import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/signal_chain_dao.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/core/enums/signal_destination.dart';
import 'package:tone_vault/features/pedalboards/data/chain_endpoints.dart';
import 'package:tone_vault/features/pedalboards/data/chain_routing.dart';
import 'package:tone_vault/features/pedalboards/providers/pedalboard_providers.dart';
import 'package:tone_vault/features/pedalboards/widgets/add_block_sheet.dart';
import 'package:tone_vault/features/pedalboards/widgets/assign_pedal_sheet.dart';
import 'package:tone_vault/features/pedalboards/widgets/block_cables_sheet.dart';
import 'package:tone_vault/features/pedalboards/widgets/block_endpoint_sheet.dart';
import 'package:tone_vault/features/pedalboards/widgets/send_pair_sheet.dart';
import 'package:tone_vault/features/pedals/providers/pedal_providers.dart';
import '../support/chain_rows.dart';

/// The two sheets a block is built with: what goes here, and what fills it.
///
/// What either writes is signal_chain_test.dart's job in test/database; here the
/// question is what each one offers.
void main() {
  const pedalboardId = 4;

  Future<void> pumpSheet(
    WidgetTester tester,
    Widget sheet, {
    List<Pedal> pedals = const [],
    List<ChainBlock> chain = const [],
    ChainRouting routing = ChainRouting.none,
    ChainEndpoints endpoints = ChainEndpoints.none,
  }) async {
    // The type list is longer than the default 600pt surface, and a sheet that
    // has scrolled out of view cannot be tapped.
    tester.view.physicalSize = const Size(500, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pedalListProvider.overrideWith((ref) => Stream.value(pedals)),
          signalChainProvider(
            pedalboardId,
          ).overrideWith((ref) => Stream.value(chain)),
          signalRoutingProvider(
            pedalboardId,
          ).overrideWith((ref) => Stream.value(routing)),
          signalEndpointsProvider(
            pedalboardId,
          ).overrideWith((ref) => Stream.value(endpoints)),
        ],
        child: MaterialApp(home: Scaffold(body: sheet)),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('AddBlockSheet', () {
    testWidgets('asks only what the block is for', (tester) async {
      await pumpSheet(tester, const AddBlockSheet(pedalboardId: pedalboardId));

      expect(find.text('What goes here?'), findsOne);
      // Which pedal fills it, and where in the chain it sits, are both decided
      // afterwards - on the block itself, and by dragging.
      expect(find.textContaining('pedal'), findsNothing);
    });

    testWidgets('offers every type, in the order a board is built', (
      tester,
    ) async {
      await pumpSheet(tester, const AddBlockSheet(pedalboardId: pedalboardId));

      final offered = tester
          .widgetList<ListTile>(find.byType(ListTile))
          .map((tile) => (tile.title! as Text).data)
          .toList();
      expect(offered, [for (final type in SignalBlockType.values) type.label]);
    });
  });

  group('AssignPedalSheet', () {
    final drive = chainPedal(1, 'PureSky', brand: 'Caline');
    final verb = chainPedal(2, 'RV-6', category: PedalCategory.reverb);

    testWidgets('names the block it is filling', (tester) async {
      await pumpSheet(
        tester,
        AssignPedalSheet(
          block: chainBlock(10, type: SignalBlockType.delay).block,
        ),
        pedals: [drive],
      );

      expect(find.text('What fills this delay?'), findsOne);
    });

    testWidgets('what suits the block comes first, and is labelled', (
      tester,
    ) async {
      await pumpSheet(
        tester,
        AssignPedalSheet(block: chainBlock(10).block),
        pedals: [verb, drive],
      );

      expect(find.text('Suits this block'), findsOne);
      expect(find.text('Everything else you own'), findsOne);
      // Whose pedal it is, since two pedals can share a name.
      expect(find.text('Caline'), findsOne);
      expect(
        tester.getCenter(find.text('PureSky')).dy,
        lessThan(tester.getCenter(find.text('RV-6')).dy),
      );
    });

    testWidgets('one group alone needs no heading', (tester) async {
      await pumpSheet(
        tester,
        AssignPedalSheet(block: chainBlock(10).block),
        pedals: [drive],
      );

      expect(find.text('Suits this block'), findsNothing);
      expect(find.text('PureSky'), findsOne);
    });

    testWidgets('whatever is already in the block is ticked, not offered', (
      tester,
    ) async {
      final entry = chainBlock(10, pedal: drive);

      await pumpSheet(
        tester,
        AssignPedalSheet(block: entry.block),
        pedals: [drive],
        chain: [entry],
      );

      expect(find.byIcon(Icons.check), findsOne);
      expect(
        tester.widget<ListTile>(find.widgetWithText(ListTile, 'PureSky')).onTap,
        isNull,
      );
      // Emptying it again is offered, and says what it will not touch.
      expect(find.text('Leave this block empty'), findsOne);
      expect(find.text('The pedal stays in your inventory'), findsOne);
    });

    testWidgets('an empty block is not offered a way to be emptied', (
      tester,
    ) async {
      await pumpSheet(
        tester,
        AssignPedalSheet(block: chainBlock(10).block),
        pedals: [drive],
      );

      expect(find.text('Leave this block empty'), findsNothing);
    });

    testWidgets('an empty inventory says to fill that first', (tester) async {
      await pumpSheet(tester, AssignPedalSheet(block: chainBlock(10).block));

      expect(
        find.textContaining('Add a pedal to your inventory first'),
        findsOne,
      );
    });

    testWidgets('a rig already holding everything says so instead', (
      tester,
    ) async {
      final elsewhere = chainBlock(11, position: 1, pedal: drive);
      final sold = chainPedal(3, 'Sold Drive', status: PedalStatus.sold);

      await pumpSheet(
        tester,
        AssignPedalSheet(block: chainBlock(10).block),
        pedals: [drive, sold],
        chain: [chainBlock(10), elsewhere],
      );

      // A different message, because nothing is missing from the inventory - it
      // is all on this rig already.
      expect(find.textContaining('already on this'), findsOne);
    });
  });

  group('BlockCablesSheet', () {
    final chain = [
      chainBlock(10),
      chainBlock(11, type: SignalBlockType.delay, position: 1),
      chainBlock(12, type: SignalBlockType.reverb, position: 2),
    ];

    Future<void> pumpCables(
      WidgetTester tester, {
      int sourceBlockId = 10,
      ChainRouting routing = ChainRouting.none,
    }) {
      return pumpSheet(
        tester,
        BlockCablesSheet(
          pedalboardId: pedalboardId,
          sourceBlockId: sourceBlockId,
        ),
        chain: chain,
        routing: routing,
      );
    }

    testWidgets('an unwired block says the rig runs in order', (tester) async {
      await pumpCables(tester);

      // Not an empty state: a chain with no cables is the ordinary rig.
      expect(find.textContaining('carries on to whatever is next'), findsOne);
      expect(find.text('Add a cable to'), findsOne);
      expect(find.text('Delay'), findsOne);
      expect(find.text('Reverb'), findsOne);
    });

    testWidgets('what it feeds can be unplugged, and is not offered twice', (
      tester,
    ) async {
      await pumpCables(
        tester,
        routing: ChainRouting([chainCable(1, source: 10, target: 11)]),
      );

      expect(find.byIcon(Icons.link_off), findsOne);
      expect(find.text('Delay'), findsOne);
      expect(find.text('Reverb'), findsOne);
      expect(
        find.textContaining('carries on to whatever is next'),
        findsNothing,
      );
    });

    testWidgets('a cable that would loop is greyed with its reason', (
      tester,
    ) async {
      await pumpCables(
        tester,
        sourceBlockId: 11,
        routing: ChainRouting([chainCable(1, source: 10, target: 11)]),
      );

      expect(find.text('That would send signal back into itself.'), findsOne);
      expect(
        tester
            .widget<ListTile>(find.widgetWithText(ListTile, 'Overdrive'))
            .enabled,
        isFalse,
      );
    });

    testWidgets('a merge is asked what joins up at it, from its own end', (
      tester,
    ) async {
      await pumpSheet(
        tester,
        const BlockCablesSheet(pedalboardId: pedalboardId, sourceBlockId: 13),
        chain: [
          ...chain,
          chainBlock(13, type: SignalBlockType.merge, position: 3),
        ],
        routing: ChainRouting([chainCable(1, source: 11, target: 13)]),
      );

      // Going back to each path in turn to point it here would be describing the
      // rig the long way round.
      expect(find.text('What joins up here?'), findsOne);
      expect(find.text('Join a path from'), findsOne);
      expect(find.byIcon(Icons.call_merge), findsOne);
      // What it feeds is still asked, below.
      expect(find.text('Add a cable to'), findsOne);
    });

    testWidgets('a merge with nothing arriving says what it is waiting for', (
      tester,
    ) async {
      await pumpSheet(
        tester,
        const BlockCablesSheet(pedalboardId: pedalboardId, sourceBlockId: 13),
        chain: [
          ...chain,
          chainBlock(13, type: SignalBlockType.merge, position: 3),
        ],
      );

      expect(find.textContaining('Nothing joins up here yet'), findsOne);
    });
  });

  group('BlockEndpointSheet', () {
    final send = chainBlock(10, type: SignalBlockType.send).block;
    final back = chainBlock(20, type: SignalBlockType.fxReturn).block;

    /// Whether Save would write anything yet.
    bool canSave(WidgetTester tester) {
      return tester
              .widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'))
              .onPressed !=
          null;
    }

    testWidgets('asks a send where signal goes, grouped by what it is', (
      tester,
    ) async {
      await pumpSheet(tester, BlockEndpointSheet(block: send));

      expect(find.text('Where does this go?'), findsOne);
      // The two amplifier sockets together, because they are the pair most easily
      // muddled and neither is the other.
      expect(find.text('An amplifier'), findsOne);
      expect(find.text('Amp input'), findsOne);
      expect(find.text('Amp FX return'), findsOne);
      expect(find.text('Front of house'), findsOne);
    });

    testWidgets('asks a return where signal comes from instead', (
      tester,
    ) async {
      await pumpSheet(tester, BlockEndpointSheet(block: back));

      expect(find.text('Where does this come from?'), findsOne);
      expect(find.text('Guitar'), findsOne);
      // The amp sending to the board, which is the opposite direction to the
      // board's own send.
      expect(find.text('Amp FX send'), findsOne);
      // A block cannot be both ends of the same cable, so no destination is
      // offered here at all.
      expect(find.text('Front of house'), findsNothing);
    });

    testWidgets('nothing is saved until somewhere has been chosen', (
      tester,
    ) async {
      await pumpSheet(tester, BlockEndpointSheet(block: send));

      // Disabled rather than refused after the tap: the user could not have
      // avoided that refusal.
      expect(canSave(tester), isFalse);

      await tester.tap(find.text('Front of house'));
      await tester.pumpAndSettle();

      expect(canSave(tester), isTrue);
    });

    testWidgets('something else has to be said in words', (tester) async {
      await pumpSheet(tester, BlockEndpointSheet(block: send));

      await tester.tap(find.text('Something else'));
      await tester.pumpAndSettle();

      // 'Something else' only says the app's list did not cover it, so the user's
      // own words are the whole answer.
      expect(find.text('What is it?'), findsOne);
      expect(canSave(tester), isFalse);

      await tester.enterText(find.byType(TextField).first, 'Leslie cabinet');
      await tester.pumpAndSettle();

      expect(canSave(tester), isTrue);
    });

    testWidgets('opens on what was said before, and offers to unsay it', (
      tester,
    ) async {
      await pumpSheet(
        tester,
        BlockEndpointSheet(
          block: send,
          saved: chainEndpoint(
            1,
            blockId: 10,
            destination: SignalDestination.physicalAmpInput,
            gear: 'Marshall JVM',
          ),
        ),
      );

      expect(find.byIcon(Icons.radio_button_checked), findsOne);
      expect(find.text('Marshall JVM'), findsOne);
      // Worded as unsaying it rather than as deleting: the block stays on the rig.
      expect(find.text('Not saying'), findsOne);
    });

    testWidgets('a block that was never asked has nothing to unsay', (
      tester,
    ) async {
      await pumpSheet(tester, BlockEndpointSheet(block: send));

      expect(find.text('Not saying'), findsNothing);
    });
  });

  group('SendPairSheet', () {
    final chain = [
      chainBlock(10, label: 'To the amp', type: SignalBlockType.send),
      chainBlock(20, type: SignalBlockType.fxReturn, position: 1),
      chainBlock(30, type: SignalBlockType.delay, position: 2),
    ];

    testWidgets('offers what takes signal back in, and nothing else', (
      tester,
    ) async {
      await pumpSheet(
        tester,
        const SendPairSheet(pedalboardId: pedalboardId, sendBlockId: 10),
        chain: chain,
      );

      expect(find.text('Where does it come back in?'), findsOne);
      expect(find.text('Return'), findsOne);
      // Not the delay in the middle of the chain, and not the send itself.
      expect(find.text('Delay'), findsNothing);
      expect(find.text('To the amp'), findsNothing);
    });

    testWidgets('a rig with no return says to add one', (tester) async {
      await pumpSheet(
        tester,
        const SendPairSheet(pedalboardId: pedalboardId, sendBlockId: 10),
        chain: [chain.first],
      );

      // A send with nothing paired is a loop half described, not a mistake, so
      // this says what is missing rather than refusing anything.
      expect(find.textContaining('Add a return block'), findsOne);
    });

    testWidgets('the return already in use is ticked and offers a way out', (
      tester,
    ) async {
      await pumpSheet(
        tester,
        const SendPairSheet(pedalboardId: pedalboardId, sendBlockId: 10),
        chain: chain,
        endpoints: ChainEndpoints([
          chainEndpoint(1, blockId: 10, pairedBlockId: 20),
          chainEndpoint(2, blockId: 20, pairedBlockId: 10),
        ]),
      );

      expect(find.byIcon(Icons.check_circle), findsOne);
      expect(
        tester.widget<ListTile>(find.widgetWithText(ListTile, 'Return')).onTap,
        isNull,
      );
      // Separating them leaves both blocks where they are.
      expect(find.text('Not paired'), findsOne);
      expect(find.text('Both blocks stay on the rig'), findsOne);
    });

    testWidgets('a return another send uses is offered anyway, marked', (
      tester,
    ) async {
      await pumpSheet(
        tester,
        const SendPairSheet(pedalboardId: pedalboardId, sendBlockId: 10),
        chain: [
          ...chain,
          chainBlock(40, type: SignalBlockType.send, position: 3),
        ],
        endpoints: ChainEndpoints([
          chainEndpoint(1, blockId: 40, pairedBlockId: 20),
          chainEndpoint(2, blockId: 20, pairedBlockId: 40),
        ]),
      );

      // Left in rather than hidden, so a user rearranging their loops can see
      // where the return they were after has gone.
      expect(find.text('Already paired with another send'), findsOne);
    });
  });
}
