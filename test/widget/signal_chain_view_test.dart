import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/daos/signal_chain_dao.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/core/enums/signal_connection_type.dart';
import 'package:tone_vault/core/enums/signal_destination.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/pedalboards/data/chain_endpoints.dart';
import 'package:tone_vault/features/pedalboards/data/chain_routing.dart';
import 'package:tone_vault/features/pedalboards/providers/pedalboard_providers.dart';
import 'package:tone_vault/features/pedalboards/widgets/signal_block_card.dart';
import 'package:tone_vault/features/pedalboards/widgets/signal_chain_canvas.dart';
import 'package:tone_vault/features/pedalboards/widgets/signal_chain_link.dart';
import 'package:tone_vault/features/pedalboards/widgets/signal_chain_view.dart';
import '../support/chain_rows.dart';

/// A rig's chain on screen: how it reads, and what a drag asks for.
///
/// What the repository does with a drag is signal_chain_test.dart's job in
/// test/database; here the question is what the canvas hands it.
void main() {
  const pedalboardId = 4;

  final chain = [
    chainBlock(
      10,
      type: SignalBlockType.wah,
      pedal: chainPedal(1, 'Vox Wah', brand: 'Vox'),
    ),
    chainBlock(11, position: 1, pedal: chainPedal(2, 'Caline PureSky')),
    chainBlock(12, type: SignalBlockType.delay, position: 2, label: 'Slapback'),
  ];

  /// What each block reads as, top to bottom.
  List<String> orderOnScreen(WidgetTester tester) {
    return [
      for (final card in tester.widgetList<SignalBlockCard>(
        find.byType(SignalBlockCard),
      ))
        card.pedal?.name ?? card.block.label ?? card.block.blockType.label,
    ];
  }

  /// The transparent, raised layer the canvas wraps a card in while it is being
  /// dragged: a shadow under the card rather than a second surface behind it.
  Iterable<Material> liftedCards(WidgetTester tester) {
    return tester
        .widgetList<Material>(find.byType(Material))
        .where(
          (layer) => layer.color == Colors.transparent && layer.elevation > 0,
        );
  }

  /// Drags the card at [index] down past the one below it, by its own height so
  /// the distance holds whatever the card ends up measuring.
  Future<void> dragDownOneCard(WidgetTester tester, int index) async {
    final height = tester.getSize(find.byType(SignalBlockCard).first).height;
    final gesture = await tester.startGesture(
      tester.getCenter(find.byIcon(Icons.drag_handle).at(index)),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // In two moves, so the list sees a drag rather than a jump.
    await gesture.moveBy(Offset(0, height * 0.7));
    await tester.pump();
    await gesture.moveBy(Offset(0, height * 0.5));
    await tester.pump();

    await gesture.up();
    await tester.pumpAndSettle();
  }

  group('SignalChainView', () {
    Future<void> pumpView(
      WidgetTester tester,
      Stream<List<ChainBlock>> chain, {
      ChainRouting routing = ChainRouting.none,
      ChainEndpoints endpoints = ChainEndpoints.none,
    }) async {
      // Three cards, the two ends and the button are taller than the default
      // 600pt surface, and the amp would otherwise be below the fold.
      tester.view.physicalSize = const Size(400, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            signalChainProvider(pedalboardId).overrideWith((ref) => chain),
            signalRoutingProvider(
              pedalboardId,
            ).overrideWith((ref) => Stream.value(routing)),
            signalEndpointsProvider(
              pedalboardId,
            ).overrideWith((ref) => Stream.value(endpoints)),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SignalChainView(pedalboardId: pedalboardId)),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('says what a chain is for when the rig is bare', (
      tester,
    ) async {
      await pumpView(tester, Stream.value(const []));

      expect(find.text('Nothing on this rig yet'), findsOne);
      expect(find.textContaining('from your guitar'), findsOne);
      // That a block may wait empty is the part worth saying out loud: a rig is
      // designed before it is bought.
      expect(find.textContaining('wait empty'), findsOne);
      // Adding one is the only thing to do here, so the button is on screen even
      // with an empty chain.
      expect(find.widgetWithText(FilledButton, 'Add block'), findsOne);
    });

    testWidgets('draws the chain between the guitar and wherever it goes', (
      tester,
    ) async {
      await pumpView(tester, Stream.value(chain));

      expect(orderOnScreen(tester), ['Vox Wah', 'Caline PureSky', 'Slapback']);
      // Neither end is a block the user put there, so neither can be dragged.
      expect(find.text('Guitar'), findsOne);
      // Not called the amp: plenty of rigs finish at a desk or an interface.
      expect(find.text('Wherever this goes'), findsOne);
      expect(find.byIcon(Icons.drag_handle), findsExactly(3));
    });

    testWidgets('a rig that says where it ends is not guessed at', (
      tester,
    ) async {
      await pumpView(
        tester,
        Stream.value([
          ...chain,
          chainBlock(13, type: SignalBlockType.output, position: 3),
        ]),
      );

      // The block says it, and better than the guess could.
      expect(find.text('Wherever this goes'), findsNothing);
      expect(find.text('Guitar'), findsOne);
    });

    testWidgets('says nothing about the wiring of a plain chain', (
      tester,
    ) async {
      await pumpView(tester, Stream.value(chain));

      // Straight through in order, which is most rigs: there is nothing to point
      // out, so the panel is not there to be dismissed.
      expect(find.textContaining('to check'), findsNothing);
    });

    testWidgets('mentions a block the cables never reach', (tester) async {
      await pumpView(
        tester,
        Stream.value(chain),
        // The wah runs to the drive, and nothing runs to the delay.
        routing: ChainRouting([chainCable(1, source: 10, target: 11)]),
      );

      expect(find.text('2 things to check'), findsOne);
      await tester.tap(find.text('2 things to check'));
      await tester.pumpAndSettle();

      // Both ends of the gap: the drive feeds nothing, and nothing feeds the
      // delay.
      expect(find.text('Caline PureSky does not feed anything yet.'), findsOne);
      expect(find.text('Nothing feeds Slapback yet.'), findsOne);
      // Said as an observation, because a half-wired rig is a normal thing to
      // leave and come back to.
      expect(find.textContaining('stops you saving'), findsOne);
    });

    testWidgets('shows where the rig leaves off on the block that says so', (
      tester,
    ) async {
      await pumpView(
        tester,
        Stream.value([
          ...chain,
          chainBlock(13, type: SignalBlockType.output, position: 3),
        ]),
        endpoints: ChainEndpoints([
          chainEndpoint(
            1,
            blockId: 13,
            destination: SignalDestination.foh,
            gear: 'Behringer X32',
          ),
        ]),
      );

      expect(find.text('To Front of house · Behringer X32'), findsOne);
    });

    testWidgets('keeps a failure readable', (tester) async {
      await pumpView(tester, Stream<List<ChainBlock>>.error(Exception('disk')));

      expect(find.text('Could not load the chain'), findsOne);
      expect(find.textContaining('disk'), findsNothing);
    });
  });

  group('SignalChainCanvas', () {
    List<int>? reordered;
    ChainBlock? opened;
    SignalBlockType? asked;

    setUp(() {
      reordered = null;
      opened = null;
      asked = null;
    });

    Future<void> pumpCanvas(
      WidgetTester tester, {
      Future<void> Function(List<int>)? onReorder,
      Size size = const Size(400, 800),
      ChainRouting routing = ChainRouting.none,
      List<ChainBlock>? blocks,
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SignalChainCanvas(
              chain: blocks ?? chain,
              routing: routing,
              onReorder:
                  onReorder ??
                  (blockIds) async {
                    reordered = blockIds;
                  },
              onOpenBlock: (entry) => opened = entry,
              onAddEnd: (blockType) => asked = blockType,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a drag asks for the blocks in their new signal order', (
      tester,
    ) async {
      await pumpCanvas(tester);

      await dragDownOneCard(tester, 0);

      // The wah now sits second, so the chain is asked for in that order.
      expect(reordered, [11, 10, 12]);
      expect(orderOnScreen(tester), ['Caline PureSky', 'Vox Wah', 'Slapback']);
    });

    testWidgets('a refused drag puts the chain back and says why', (
      tester,
    ) async {
      await pumpCanvas(
        tester,
        onReorder: (_) async {
          throw const AppFailure('This rig changed while you were reordering.');
        },
      );

      await dragDownOneCard(tester, 0);

      expect(
        find.text('This rig changed while you were reordering.'),
        findsOne,
      );
      // The database still has the old order, so the chain shows it again rather
      // than an arrangement that was never saved.
      expect(orderOnScreen(tester), ['Vox Wah', 'Caline PureSky', 'Slapback']);
    });

    testWidgets('tapping a card hands back the whole block', (tester) async {
      await pumpCanvas(tester);

      await tester.tap(find.text('Slapback'));
      await tester.pumpAndSettle();

      // The block and its pedal both, because what can be done with a block
      // depends on whether there is a pedal in it.
      expect(opened?.block.id, 12);
      expect(opened?.pedal, isNull);
    });

    testWidgets('a cable runs into every block but the first', (tester) async {
      await pumpCanvas(tester);

      // Three blocks, two cables: the first is fed by the guitar at the head of
      // the list rather than by a block.
      expect(find.byType(SignalChainLink), findsExactly(2));
      expect(find.byIcon(Icons.expand_more), findsExactly(2));
    });

    testWidgets('an unwired chain says nothing about paths', (tester) async {
      await pumpCanvas(tester);

      expect(find.textContaining('Feeds'), findsNothing);
      expect(find.byIcon(Icons.subdirectory_arrow_right), findsNothing);
    });

    testWidgets('a split says how many paths leave, and sets the branch in', (
      tester,
    ) async {
      // The wah feeds both the drive and the delay, the delay on the branch.
      await pumpCanvas(
        tester,
        routing: ChainRouting([
          chainCable(1, source: 10, target: 11),
          chainCable(
            2,
            source: 10,
            target: 12,
            type: SignalConnectionType.parallel,
          ),
        ]),
      );

      expect(find.text('Feeds 2 paths'), findsOne);
      expect(find.byIcon(Icons.subdirectory_arrow_right), findsOne);
      // Named, because an arrow alone cannot say which of the paths this is.
      expect(find.text('Path 2'), findsOne);
      // Set in from the path it came off, so the two read as two paths.
      expect(
        tester.getTopLeft(find.byType(SignalBlockCard).at(2)).dx,
        greaterThan(tester.getTopLeft(find.byType(SignalBlockCard).at(1)).dx),
      );
    });

    testWidgets('a guessed end offers to become a block that says more', (
      tester,
    ) async {
      await pumpCanvas(tester);

      await tester.tap(find.text('Wherever this goes'));
      await tester.pumpAndSettle();

      // An output block, which is the only thing that can then be asked where it
      // reaches. Written by the screen above rather than here.
      expect(asked, SignalBlockType.output);

      await tester.tap(find.text('Guitar'));
      await tester.pumpAndSettle();

      expect(asked, SignalBlockType.input);
    });

    testWidgets('an end the rig has answered for is neither drawn nor asked', (
      tester,
    ) async {
      await pumpCanvas(
        tester,
        blocks: [
          chainBlock(10, type: SignalBlockType.input),
          chainBlock(11, position: 1),
        ],
      );

      expect(find.text('Guitar'), findsNothing);
      expect(find.text('Wherever this goes'), findsOne);
    });

    testWidgets('a card lifts off the board while it is dragged', (
      tester,
    ) async {
      await pumpCanvas(tester);

      expect(liftedCards(tester), isEmpty);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byIcon(Icons.drag_handle).first),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.moveBy(const Offset(0, 40));
      // One frame to pick the card up, then long enough for it to finish rising.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(liftedCards(tester), isNotEmpty);

      await gesture.up();
      await tester.pumpAndSettle();

      // Put down again, so nothing is left hovering over the chain.
      expect(liftedCards(tester), isEmpty);
    });

    testWidgets('a tablet draws the chain across rather than down', (
      tester,
    ) async {
      await pumpCanvas(tester, size: const Size(1000, 700));

      // The same list either way, so the two layouts cannot drift apart.
      expect(orderOnScreen(tester), ['Vox Wah', 'Caline PureSky', 'Slapback']);
      final canvas = tester.widget<ReorderableListView>(
        find.byType(ReorderableListView),
      );
      expect(canvas.scrollDirection, Axis.horizontal);
      // The cables turn with it, rather than pointing down a row.
      expect(find.byIcon(Icons.chevron_right), findsExactly(2));
    });
  });
}
