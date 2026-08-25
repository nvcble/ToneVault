import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/enums/signal_connection_type.dart';
import 'package:tone_vault/features/pedalboards/data/chain_routing.dart';
import '../support/chain_rows.dart';

/// The questions a screen has of a rig's cables, asked block by block.
void main() {
  // A drive that splits into a delay and a reverb, the reverb on the branch.
  final split = ChainRouting([
    chainCable(1, source: 10, target: 20),
    chainCable(2, source: 10, target: 30, type: SignalConnectionType.parallel),
  ]);

  test('a rig with no cables is not wired', () {
    expect(ChainRouting.none.isWired, isFalse);
    expect(ChainRouting.none.pathsFrom(10), 0);
  });

  test('counts the paths out of a block', () {
    expect(split.isWired, isTrue);
    expect(split.pathsFrom(10), 2);
    expect(split.pathsFrom(20), 0);
  });

  test('reads the cables at either end of a block', () {
    expect(split.from(10).map((cable) => cable.targetBlockId), [20, 30]);
    expect(split.into(30).map((cable) => cable.sourceBlockId), [10]);
    expect(split.into(10), isEmpty);
  });
}
