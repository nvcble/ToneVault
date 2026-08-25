import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/core/enums/signal_connection_type.dart';
import 'package:tone_vault/features/pedalboards/data/routing_rules.dart';
import 'package:tone_vault/features/pedalboards/data/signal_graph.dart';
import '../support/chain_rows.dart';

/// Which cables a rig will take, block type by block type.
void main() {
  SignalBlock blockOf(int id, SignalBlockType type) =>
      chainBlock(id, type: type).block;

  SignalGraph graphOf(
    List<int> ids, [
    List<SignalConnection> cables = const [],
  ]) {
    return SignalGraph(blockIdsByPosition: ids, connections: cables);
  }

  String? refusal(
    SignalBlock source,
    SignalBlock target, {
    SignalGraph? graph,
  }) {
    return RoutingRules.refusalFor(
      source: source,
      target: target,
      graph: graph ?? graphOf([source.id, target.id]),
    );
  }

  group('a plain cable', () {
    test('runs from one effect to the next', () {
      expect(
        refusal(
          blockOf(10, SignalBlockType.overdrive),
          blockOf(20, SignalBlockType.delay),
        ),
        isNull,
      );
    });

    test('runs out of an input and into an output', () {
      expect(
        refusal(
          blockOf(10, SignalBlockType.input),
          blockOf(20, SignalBlockType.overdrive),
        ),
        isNull,
      );
      expect(
        refusal(
          blockOf(10, SignalBlockType.overdrive),
          blockOf(20, SignalBlockType.output),
        ),
        isNull,
      );
    });

    test('runs out of a return and into a send', () {
      // The two halves of a trip out of the rig are ordinary blocks on the way in
      // and on the way out: what they cannot do is carry on past their own edge.
      expect(
        refusal(
          blockOf(10, SignalBlockType.fxReturn),
          blockOf(20, SignalBlockType.delay),
        ),
        isNull,
      );
      expect(
        refusal(
          blockOf(10, SignalBlockType.delay),
          blockOf(20, SignalBlockType.send),
        ),
        isNull,
      );
    });
  });

  group('what the shape of the chain refuses', () {
    test('a block feeding itself', () {
      final block = blockOf(10, SignalBlockType.delay);

      expect(
        RoutingRules.refusalFor(
          source: block,
          target: block,
          graph: graphOf([10]),
        ),
        'A block cannot feed itself.',
      );
    });

    test('a cable already run', () {
      final graph = graphOf([10, 20], [chainCable(1, source: 10, target: 20)]);

      expect(
        refusal(
          blockOf(10, SignalBlockType.overdrive),
          blockOf(20, SignalBlockType.delay),
          graph: graph,
        ),
        'Those two blocks are already connected.',
      );
    });

    test('a loop back into itself', () {
      final graph = graphOf([10, 20], [chainCable(1, source: 10, target: 20)]);

      expect(
        refusal(
          blockOf(20, SignalBlockType.delay),
          blockOf(10, SignalBlockType.overdrive),
          graph: graph,
        ),
        'That would send signal back into itself.',
      );
    });
  });

  group('what the ends of the rig refuse', () {
    test('running on from an output', () {
      expect(
        refusal(
          blockOf(10, SignalBlockType.output),
          blockOf(20, SignalBlockType.reverb),
        ),
        'Signal leaves the rig at an output, so nothing on the rig follows it.',
      );
    });

    test('cabling a send on to the next block', () {
      // What comes next is an amplifier the app has never seen, so the answer is
      // the return it is paired with rather than a cable.
      expect(
        refusal(
          blockOf(10, SignalBlockType.send),
          blockOf(20, SignalBlockType.reverb),
        ),
        'A send is where signal leaves the rig, so pair it with a return rather '
        'than cabling it on.',
      );
    });

    test('feeding an input', () {
      expect(
        refusal(
          blockOf(10, SignalBlockType.reverb),
          blockOf(20, SignalBlockType.input),
        ),
        'An input is where signal starts, so nothing on the rig feeds it.',
      );
    });

    test('feeding a return', () {
      expect(
        refusal(
          blockOf(10, SignalBlockType.reverb),
          blockOf(20, SignalBlockType.fxReturn),
        ),
        'A return brings signal back from outside the rig, so nothing on the rig '
        'feeds it.',
      );
    });

    test('says the end is wrong before it says the shape is', () {
      // A cable out of an output is refused for being out of an output, not for
      // whatever loop it would have made. The first thing wrong with it is the
      // thing worth telling the user.
      final graph = graphOf([10, 20], [chainCable(1, source: 20, target: 10)]);

      expect(
        refusal(
          blockOf(10, SignalBlockType.output),
          blockOf(20, SignalBlockType.overdrive),
          graph: graph,
        ),
        startsWith('Signal leaves the rig at an output'),
      );
    });
  });

  group('a rig with three paths out of one block', () {
    test('takes every one of them', () {
      // Three at once is a rig, not a mistake: a dry line, a delay and a reverb
      // all off the same split is an ordinary ambient setup.
      final graph = graphOf(
        [10, 20, 30, 40],
        [
          chainCable(1, source: 10, target: 20),
          chainCable(
            2,
            source: 10,
            target: 30,
            type: SignalConnectionType.parallel,
          ),
        ],
      );

      expect(
        refusal(
          blockOf(10, SignalBlockType.split),
          blockOf(40, SignalBlockType.reverb),
          graph: graph,
        ),
        isNull,
      );
    });

    test('and lets them all come back to one merge', () {
      final graph = graphOf(
        [10, 20, 30, 40],
        [
          chainCable(1, source: 10, target: 20),
          chainCable(
            2,
            source: 10,
            target: 30,
            type: SignalConnectionType.parallel,
          ),
          chainCable(3, source: 20, target: 40),
        ],
      );

      expect(
        refusal(
          blockOf(30, SignalBlockType.reverb),
          blockOf(40, SignalBlockType.merge),
          graph: graph,
        ),
        isNull,
      );
    });
  });
}
