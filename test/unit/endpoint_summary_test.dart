import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/daos/signal_chain_dao.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/core/enums/signal_destination.dart';
import 'package:tone_vault/core/enums/signal_source.dart';
import 'package:tone_vault/features/pedalboards/data/chain_endpoints.dart';
import 'package:tone_vault/features/pedalboards/data/endpoint_summary.dart';
import '../support/chain_rows.dart';

/// The one line a card reads for an edge of a rig.
void main() {
  final chain = <ChainBlock>[
    chainBlock(10, label: 'To the amp', type: SignalBlockType.send),
    chainBlock(20, type: SignalBlockType.fxReturn, position: 1),
    chainBlock(30, type: SignalBlockType.delay, position: 2),
    chainBlock(40, type: SignalBlockType.output, position: 3),
  ];

  Map<int, String> summaries(ChainEndpoints endpoints) =>
      endpointSummaries(chain: chain, endpoints: endpoints);

  test('a rig that was never asked has nothing to show', () {
    expect(summaries(ChainEndpoints.none), isEmpty);
  });

  test('says where signal goes, and what is at the other end', () {
    final lines = summaries(
      ChainEndpoints([
        chainEndpoint(
          1,
          blockId: 40,
          destination: SignalDestination.foh,
          gear: 'Behringer X32',
        ),
      ]),
    );

    expect(lines, {40: 'To Front of house · Behringer X32'});
  });

  test('what is at the other end is left out when it was not said', () {
    final lines = summaries(
      ChainEndpoints([
        chainEndpoint(1, blockId: 40, destination: SignalDestination.foh),
      ]),
    );

    expect(lines[40], 'To Front of house');
  });

  test('the two halves of a loop each say their own side of it', () {
    // The board leaves at the send for the front of the amp, and comes back at the
    // return off the amp's own send. Two different sockets, said in both places.
    final lines = summaries(
      ChainEndpoints([
        chainEndpoint(
          1,
          blockId: 10,
          destination: SignalDestination.physicalAmpInput,
          pairedBlockId: 20,
          gear: 'Marshall JVM',
        ),
        chainEndpoint(
          2,
          blockId: 20,
          source: SignalSource.physicalAmpFxSend,
          pairedBlockId: 10,
        ),
      ]),
    );

    expect(lines[10], 'To Amp input · Marshall JVM · back in at Return');
    expect(lines[20], 'From Amp FX send · sent out at To the amp');
  });

  test('a block in the middle of the chain says nothing', () {
    final lines = summaries(
      ChainEndpoints([
        chainEndpoint(1, blockId: 40, destination: SignalDestination.foh),
      ]),
    );

    expect(lines.containsKey(30), isFalse);
  });

  test('a row with nothing filled in yet is left out too', () {
    // Half a pairing can exist before either half has been described, and an empty
    // line under a card would read as something having gone wrong.
    expect(summaries(ChainEndpoints([chainEndpoint(1, blockId: 40)])), isEmpty);
  });
}
