import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/daos/signal_chain_dao.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/features/pedalboards/data/block_cable_choices.dart';
import 'package:tone_vault/features/pedalboards/data/chain_routing.dart';
import '../support/chain_rows.dart';

/// What the cables sheet offers for one block: what it already feeds, and what
/// is left to feed.
void main() {
  final drive = chainBlock(10);
  final delay = chainBlock(20, type: SignalBlockType.delay, position: 1);
  final verb = chainBlock(30, type: SignalBlockType.reverb, position: 2);
  final chain = <ChainBlock>[drive, delay, verb];

  CableChoices choicesFor(int sourceBlockId, {ChainRouting? routing}) {
    return cableChoices(
      chain: chain,
      routing: routing ?? ChainRouting.none,
      sourceBlockId: sourceBlockId,
    );
  }

  test('an unwired block can feed anything else on the rig', () {
    final choices = choicesFor(10);

    expect(choices.feeds, isEmpty);
    expect(choices.candidates.map((c) => c.block.block.id), [20, 30]);
    expect(choices.candidates.every((c) => c.refusal == null), isTrue);
  });

  test('a block is never offered a cable to itself', () {
    expect(choicesFor(20).candidates.map((c) => c.block.block.id), [10, 30]);
  });

  test('what it already feeds is listed once, not offered again', () {
    final choices = choicesFor(
      10,
      routing: ChainRouting([chainCable(1, source: 10, target: 20)]),
    );

    expect(choices.feeds.map((feed) => feed.target.block.id), [20]);
    expect(choices.feeds.single.cable.id, 1);
    expect(choices.candidates.map((c) => c.block.block.id), [30]);
  });

  test('a cable that would loop is offered with its reason', () {
    // Greyed rather than missing: a block that has quietly vanished from the
    // list is harder to make sense of than one that says why.
    final choices = choicesFor(
      20,
      routing: ChainRouting([chainCable(1, source: 10, target: 20)]),
    );

    final back = choices.candidates.firstWhere((c) => c.block.block.id == 10);
    expect(back.refusal, 'That would send signal back into itself.');
    expect(
      choices.candidates.firstWhere((c) => c.block.block.id == 30).refusal,
      isNull,
    );
  });

  test('an output is offered nothing to feed, and says so', () {
    final ends = <ChainBlock>[
      drive,
      chainBlock(20, type: SignalBlockType.output, position: 1),
      chainBlock(30, type: SignalBlockType.input, position: 2),
    ];

    final choices = cableChoices(
      chain: ends,
      routing: ChainRouting.none,
      sourceBlockId: 20,
    );

    // Every candidate carries the same reason, because the trouble is the block
    // the cable would come out of rather than the one it would go to.
    expect(
      choices.candidates.map((c) => c.refusal),
      everyElement(startsWith('Signal leaves the rig at an output')),
    );
  });

  test('an input is never offered as somewhere to send signal', () {
    final ends = <ChainBlock>[
      drive,
      chainBlock(20, type: SignalBlockType.input, position: 1),
    ];

    final choices = cableChoices(
      chain: ends,
      routing: ChainRouting.none,
      sourceBlockId: 10,
    );

    expect(
      choices.candidates.single.refusal,
      'An input is where signal starts, so nothing on the rig feeds it.',
    );
  });

  test('a cable to a block that has gone is left out of the feeds', () {
    final choices = choicesFor(
      10,
      routing: ChainRouting([chainCable(1, source: 10, target: 404)]),
    );

    expect(choices.feeds, isEmpty);
  });

  group('what joins up at a merge', () {
    final joined = <ChainBlock>[
      drive,
      delay,
      verb,
      chainBlock(40, type: SignalBlockType.merge, position: 3),
    ];

    MergeChoices joining({ChainRouting? routing}) {
      return mergeChoices(
        chain: joined,
        routing: routing ?? ChainRouting.none,
        mergeBlockId: 40,
      );
    }

    test('nothing has joined yet, and anything else on the rig could', () {
      final choices = joining();

      expect(choices.arrivals, isEmpty);
      expect(choices.candidates.map((c) => c.block.block.id), [10, 20, 30]);
    });

    test('a path already arriving is listed once, not offered again', () {
      final choices = joining(
        routing: ChainRouting([chainCable(1, source: 20, target: 40)]),
      );

      // Named from the merge's point of view: what arrives is a block, not a
      // block this one feeds.
      expect(choices.arrivals.single.source.block.id, 20);
      expect(choices.arrivals.single.cable.id, 1);
      expect(choices.candidates.map((c) => c.block.block.id), [10, 30]);
    });

    test('a path that could not reach it says why, from the far end', () {
      final choices = mergeChoices(
        chain: [
          drive,
          chainBlock(20, type: SignalBlockType.output, position: 1),
        ],
        routing: ChainRouting.none,
        mergeBlockId: 10,
      );

      // The refusal belongs to the block the cable would leave, which is the one
      // being offered here.
      expect(
        choices.candidates.single.refusal,
        startsWith('Signal leaves the rig at an output'),
      );
    });
  });
}
