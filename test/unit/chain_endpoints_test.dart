import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/core/enums/signal_destination.dart';
import 'package:tone_vault/core/enums/signal_source.dart';
import 'package:tone_vault/features/pedalboards/data/chain_endpoints.dart';
import '../support/chain_rows.dart';

/// The questions a screen has of a rig's edges, asked block by block.
void main() {
  // A board that leaves at block 40 for the front of an amp and comes back in at
  // 50 off the amp's own send: the four cable method, as stored.
  final fourCable = ChainEndpoints([
    chainEndpoint(
      1,
      blockId: 40,
      destination: SignalDestination.physicalAmpInput,
      pairedBlockId: 50,
      gear: 'Marshall JVM',
    ),
    chainEndpoint(
      2,
      blockId: 50,
      source: SignalSource.physicalAmpFxSend,
      pairedBlockId: 40,
    ),
    chainEndpoint(3, blockId: 60, destination: SignalDestination.foh),
  ]);

  test('a rig that was never asked says nothing', () {
    expect(ChainEndpoints.none.isEmpty, isTrue);
    expect(ChainEndpoints.none.of(40), isNull);
    expect(ChainEndpoints.none.isPaired(40), isFalse);
    expect(ChainEndpoints.none.pairedBlockIds, isEmpty);
  });

  test('reads what one block reaches', () {
    expect(fourCable.of(40)!.destination, SignalDestination.physicalAmpInput);
    expect(fourCable.of(40)!.gear, 'Marshall JVM');
    expect(fourCable.of(50)!.source, SignalSource.physicalAmpFxSend);
    // A block on the board that is not an edge at all.
    expect(fourCable.of(20), isNull);
  });

  test('finds the other half of a trip out of the rig', () {
    // From either end: each half stores the pairing, so a card can answer on its
    // own without being handed the whole rig.
    expect(fourCable.pairedWith(40), 50);
    expect(fourCable.pairedWith(50), 40);
    expect(fourCable.isPaired(40), isTrue);
  });

  test('an output on its own is not half of anything', () {
    expect(fourCable.pairedWith(60), isNull);
    expect(fourCable.isPaired(60), isFalse);
  });

  test('names every block already spoken for', () {
    // What a picker leaves out when it offers a send something to pair with.
    expect(fourCable.pairedBlockIds, {40, 50});
  });

  group('what the pairing tells the chain about order', () {
    final blocks = [
      chainBlock(40, type: SignalBlockType.send).block,
      chainBlock(50, type: SignalBlockType.fxReturn, position: 1).block,
      chainBlock(60, type: SignalBlockType.output, position: 2).block,
    ];

    test('the return comes straight after the send it belongs to', () {
      // One way round only: the pair points the way signal travels, and a hint
      // both ways would be a loop.
      expect(fourCable.orderingAfter(blocks), {40: 50});
    });

    test('a rig with nothing paired says nothing about order', () {
      expect(ChainEndpoints.none.orderingAfter(blocks), isEmpty);
      expect(
        ChainEndpoints([
          chainEndpoint(1, blockId: 60, destination: SignalDestination.foh),
        ]).orderingAfter(blocks),
        isEmpty,
      );
    });
  });
}
