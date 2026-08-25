import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/signal_chain_dao.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/core/enums/signal_connection_type.dart';
import 'package:tone_vault/features/pedalboards/data/chain_branches.dart';
import 'package:tone_vault/features/pedalboards/data/chain_routing.dart';
import '../support/chain_rows.dart';

/// Which path each block of a rig is on, for a list of cards to set out.
void main() {
  /// Ids 10, 20, 30... in the order signal reaches them, which is how the chain
  /// arrives from `SignalGraph`.
  List<ChainBlock> chainOf(int count) => [
    for (var i = 0; i < count; i++)
      chainBlock((i + 1) * 10, position: i, type: SignalBlockType.delay),
  ];

  Map<int, BranchPlacement> placementsFor(
    int blocks,
    List<SignalConnection> cables,
  ) {
    return branchPlacements(
      chain: chainOf(blocks),
      routing: ChainRouting(cables),
    );
  }

  test('a rig with no cables has no paths to set out', () {
    // Most rigs: one line from end to end, where nothing needs setting in.
    expect(placementsFor(3, const []), isEmpty);
  });

  test('a chain wired straight through stays on the main line', () {
    expect(
      placementsFor(3, [
        chainCable(1, source: 10, target: 20),
        chainCable(2, source: 20, target: 30),
      ]),
      isEmpty,
    );
  });

  test('a split sets its second path in, and names it', () {
    final placements = placementsFor(3, [
      chainCable(1, source: 10, target: 20),
      chainCable(
        2,
        source: 10,
        target: 30,
        type: SignalConnectionType.parallel,
      ),
    ]);

    // The first path out of a split is the one the chain carries on down; it is
    // the second that reads as a branch.
    expect(placements[20], isNull);
    expect(placements[30], (depth: 1, label: 'Path 2'));
  });

  test('three paths out of one block are three steps apart', () {
    final placements = placementsFor(4, [
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

    // Numbered by the order the cables were run, so the labels match what the
    // user did rather than the order the blocks happen to sit in.
    expect(placements[30]?.label, 'Path 2');
    expect(placements[40]?.label, 'Path 3');
  });

  test('a path carries on at the depth it started, unlabelled', () {
    final placements = placementsFor(4, [
      chainCable(1, source: 10, target: 20),
      chainCable(
        2,
        source: 10,
        target: 30,
        type: SignalConnectionType.parallel,
      ),
      chainCable(3, source: 30, target: 40),
    ]);

    // Still the same path, so it is set in the same distance and not renamed
    // halfway down.
    expect(placements[40], (depth: 1, label: null));
  });

  test('a split off a split is a step further out again', () {
    final placements = placementsFor(5, [
      chainCable(1, source: 10, target: 20),
      chainCable(
        2,
        source: 10,
        target: 30,
        type: SignalConnectionType.parallel,
      ),
      chainCable(3, source: 30, target: 40),
      chainCable(
        4,
        source: 30,
        target: 50,
        type: SignalConnectionType.parallel,
      ),
    ]);

    expect(placements[40], (depth: 1, label: null));
    expect(placements[50], (depth: 2, label: 'Path 2'));
  });

  test('where the paths come back together, so does the layout', () {
    final placements = placementsFor(4, [
      chainCable(1, source: 10, target: 20),
      chainCable(
        2,
        source: 10,
        target: 30,
        type: SignalConnectionType.parallel,
      ),
      chainCable(3, source: 20, target: 40),
      chainCable(
        4,
        source: 30,
        target: 40,
        type: SignalConnectionType.parallel,
      ),
    ]);

    // A merge is the end of the branching rather than another branch of it, so
    // it comes back out to the shallowest path that arrives.
    expect(placements[40], isNull);
  });
}
