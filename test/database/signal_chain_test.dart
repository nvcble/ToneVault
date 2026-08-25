import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/pedalboards/data/pedalboard_draft.dart';
import 'package:tone_vault/features/pedalboards/data/signal_block_draft.dart';
import 'package:tone_vault/features/pedalboards/data/signal_block_validator.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import '../support/repositories.dart';

/// Building a rig's signal chain: what goes on it, what is in each block, in what
/// order signal reaches them, and what happens to the order when one comes off.
void main() {
  late AppDatabase database;
  late int rigId;
  final moment = DateTime.utc(2026, 8, 19, 12);

  /// A refusal the user can read, rather than a raw driver exception.
  Matcher failsWith(String message) => throwsA(
    isA<AppFailure>().having((failure) => failure.message, 'message', message),
  );

  Future<int> addPedal(String name) {
    return pedalRepository(database).createPedal(
      PedalDraft(
        name: name,
        type: PedalType.analog,
        category: PedalCategory.overdrive,
      ),
    );
  }

  Future<int> block({
    SignalBlockType type = SignalBlockType.overdrive,
    int? pedalId,
    String? label,
    int? onRig,
    DateTime? at,
  }) {
    return signalChainRepository(
      database,
      clock: at == null ? null : () => at,
    ).addBlock(
      pedalboardId: onRig ?? rigId,
      blockType: type,
      pedalId: pedalId,
      label: label,
    );
  }

  /// The chain as the screen reads it: what each block holds, in signal order.
  Future<List<String>> chain([int? boardId]) async {
    final blocks = await signalChainRepository(
      database,
    ).watchChain(boardId ?? rigId).first;
    return [
      for (final entry in blocks)
        entry.pedal?.name ?? entry.block.label ?? entry.block.blockType.label,
    ];
  }

  Future<List<int>> positions() async {
    final blocks = await database.signalChainDao.blocksOf(rigId);
    return [for (final block in blocks) block.position];
  }

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    rigId = await pedalboardRepository(
      database,
      clock: () => moment,
    ).createPedalboard(const PedalboardDraft(name: 'Hybrid Worship Rig'));
  });

  tearDown(() => database.close());

  test('adds blocks to the end, in the order signal runs', () async {
    await block(type: SignalBlockType.tuner);
    await block();
    await block(type: SignalBlockType.reverb);

    expect(await chain(), ['Tuner', 'Overdrive', 'Reverb']);
    expect(await positions(), [0, 1, 2]);
  });

  test('what the rig is fed from goes to the front, not the end', () async {
    await block(type: SignalBlockType.tuner);
    await block();

    await signalChainRepository(database).addBlock(
      pedalboardId: rigId,
      blockType: SignalBlockType.input,
      atStart: true,
    );

    // Signal arriving halfway down a chain would read as a mistake rather than
    // as an arrangement waiting to be tidied.
    expect(await chain(), ['Input', 'Tuner', 'Overdrive']);
    expect(await positions(), [0, 1, 2]);
  });

  test('a block can be laid out with nothing in it yet', () async {
    // The whole point of a block: a rig is designed before it is bought, and
    // "a delay goes here" is a complete thing to have said.
    final blockId = await block(type: SignalBlockType.delay, label: 'Slapback');

    final stored = await database.signalChainDao.findBlock(blockId);
    expect(stored!.pedalId, isNull);
    expect(stored.label, 'Slapback');
    expect(stored.isEnabled, isTrue);
    expect(await chain(), ['Slapback']);
  });

  test('records the rig as changed when its chain changes', () async {
    final later = moment.add(const Duration(days: 2));

    await block(at: later);

    final rig = (await database.pedalboardDao.findPedalboard(rigId))!;
    expect(rig.updatedAt, later);
    expect(rig.createdAt, moment);
  });

  test('says so when the rig or the pedal is already gone', () async {
    expect(block(onRig: 404), failsWith('That rig no longer exists.'));
    expect(block(pedalId: 404), failsWith('That pedal no longer exists.'));
  });

  group('putting a pedal in a block', () {
    test('changes the block and nothing about the pedal', () async {
      final pedalId = await addPedal('Caline PureSky');
      final blockId = await block();
      final pedalBefore = await database.pedalDao.findPedal(pedalId);

      await signalChainRepository(
        database,
      ).assignPedal(blockId: blockId, pedalId: pedalId);

      expect((await database.signalChainDao.findBlock(blockId))!.pedalId, 1);
      expect(await database.pedalDao.findPedal(pedalId), pedalBefore);
    });

    test('emptying it leaves the block on the rig', () async {
      final pedalId = await addPedal('Caline PureSky');
      final blockId = await block(pedalId: pedalId);

      await signalChainRepository(
        database,
      ).assignPedal(blockId: blockId, pedalId: null);

      final stored = await database.signalChainDao.findBlock(blockId);
      expect(stored!.pedalId, isNull);
      expect(stored.position, 0);
    });

    test('refuses a pedal already elsewhere on the rig, naming both', () async {
      final pedalId = await addPedal('Boss TU-3');
      await block(pedalId: pedalId);
      final second = await block(type: SignalBlockType.delay);

      expect(
        signalChainRepository(
          database,
        ).assignPedal(blockId: second, pedalId: pedalId),
        failsWith('Boss TU-3 is already on Hybrid Worship Rig.'),
      );
    });

    test('the same pedal can be on two different rigs', () async {
      final pedalId = await addPedal('Boss TU-3');
      final secondRigId = await pedalboardRepository(
        database,
      ).createPedalboard(const PedalboardDraft(name: 'Home Practice'));

      await block(pedalId: pedalId);
      await block(pedalId: pedalId, onRig: secondRigId);

      expect(await chain(), ['Boss TU-3']);
      expect(await chain(secondRigId), ['Boss TU-3']);
    });

    test('says so when the block is no longer there', () async {
      expect(
        signalChainRepository(
          database,
        ).assignPedal(blockId: 404, pedalId: null),
        failsWith('That block is no longer on this rig.'),
      );
    });
  });

  group('editing a block', () {
    test('changes what it is, what it is called and what is noted', () async {
      final blockId = await block();

      await signalChainRepository(database).editBlock(
        blockId: blockId,
        draft: const SignalBlockDraft(
          blockType: SignalBlockType.delay,
          label: '  Slapback ',
          notes: ' Dotted eighths ',
          isEnabled: false,
        ),
      );

      final stored = (await database.signalChainDao.findBlock(blockId))!;
      expect(stored.blockType, SignalBlockType.delay);
      expect(stored.label, 'Slapback');
      expect(stored.notes, 'Dotted eighths');
      expect(stored.isEnabled, isFalse);
    });

    test('leaves the pedal in it and its place in the chain alone', () async {
      final pedalId = await addPedal('Caline PureSky');
      await block(type: SignalBlockType.tuner);
      final blockId = await block(pedalId: pedalId);

      // A rig gets rethought around the gear on it, so changing the type of a
      // block that already holds a pedal is allowed.
      await signalChainRepository(database).editBlock(
        blockId: blockId,
        draft: const SignalBlockDraft(blockType: SignalBlockType.boost),
      );

      final stored = (await database.signalChainDao.findBlock(blockId))!;
      expect(stored.pedalId, pedalId);
      expect(stored.position, 1);
      expect(await positions(), [0, 1]);
    });

    test('a cleared label falls back to what the block is for', () async {
      final blockId = await block(label: 'Always on');

      await signalChainRepository(database).editBlock(
        blockId: blockId,
        draft: const SignalBlockDraft(
          blockType: SignalBlockType.overdrive,
          label: '   ',
        ),
      );

      expect((await database.signalChainDao.findBlock(blockId))!.label, isNull);
      expect(await chain(), ['Overdrive']);
    });

    test('records the rig as changed', () async {
      final later = moment.add(const Duration(days: 2));
      final blockId = await block();

      await signalChainRepository(database, clock: () => later).editBlock(
        blockId: blockId,
        draft: const SignalBlockDraft(blockType: SignalBlockType.boost),
      );

      final rig = (await database.pedalboardDao.findPedalboard(rigId))!;
      expect(rig.updatedAt, later);
    });

    test('refuses a label longer than the column allows', () async {
      final blockId = await block();

      expect(
        signalChainRepository(database).editBlock(
          blockId: blockId,
          draft: SignalBlockDraft(
            blockType: SignalBlockType.overdrive,
            label: 'a' * (SignalBlockValidator.labelMaxLength + 1),
          ),
        ),
        failsWith('Use at most 80 characters.'),
      );
    });

    test('says so when the block is no longer there', () async {
      expect(
        signalChainRepository(database).editBlock(
          blockId: 404,
          draft: const SignalBlockDraft(blockType: SignalBlockType.overdrive),
        ),
        failsWith('That block is no longer on this rig.'),
      );
    });
  });

  group('bypassing a block', () {
    test('keeps it in the chain, in its place', () async {
      await block(type: SignalBlockType.tuner);
      final blockId = await block();
      await block(type: SignalBlockType.reverb);

      await signalChainRepository(
        database,
      ).setEnabled(blockId: blockId, isEnabled: false);

      expect(
        (await database.signalChainDao.findBlock(blockId))!.isEnabled,
        isFalse,
      );
      expect(await chain(), ['Tuner', 'Overdrive', 'Reverb']);
      expect(await positions(), [0, 1, 2]);
    });
  });

  group('taking a block off', () {
    test('closes the gap it leaves in the chain', () async {
      await block(type: SignalBlockType.tuner);
      final blockId = await block();
      await block(type: SignalBlockType.reverb);

      await signalChainRepository(database).removeBlock(blockId);

      expect(await chain(), ['Tuner', 'Reverb']);
      // Renumbered rather than left as 0 and 2.
      expect(await positions(), [0, 1]);
    });

    test('keeps the pedal that was in it, which is still owned', () async {
      final pedalId = await addPedal('Caline PureSky');
      final blockId = await block(pedalId: pedalId);

      await signalChainRepository(database).removeBlock(blockId);

      expect(
        (await database.pedalDao.findPedal(pedalId))!.name,
        'Caline PureSky',
      );
    });

    test('says so when it is no longer on the rig', () async {
      expect(
        signalChainRepository(database).removeBlock(404),
        failsWith('That block is no longer on this rig.'),
      );
    });

    test('puts it back where it stood, as it stood', () async {
      final pedalId = await addPedal('Caline PureSky');
      await block(type: SignalBlockType.tuner);
      final blockId = await block(pedalId: pedalId, label: 'Always on');
      await block(type: SignalBlockType.reverb);
      await signalChainRepository(
        database,
      ).setEnabled(blockId: blockId, isEnabled: false);

      final gone = await signalChainRepository(database).removeBlock(blockId);
      await signalChainRepository(database).restoreBlock(gone);

      // Everything the user chose comes back, in the place it was in.
      expect(await chain(), ['Tuner', 'Caline PureSky', 'Reverb']);
      expect(await positions(), [0, 1, 2]);
      final restored = (await database.signalChainDao.blocksOf(rigId))[1];
      expect(restored.label, 'Always on');
      expect(restored.pedalId, pedalId);
      expect(restored.isEnabled, isFalse);
    });
  });

  group('clearing the chain', () {
    test('takes every block off, and keeps every pedal', () async {
      final pedalId = await addPedal('Caline PureSky');
      await block(type: SignalBlockType.tuner);
      await block(pedalId: pedalId);

      await signalChainRepository(database).clearChain(rigId);

      expect(await chain(), isEmpty);
      expect(
        (await database.pedalDao.findPedal(pedalId))!.name,
        'Caline PureSky',
      );
    });

    test('leaves the rig, and every other rig, standing', () async {
      final otherRigId = await pedalboardRepository(
        database,
      ).createPedalboard(const PedalboardDraft(name: 'Home Practice'));
      await block();
      await block(onRig: otherRigId, type: SignalBlockType.reverb);

      await signalChainRepository(database).clearChain(rigId);

      expect(await database.pedalboardDao.findPedalboard(rigId), isNotNull);
      expect(await chain(otherRigId), ['Reverb']);
    });

    test('records the rig as changed', () async {
      final later = moment.add(const Duration(days: 2));
      await block();

      await signalChainRepository(
        database,
        clock: () => later,
      ).clearChain(rigId);

      final rig = (await database.pedalboardDao.findPedalboard(rigId))!;
      expect(rig.updatedAt, later);
    });

    test('says so when the rig is already gone', () async {
      expect(
        signalChainRepository(database).clearChain(404),
        failsWith('That rig no longer exists.'),
      );
    });
  });

  group('reordering', () {
    test('renumbers the chain into the given order', () async {
      final tuner = await block(type: SignalBlockType.tuner);
      final drive = await block();
      final verb = await block(type: SignalBlockType.reverb);

      await signalChainRepository(
        database,
      ).reorderChain(rigId, [verb, tuner, drive]);

      expect(await chain(), ['Reverb', 'Tuner', 'Overdrive']);
      expect(await positions(), [0, 1, 2]);
    });

    test('refuses a list that no longer matches the rig', () async {
      final tuner = await block(type: SignalBlockType.tuner);
      final drive = await block();

      // A block was added on another screen after this list was built.
      await block(type: SignalBlockType.reverb);

      expect(
        signalChainRepository(database).reorderChain(rigId, [drive, tuner]),
        failsWith(
          'This rig changed while you were reordering it. Reopen the rig and '
          'try again.',
        ),
      );
      expect(await chain(), ['Tuner', 'Overdrive', 'Reverb']);
    });
  });

  group('a rig that takes a trip through an amplifier loop', () {
    test('reads in the order it is patched, top to bottom', () async {
      // The four cable method: everything before the amp runs to a send, the amp's
      // own loop takes it away, and what comes back arrives at a return.
      final drive = await block(label: 'Drive');
      final send = await block(type: SignalBlockType.send, label: 'To the amp');
      final back = await block(
        type: SignalBlockType.fxReturn,
        label: 'Back in',
      );
      final delay = await block(type: SignalBlockType.delay, label: 'Slapback');
      final out = await block(
        type: SignalBlockType.output,
        label: 'To the cab',
      );
      final routing = signalRoutingRepository(database);
      await routing.connect(sourceBlockId: drive, targetBlockId: send);
      await routing.connect(sourceBlockId: back, targetBlockId: delay);
      await routing.connect(sourceBlockId: delay, targetBlockId: out);

      // Nothing on the rig feeds the return, so before the two halves are tied
      // together it comes out level with the send.
      expect(await chain(), [
        'Drive',
        'Back in',
        'To the amp',
        'Slapback',
        'To the cab',
      ]);

      await signalEndpointRepository(
        database,
      ).pair(sendBlockId: send, returnBlockId: back);

      // Said once, and the chain reads the way it is patched - without a cable
      // being invented for the part of the trip that happens off the board.
      expect(await chain(), [
        'Drive',
        'To the amp',
        'Back in',
        'Slapback',
        'To the cab',
      ]);
      expect(await database.signalChainDao.connectionsOf(rigId), hasLength(3));
    });

    test('goes back to reading by position when the pair is separated', () async {
      final send = await block(type: SignalBlockType.send, label: 'To the amp');
      final back = await block(
        type: SignalBlockType.fxReturn,
        label: 'Back in',
      );
      final endpoints = signalEndpointRepository(database);
      await endpoints.pair(sendBlockId: send, returnBlockId: back);

      await endpoints.unpair(send);

      // Both blocks stay on the rig either way: separating them says the loop is
      // no longer described, not that the board changed.
      expect(await chain(), ['To the amp', 'Back in']);
    });
  });

  group('deleting either end', () {
    test('deleting a rig takes its chain with it, not the pedals', () async {
      final pedalId = await addPedal('Caline PureSky');
      await block(pedalId: pedalId);

      await pedalboardRepository(database).deletePedalboard(rigId);

      expect(await database.signalChainDao.blocksOf(rigId), isEmpty);
      expect(await database.pedalDao.findPedal(pedalId), isNotNull);
    });

    test('a pedal in a block cannot be deleted until it comes out', () async {
      final pedalId = await addPedal('Caline PureSky');
      final blockId = await block(pedalId: pedalId);

      // Awaited, because what happens next depends on the refusal having
      // already happened.
      await expectLater(
        pedalRepository(database).deletePedal(pedalId),
        failsWith(
          // One message covers every reference a pedal can be held by, the
          // pedals inside a multi-effects unit included.
          'This pedal is on a rig, holds other pedals, or has configurations, '
          'history or snapshots attached. Take it off the rig, or change its '
          'status rather than deleting it.',
        ),
      );

      // Emptying the block is enough: the block itself holds no pedal now.
      await signalChainRepository(
        database,
      ).assignPedal(blockId: blockId, pedalId: null);
      await pedalRepository(database).deletePedal(pedalId);

      expect(await database.pedalDao.findPedal(pedalId), isNull);
    });
  });
}
