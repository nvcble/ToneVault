import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/core/enums/signal_destination.dart';
import 'package:tone_vault/core/enums/signal_source.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/pedalboards/data/pedalboard_draft.dart';
import 'package:tone_vault/features/pedalboards/data/signal_endpoint_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import '../support/repositories.dart';

/// Saying where a rig starts and finishes, and which send comes back where.
///
/// Nothing here is written for a rig that has not been asked: a rig with no rows
/// has said nothing about its edges, which is every rig upgraded from before.
void main() {
  late AppDatabase database;
  late int rigId;
  final moment = DateTime.utc(2026, 8, 19, 12);

  Matcher failsWith(String message) => throwsA(
    isA<AppFailure>().having((failure) => failure.message, 'message', message),
  );

  Future<int> block(SignalBlockType type, {int? onRig}) {
    return signalChainRepository(
      database,
    ).addBlock(pedalboardId: onRig ?? rigId, blockType: type);
  }

  Future<List<SignalEndpoint>> edges([int? boardId]) {
    return database.signalEndpointDao.endpointsOf(boardId ?? rigId);
  }

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    rigId = await pedalboardRepository(
      database,
      clock: () => moment,
    ).createPedalboard(const PedalboardDraft(name: 'Hybrid Worship Rig'));
  });

  tearDown(() => database.close());

  test('a rig says nothing about its edges until it is asked', () async {
    await block(SignalBlockType.output);

    expect(await edges(), isEmpty);
    expect(
      (await signalEndpointRepository(
        database,
      ).watchEndpoints(rigId).first).isEmpty,
      isTrue,
    );
  });

  test('an output records where the rig goes, and what is there', () async {
    final out = await block(SignalBlockType.output);

    await signalEndpointRepository(database).describe(
      blockId: out,
      draft: const SignalEndpointDraft(
        destination: SignalDestination.foh,
        gear: 'The desk on stage left',
      ),
    );

    final edge = (await edges()).single;
    expect(edge.blockId, out);
    expect(edge.destination, SignalDestination.foh);
    expect(edge.gear, 'The desk on stage left');
    // Not a source: signal leaves here, so there is nothing to come from.
    expect(edge.source, isNull);
  });

  test('an input records what the rig begins at', () async {
    final start = await block(SignalBlockType.input);

    await signalEndpointRepository(database).describe(
      blockId: start,
      draft: const SignalEndpointDraft(source: SignalSource.guitar),
    );

    expect((await edges()).single.source, SignalSource.guitar);
  });

  test('saying it again corrects the answer rather than adding one', () async {
    final out = await block(SignalBlockType.output);
    final repository = signalEndpointRepository(database);
    await repository.describe(
      blockId: out,
      draft: const SignalEndpointDraft(destination: SignalDestination.foh),
    );

    await repository.describe(
      blockId: out,
      draft: const SignalEndpointDraft(
        destination: SignalDestination.physicalAmpInput,
        gear: 'Marshall JVM, channel 2',
      ),
    );

    final edge = (await edges()).single;
    expect(edge.destination, SignalDestination.physicalAmpInput);
    expect(edge.gear, 'Marshall JVM, channel 2');
  });

  test('a rig can end at two places at once', () async {
    // Not a field on the rig: one board feeding an amp on stage and the desk out
    // front is an ordinary night, not an exotic setup.
    final toAmp = await block(SignalBlockType.output);
    final toDesk = await block(SignalBlockType.output);
    final repository = signalEndpointRepository(database);

    await repository.describe(
      blockId: toAmp,
      draft: const SignalEndpointDraft(
        destination: SignalDestination.physicalAmpInput,
      ),
    );
    await repository.describe(
      blockId: toDesk,
      draft: const SignalEndpointDraft(destination: SignalDestination.foh),
    );

    expect(
      {for (final edge in await edges()) edge.destination},
      {SignalDestination.physicalAmpInput, SignalDestination.foh},
    );
  });

  test('blank text is stored as nothing said', () async {
    final out = await block(SignalBlockType.output);

    await signalEndpointRepository(database).describe(
      blockId: out,
      draft: const SignalEndpointDraft(
        destination: SignalDestination.foh,
        gear: '   ',
        notes: '',
      ),
    );

    final edge = (await edges()).single;
    expect(edge.gear, isNull);
    expect(edge.notes, isNull);
  });

  test('records the rig as changed when an edge is described', () async {
    final later = moment.add(const Duration(days: 2));
    final out = await block(SignalBlockType.output);

    await signalEndpointRepository(database, clock: () => later).describe(
      blockId: out,
      draft: const SignalEndpointDraft(destination: SignalDestination.foh),
    );

    expect(
      (await database.pedalboardDao.findPedalboard(rigId))!.updatedAt,
      later,
    );
  });

  group('a send and the return it comes back through', () {
    test('names each other, so either can be read on its own', () async {
      final send = await block(SignalBlockType.send);
      final back = await block(SignalBlockType.fxReturn);

      await signalEndpointRepository(
        database,
      ).pair(sendBlockId: send, returnBlockId: back);

      final pairing = {
        for (final edge in await edges()) edge.blockId: edge.pairedBlockId,
      };
      expect(pairing[send], back);
      expect(pairing[back], send);
    });

    test('is not a cable, because the signal is out of the rig', () async {
      final send = await block(SignalBlockType.send);
      final back = await block(SignalBlockType.fxReturn);

      await signalEndpointRepository(
        database,
      ).pair(sendBlockId: send, returnBlockId: back);

      // A cable here would claim the app knows what happens between the two, and
      // what happens is an amplifier the app has never seen.
      expect(await database.signalChainDao.connectionsOf(rigId), isEmpty);
    });

    test(
      'the board send goes to the amp in, the return comes off its send',
      () async {
        // The pair most easily muddled, and the reason each half stores its own
        // socket rather than sharing one.
        final send = await block(SignalBlockType.send);
        final back = await block(SignalBlockType.fxReturn);
        final repository = signalEndpointRepository(database);

        await repository.describe(
          blockId: send,
          draft: const SignalEndpointDraft(
            destination: SignalDestination.physicalAmpInput,
            gear: 'Marshall JVM',
          ),
        );
        await repository.describe(
          blockId: back,
          draft: const SignalEndpointDraft(
            source: SignalSource.physicalAmpFxSend,
          ),
        );
        await repository.pair(sendBlockId: send, returnBlockId: back);

        final edges_ = {for (final edge in await edges()) edge.blockId: edge};
        expect(edges_[send]!.destination, SignalDestination.physicalAmpInput);
        expect(edges_[back]!.source, SignalSource.physicalAmpFxSend);
        // Pairing does not disturb what either one said it reaches.
        expect(edges_[send]!.gear, 'Marshall JVM');
      },
    );

    test('pairing again moves the send rather than leaving two', () async {
      final send = await block(SignalBlockType.send);
      final first = await block(SignalBlockType.fxReturn);
      final second = await block(SignalBlockType.fxReturn);
      final repository = signalEndpointRepository(database);
      await repository.pair(sendBlockId: send, returnBlockId: first);

      await repository.pair(sendBlockId: send, returnBlockId: second);

      final pairing = {
        for (final edge in await edges()) edge.blockId: edge.pairedBlockId,
      };
      expect(pairing[send], second);
      expect(pairing[second], send);
      // A block cannot be in two loops at once, so the first one is let go.
      expect(pairing[first], isNull);
    });

    test('separating them leaves both blocks on the rig', () async {
      final send = await block(SignalBlockType.send);
      final back = await block(SignalBlockType.fxReturn);
      final repository = signalEndpointRepository(database);
      await repository.pair(sendBlockId: send, returnBlockId: back);

      await repository.unpair(send);

      expect(
        (await edges()).every((edge) => edge.pairedBlockId == null),
        isTrue,
      );
      expect(await database.signalChainDao.blocksOf(rigId), hasLength(2));
    });

    test('losing the return leaves a send with nothing coming back', () async {
      final send = await block(SignalBlockType.send);
      final back = await block(SignalBlockType.fxReturn);
      final repository = signalEndpointRepository(database);
      await repository.describe(
        blockId: send,
        draft: const SignalEndpointDraft(
          destination: SignalDestination.physicalAmpInput,
        ),
      );
      await repository.pair(sendBlockId: send, returnBlockId: back);

      await signalChainRepository(database).removeBlock(back);

      // The send still exists and still says where it goes: half a pair is an
      // ordinary thing to have while a rig is being worked out.
      final edge = (await edges()).single;
      expect(edge.blockId, send);
      expect(edge.pairedBlockId, isNull);
      expect(edge.destination, SignalDestination.physicalAmpInput);
    });
  });

  group('what it refuses', () {
    test('describing a block that is no longer there', () async {
      expect(
        signalEndpointRepository(database).describe(
          blockId: 404,
          draft: const SignalEndpointDraft(destination: SignalDestination.foh),
        ),
        failsWith('That block is no longer on this rig.'),
      );
    });

    test('a reverb claiming to be where the rig ends', () async {
      final verb = await block(SignalBlockType.reverb);

      expect(
        signalEndpointRepository(database).describe(
          blockId: verb,
          draft: const SignalEndpointDraft(destination: SignalDestination.foh),
        ),
        failsWith(
          'Only an input, output, send or return says where signal comes from '
          'or goes to.',
        ),
      );
    });

    test('an output fed from somewhere rather than going somewhere', () async {
      final out = await block(SignalBlockType.output);

      expect(
        signalEndpointRepository(database).describe(
          blockId: out,
          draft: const SignalEndpointDraft(source: SignalSource.guitar),
        ),
        failsWith(
          'Output is where signal leaves, so it needs somewhere to go rather '
          'than somewhere to come from.',
        ),
      );
    });

    test('pairing a return with a return', () async {
      final back = await block(SignalBlockType.fxReturn);
      final other = await block(SignalBlockType.fxReturn);

      expect(
        signalEndpointRepository(
          database,
        ).pair(sendBlockId: back, returnBlockId: other),
        failsWith('Only a send or an output goes out of the rig.'),
      );
    });

    test('pairing a send with an overdrive', () async {
      final send = await block(SignalBlockType.send);
      final drive = await block(SignalBlockType.overdrive);

      expect(
        signalEndpointRepository(
          database,
        ).pair(sendBlockId: send, returnBlockId: drive),
        failsWith('Only a return or an input brings signal back in.'),
      );
    });

    test('pairing across two rigs', () async {
      final otherRigId = await pedalboardRepository(
        database,
      ).createPedalboard(const PedalboardDraft(name: 'Home Practice'));
      final send = await block(SignalBlockType.send);
      final back = await block(SignalBlockType.fxReturn, onRig: otherRigId);

      expect(
        signalEndpointRepository(
          database,
        ).pair(sendBlockId: send, returnBlockId: back),
        failsWith('Those two blocks are on different rigs.'),
      );
    });
  });

  group('what an edge does not outlive', () {
    test('taking the block off the rig', () async {
      final out = await block(SignalBlockType.output);
      await signalEndpointRepository(database).describe(
        blockId: out,
        draft: const SignalEndpointDraft(destination: SignalDestination.foh),
      );

      await signalChainRepository(database).removeBlock(out);

      expect(await edges(), isEmpty);
    });

    test('deleting the rig', () async {
      final out = await block(SignalBlockType.output);
      await signalEndpointRepository(database).describe(
        blockId: out,
        draft: const SignalEndpointDraft(destination: SignalDestination.foh),
      );

      await pedalboardRepository(database).deletePedalboard(rigId);

      expect(await edges(), isEmpty);
    });

    test('but the pedal in the block is never one of them', () async {
      // A send can be a pedal on the board - a loop switcher, a line selector -
      // and describing where it goes is not a claim on the pedal itself.
      final pedalId = await pedalRepository(database).createPedal(
        const PedalDraft(
          name: 'Line Selector',
          type: PedalType.analog,
          category: PedalCategory.utility,
        ),
      );
      final send = await signalChainRepository(database).addBlock(
        pedalboardId: rigId,
        blockType: SignalBlockType.send,
        pedalId: pedalId,
      );
      await signalEndpointRepository(database).describe(
        blockId: send,
        draft: const SignalEndpointDraft(
          destination: SignalDestination.physicalAmpInput,
        ),
      );

      await signalChainRepository(database).removeBlock(send);

      expect(await edges(), isEmpty);
      expect(
        (await database.pedalDao.findPedal(pedalId))!.name,
        'Line Selector',
      );
    });
  });
}
