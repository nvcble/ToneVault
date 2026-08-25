import '../../../core/database/app_database.dart';

/// The order signal actually reaches a rig's blocks.
///
/// A rig with no connections stored runs straight through, so [order] is simply
/// the ids as they came - in position order - and this class costs nothing. Once
/// a rig has cables in it, they are what decides: [order] is a topological walk
/// of them, and position only breaks ties between blocks that are equally ready.
///
/// This is the only place that turns blocks and connections into a sequence.
/// Nothing above the data layer reads `blocks[i + 1]`, so a split feeding two
/// paths at once becomes a change here rather than a change everywhere. Ids
/// rather than rows, so ordering does not care whether the caller is holding
/// blocks alone or blocks with their pedals.
///
/// `follows` is for the one case where two blocks belong next to each other with
/// no cable between them: a send and the return it comes back through. The trip
/// in between is off the rig - through an amplifier's effects loop, most often -
/// so storing a cable there would claim the app knows what happens out there.
/// The hint only moves the reading order, and [nextOf] never reports it.
class SignalGraph {
  SignalGraph._(this.order, this._outgoing);

  factory SignalGraph({
    required List<int> blockIdsByPosition,
    required List<SignalConnection> connections,
    Map<int, int> follows = const {},
  }) {
    final outgoing = <int, List<int>>{};
    for (final connection in connections) {
      outgoing
          .putIfAbsent(connection.sourceBlockId, () => [])
          .add(connection.targetBlockId);
    }

    if (connections.isEmpty && follows.isEmpty) {
      return SignalGraph._(List.unmodifiable(blockIdsByPosition), outgoing);
    }

    // The hints join a copy, not [_outgoing]: they say where a block belongs in
    // the reading order, and nothing that asks what a block feeds should see one.
    final ordering = {
      for (final entry in outgoing.entries) entry.key: [...entry.value],
    };
    follows.forEach(
      (before, after) => ordering.putIfAbsent(before, () => []).add(after),
    );

    return SignalGraph._(_walk(blockIdsByPosition, ordering), outgoing);
  }

  /// The block ids in signal order.
  final List<int> order;

  final Map<int, List<int>> _outgoing;

  /// The blocks [blockId] feeds, which is more than one where a path splits.
  List<int> nextOf(int blockId) => List.unmodifiable(_outgoing[blockId] ?? []);

  /// Why [source] cannot feed [target], or null if it can.
  ///
  /// Worded for the user, because connecting two blocks is something they do by
  /// hand and a refusal has to say what is wrong with it.
  String? refusalFor({required int source, required int target}) {
    if (source == target) return 'A block cannot feed itself.';
    if (nextOf(source).contains(target)) {
      return 'Those two blocks are already connected.';
    }
    if (_reaches(from: target, to: source)) {
      return 'That would send signal back into itself.';
    }
    return null;
  }

  /// Whether following the cables out of [from] ever arrives at [to].
  bool _reaches({required int from, required int to}) {
    final pending = [from];
    final seen = <int>{from};

    while (pending.isNotEmpty) {
      final current = pending.removeLast();
      if (current == to) return true;
      for (final next in _outgoing[current] ?? const <int>[]) {
        if (seen.add(next)) pending.add(next);
      }
    }
    return false;
  }

  /// Kahn's algorithm: a block comes out once everything feeding it has.
  ///
  /// [ids] arrives in position order and each round is drained in that order, so
  /// the result is stable and a rig whose cables leave a choice keeps the order
  /// the user dragged. Anything still left when no block is ready is part of a
  /// cycle, which the writes refuse; it is appended rather than dropped, because
  /// a chain that silently loses a block is worse than one drawn in an odd order.
  static List<int> _walk(List<int> ids, Map<int, List<int>> outgoing) {
    final feeders = {for (final id in ids) id: 0};
    for (final targets in outgoing.values) {
      for (final target in targets) {
        if (feeders.containsKey(target)) feeders[target] = feeders[target]! + 1;
      }
    }

    final remaining = ids.toList();
    final ordered = <int>[];
    while (remaining.isNotEmpty) {
      final ready = remaining.where((id) => feeders[id] == 0).toList();
      if (ready.isEmpty) {
        ordered.addAll(remaining);
        break;
      }

      remaining.removeWhere(ready.contains);
      ordered.addAll(ready);
      for (final id in ready) {
        for (final target in outgoing[id] ?? const <int>[]) {
          if (feeders.containsKey(target)) {
            feeders[target] = feeders[target]! - 1;
          }
        }
      }
    }

    return List.unmodifiable(ordered);
  }
}
