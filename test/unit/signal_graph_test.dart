import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/signal_connection_type.dart';
import 'package:tone_vault/features/pedalboards/data/signal_graph.dart';

/// The order signal reaches a rig's blocks, and what cannot be cabled to what.
///
/// Ids alone, because this is the one place that turns blocks and cables into a
/// sequence and it deliberately does not care what is in them.
void main() {
  SignalConnection cable(int source, int target) {
    return SignalConnection(
      id: source * 100 + target,
      pedalboardId: 4,
      sourceBlockId: source,
      targetBlockId: target,
      connectionType: SignalConnectionType.series,
    );
  }

  SignalGraph graph(List<int> ids, [List<SignalConnection> cables = const []]) {
    return SignalGraph(blockIdsByPosition: ids, connections: cables);
  }

  test('a rig with no cables runs in the order it was dragged into', () {
    // Every rig today: nothing is stored, and position is the whole answer.
    expect(graph([3, 1, 2]).order, [3, 1, 2]);
    expect(graph([]).order, isEmpty);
  });

  test('cables decide the order, not position', () {
    // Laid out reverb, drive, tuner; cabled tuner into drive into reverb.
    final signal = graph([3, 2, 1], [cable(1, 2), cable(2, 3)]);

    expect(signal.order, [1, 2, 3]);
  });

  test('position breaks ties between blocks that are equally ready', () {
    // Both 2 and 3 are fed by 1, so neither is more ready than the other and the
    // order the user left them in stands.
    expect(graph([1, 2, 3], [cable(1, 3), cable(1, 2)]).order, [1, 2, 3]);
    expect(graph([1, 3, 2], [cable(1, 3), cable(1, 2)]).order, [1, 3, 2]);
  });

  test('a block feeding two paths says so', () {
    final signal = graph([1, 2, 3], [cable(1, 2), cable(1, 3)]);

    expect(signal.nextOf(1), [2, 3]);
    expect(signal.nextOf(3), isEmpty);
    expect(signal.nextOf(404), isEmpty);
  });

  test('a loop keeps its blocks rather than dropping them', () {
    // The writes refuse a loop, so this is a rig edited into one by hand or a
    // file restored from one. Drawn in an odd order beats drawn short.
    final signal = graph([1, 2, 3], [cable(1, 2), cable(2, 3), cable(3, 2)]);

    expect(signal.order, containsAll([1, 2, 3]));
    expect(signal.order.first, 1);
    expect(signal.order, hasLength(3));
  });

  test('a cable to a block that is not on the rig is ignored', () {
    // Only the rig's own blocks are ordered; an id from elsewhere cannot hold
    // one of them back.
    expect(graph([1, 2], [cable(404, 1), cable(1, 2)]).order, [1, 2]);
  });

  group('a send paired with a return, which has no cable between them', () {
    // The four cable method: the board runs into a send at 2, the amplifier's own
    // loop takes it away, and it arrives back at the return at 3.
    final cables = [cable(1, 2), cable(3, 4), cable(4, 5)];

    test('reads the pair one after the other rather than in position order', () {
      // Laid out drive, send, return, delay, output. Without the hint nothing
      // feeds the return, so it comes out level with the send and the order the
      // user patched is lost.
      final loose = graph([1, 2, 3, 4, 5], cables);
      expect(loose.order, [1, 3, 2, 4, 5]);

      final paired = SignalGraph(
        blockIdsByPosition: [1, 2, 3, 4, 5],
        connections: cables,
        follows: const {2: 3},
      );
      expect(paired.order, [1, 2, 3, 4, 5]);
    });

    test('but the pair is never reported as a cable', () {
      final paired = SignalGraph(
        blockIdsByPosition: [1, 2, 3, 4, 5],
        connections: cables,
        follows: const {2: 3},
      );

      // What happens between the two is an amplifier the app has never seen, so
      // nothing that asks what a block feeds is told there is a cable there.
      expect(paired.nextOf(2), isEmpty);
      expect(paired.refusalFor(source: 3, target: 2), isNull);
    });

    test('orders a rig that has no cables at all yet', () {
      // A send and a return dropped on a bare rig and paired straight away: there
      // is nothing else to go on, so the hint is the whole answer.
      final paired = SignalGraph(
        blockIdsByPosition: [3, 2],
        connections: const [],
        follows: const {2: 3},
      );

      expect(paired.order, [2, 3]);
    });
  });

  group('what cannot be cabled', () {
    test('a block cannot feed itself', () {
      expect(
        graph([1, 2]).refusalFor(source: 1, target: 1),
        'A block cannot feed itself.',
      );
    });

    test('the same pair cannot be cabled twice', () {
      expect(
        graph([1, 2], [cable(1, 2)]).refusalFor(source: 1, target: 2),
        'Those two blocks are already connected.',
      );
    });

    test('signal cannot be sent back into itself', () {
      // Not just the pair either way round: anywhere downstream counts, however
      // far along the chain it is.
      final signal = graph([1, 2, 3], [cable(1, 2), cable(2, 3)]);

      expect(
        signal.refusalFor(source: 2, target: 1),
        'That would send signal back into itself.',
      );
      expect(
        signal.refusalFor(source: 3, target: 1),
        'That would send signal back into itself.',
      );
    });

    test('a cable that leaves it a chain is allowed', () {
      final signal = graph([1, 2, 3], [cable(1, 2)]);

      expect(signal.refusalFor(source: 2, target: 3), isNull);
      // A second path out of the same block is a split, which is the point.
      expect(signal.refusalFor(source: 1, target: 3), isNull);
    });
  });
}
