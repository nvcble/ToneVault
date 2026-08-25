import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/daos/signal_chain_dao.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/core/enums/signal_destination.dart';
import 'package:tone_vault/features/pedalboards/data/chain_endpoints.dart';
import 'package:tone_vault/features/pedalboards/data/endpoint_choices.dart';
import '../support/chain_rows.dart';

/// What the sheets offer for one edge of a rig: where it can reach, and what a
/// send can come back through.
void main() {
  group('where signal can leave a rig', () {
    test('every destination is offered exactly once', () {
      // A destination added later and not grouped would be unreachable on screen,
      // which is the kind of gap nothing else would catch.
      final offered = [
        for (final group in destinationGroups) ...group.destinations,
      ];

      expect(offered, unorderedEquals(SignalDestination.values));
      expect(offered.toSet(), hasLength(offered.length));
    });

    test('the two amplifier sockets sit together under one heading', () {
      // The pair most easily muddled: the front of the amp and the far side of its
      // effects loop are different sockets and never interchangeable.
      final amp = destinationGroups.first;

      expect(amp.heading, 'An amplifier');
      expect(amp.destinations, [
        SignalDestination.physicalAmpInput,
        SignalDestination.physicalAmpFxReturn,
      ]);
    });
  });

  group('what a send can come back through', () {
    final chain = <ChainBlock>[
      chainBlock(10, type: SignalBlockType.send),
      chainBlock(20, type: SignalBlockType.fxReturn, position: 1),
      chainBlock(30, type: SignalBlockType.delay, position: 2),
      chainBlock(40, type: SignalBlockType.fxReturn, position: 3),
      chainBlock(50, type: SignalBlockType.send, position: 4),
    ];

    List<PairCandidate> candidatesFor(
      int sendBlockId, {
      ChainEndpoints endpoints = ChainEndpoints.none,
    }) {
      return pairCandidates(
        chain: chain,
        endpoints: endpoints,
        sendBlockId: sendBlockId,
      );
    }

    test('only the blocks that take signal back in', () {
      // Not the delay, which is in the middle of the chain, and not the other
      // send, which is another way out rather than a way back.
      expect(candidatesFor(10).map((c) => c.block.block.id), [20, 40]);
      expect(candidatesFor(10).every((c) => !c.isTaken), isTrue);
    });

    test('one already in another pair is offered, marked', () {
      // Left in rather than hidden, so a user rearranging their loops can see
      // where the return they were after has gone.
      final endpoints = ChainEndpoints([
        chainEndpoint(1, blockId: 50, pairedBlockId: 20),
        chainEndpoint(2, blockId: 20, pairedBlockId: 50),
      ]);

      expect(
        {
          for (final candidate in candidatesFor(10, endpoints: endpoints))
            candidate.block.block.id: candidate.isTaken,
        },
        {20: true, 40: false},
      );
    });

    test('the return this send already uses is not marked as taken', () {
      final endpoints = ChainEndpoints([
        chainEndpoint(1, blockId: 10, pairedBlockId: 20),
        chainEndpoint(2, blockId: 20, pairedBlockId: 10),
      ]);

      expect(candidatesFor(10, endpoints: endpoints).first.isTaken, isFalse);
    });
  });
}
