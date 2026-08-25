import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/daos/signal_chain_dao.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/core/enums/signal_connection_type.dart';
import 'package:tone_vault/features/pedalboards/data/chain_endpoints.dart';
import 'package:tone_vault/features/pedalboards/data/chain_routing.dart';
import 'package:tone_vault/features/pedalboards/data/routing_advice.dart';
import '../support/chain_rows.dart';

/// What a rig's wiring is worth mentioning for, none of which stops a write.
void main() {
  List<String> adviceOn(
    List<ChainBlock> chain, {
    ChainRouting routing = ChainRouting.none,
    ChainEndpoints endpoints = ChainEndpoints.none,
  }) {
    return [
      for (final note in routingAdvice(
        chain: chain,
        routing: routing,
        endpoints: endpoints,
      ))
        note.message,
    ];
  }

  test('a chain running straight through has nothing to say', () {
    final chain = [
      chainBlock(10),
      chainBlock(20, type: SignalBlockType.delay, position: 1),
      chainBlock(30, type: SignalBlockType.output, position: 2),
    ];

    // No cables at all, so signal reaches every block in position order and
    // there is nothing odd about any of it.
    expect(adviceOn(chain), isEmpty);
  });

  test('a split and a merge wired properly has nothing to say either', () {
    final chain = [
      chainBlock(10, type: SignalBlockType.split),
      chainBlock(20, type: SignalBlockType.delay, position: 1),
      chainBlock(30, type: SignalBlockType.reverb, position: 2),
      chainBlock(40, type: SignalBlockType.merge, position: 3),
    ];
    final routing = ChainRouting([
      chainCable(1, source: 10, target: 20),
      chainCable(
        2,
        source: 10,
        target: 30,
        type: SignalConnectionType.parallel,
      ),
      chainCable(3, source: 20, target: 40),
      chainCable(4, source: 30, target: 40),
    ]);

    expect(adviceOn(chain, routing: routing), isEmpty);
  });

  test('mentions a block nothing has been cabled to', () {
    final chain = [
      chainBlock(10),
      chainBlock(20, type: SignalBlockType.delay, position: 1),
      chainBlock(30, label: 'Big Sky', type: SignalBlockType.reverb),
    ];

    // Once a rig is wired, a block with no cable into it is not simply next in
    // line: signal never gets there.
    expect(
      adviceOn(
        chain,
        routing: ChainRouting([chainCable(1, source: 10, target: 20)]),
      ),
      contains('Nothing feeds Big Sky yet.'),
    );
  });

  test('does not say that about the block signal starts at', () {
    final chain = [
      chainBlock(10, label: 'Screamer'),
      chainBlock(20, type: SignalBlockType.delay, position: 1),
    ];

    expect(
      adviceOn(
        chain,
        routing: ChainRouting([chainCable(1, source: 10, target: 20)]),
      ),
      isNot(contains('Nothing feeds Screamer yet.')),
    );
  });

  test('mentions a block that feeds nothing', () {
    final chain = [
      chainBlock(10),
      chainBlock(20, label: 'Timeline', type: SignalBlockType.delay),
      chainBlock(30, type: SignalBlockType.reverb, position: 2),
    ];

    expect(
      adviceOn(
        chain,
        routing: ChainRouting([chainCable(1, source: 10, target: 20)]),
      ),
      contains('Timeline does not feed anything yet.'),
    );
  });

  test('but an output is meant to be the last thing', () {
    final chain = [
      chainBlock(10),
      chainBlock(20, label: 'To the desk', type: SignalBlockType.output),
    ];

    // An output feeding nothing is the point of it, and a send is the same: what
    // follows either one is not on the rig.
    expect(
      adviceOn(
        chain,
        routing: ChainRouting([chainCable(1, source: 10, target: 20)]),
      ),
      isNot(contains('To the desk does not feed anything yet.')),
    );
  });

  test('mentions a split with only one path out of it', () {
    final chain = [
      chainBlock(10, label: 'Y cable', type: SignalBlockType.split),
      chainBlock(20, type: SignalBlockType.delay, position: 1),
    ];

    expect(
      adviceOn(
        chain,
        routing: ChainRouting([chainCable(1, source: 10, target: 20)]),
      ),
      contains('Y cable is a split, but only one path leaves it.'),
    );
  });

  test('mentions a merge with only one path into it', () {
    final chain = [
      chainBlock(10, type: SignalBlockType.delay),
      chainBlock(20, label: 'Mixer', type: SignalBlockType.merge),
    ];

    expect(
      adviceOn(
        chain,
        routing: ChainRouting([chainCable(1, source: 10, target: 20)]),
      ),
      contains('Mixer is a merge, but only one path arrives at it.'),
    );
  });

  test('mentions paths that never come back together', () {
    final chain = [
      chainBlock(10, label: 'Splitter', type: SignalBlockType.split),
      chainBlock(20, type: SignalBlockType.delay, position: 1),
      chainBlock(30, type: SignalBlockType.reverb, position: 2),
    ];
    final routing = ChainRouting([
      chainCable(1, source: 10, target: 20),
      chainCable(
        2,
        source: 10,
        target: 30,
        type: SignalConnectionType.parallel,
      ),
    ]);

    // Not wrong: two amps on stage is a rig. Worth saying, because a user who
    // meant to blend them back together has not yet.
    expect(
      adviceOn(chain, routing: routing),
      contains(
        'The 2 paths out of Splitter never come back together, so they reach '
        'the end of the rig separately.',
      ),
    );
  });

  test('counts three paths as three', () {
    final chain = [
      chainBlock(10, label: 'Splitter', type: SignalBlockType.split),
      chainBlock(20, type: SignalBlockType.delay, position: 1),
      chainBlock(30, type: SignalBlockType.reverb, position: 2),
      chainBlock(40, type: SignalBlockType.eq, position: 3),
    ];
    final routing = ChainRouting([
      chainCable(1, source: 10, target: 20),
      chainCable(
        2,
        source: 10,
        target: 30,
        type: SignalConnectionType.parallel,
      ),
      chainCable(
        3,
        source: 10,
        target: 40,
        type: SignalConnectionType.parallel,
      ),
    ]);

    expect(
      adviceOn(chain, routing: routing),
      contains(startsWith('The 3 paths out of Splitter')),
    );
  });

  group('a send waiting for its return', () {
    test('is mentioned while nothing is paired with it', () {
      final chain = [
        chainBlock(10, label: 'To the amp', type: SignalBlockType.send),
      ];

      expect(
        adviceOn(chain),
        contains(
          'To the amp has no return paired with it, so nothing says where '
          'signal comes back in.',
        ),
      );
    });

    test('and is not once one is', () {
      final chain = [
        chainBlock(10, label: 'To the amp', type: SignalBlockType.send),
        chainBlock(20, type: SignalBlockType.fxReturn, position: 1),
      ];
      final endpoints = ChainEndpoints([
        chainEndpoint(1, blockId: 10, pairedBlockId: 20),
        chainEndpoint(2, blockId: 20, pairedBlockId: 10),
      ]);

      expect(adviceOn(chain, endpoints: endpoints), isEmpty);
    });
  });
}
