import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/signal_block_type.dart';
import 'package:tone_vault/core/enums/signal_connection_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/pedalboards/data/pedalboard_draft.dart';
import '../support/repositories.dart';

/// Wiring a rig: which block feeds which, and what the wiring refuses to become.
///
/// A rig with nothing here runs straight through, so every row written by these
/// tests is one the user asked for by hand.
void main() {
  late AppDatabase database;
  late int rigId;
  final moment = DateTime.utc(2026, 8, 19, 12);

  /// A refusal the user can read, rather than a raw driver exception.
  Matcher failsWith(String message) => throwsA(
    isA<AppFailure>().having((failure) => failure.message, 'message', message),
  );

  Future<int> block(SignalBlockType type, {int? onRig}) {
    return signalChainRepository(
      database,
    ).addBlock(pedalboardId: onRig ?? rigId, blockType: type);
  }

  Future<List<SignalConnection>> cables([int? boardId]) {
    return database.signalChainDao.connectionsOf(boardId ?? rigId);
  }

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    rigId = await pedalboardRepository(
      database,
      clock: () => moment,
    ).createPedalboard(const PedalboardDraft(name: 'Hybrid Worship Rig'));
  });

  tearDown(() => database.close());

  test('runs a cable between two blocks of the same rig', () async {
    final drive = await block(SignalBlockType.overdrive);
    final verb = await block(SignalBlockType.reverb);

    final id = await signalRoutingRepository(
      database,
    ).connect(sourceBlockId: drive, targetBlockId: verb);

    final cable = (await cables()).single;
    expect(cable.id, id);
    expect(cable.sourceBlockId, drive);
    expect(cable.targetBlockId, verb);
    // Series unless the user says otherwise: one path is still the common rig.
    expect(cable.connectionType, SignalConnectionType.series);
  });

  test('a cable can be a parallel path', () async {
    final split = await block(SignalBlockType.utility);
    final verb = await block(SignalBlockType.reverb);

    await signalRoutingRepository(database).connect(
      sourceBlockId: split,
      targetBlockId: verb,
      type: SignalConnectionType.parallel,
    );

    expect(
      (await cables()).single.connectionType,
      SignalConnectionType.parallel,
    );
  });

  test('a second cable out of one block is a split', () async {
    // The user does not say "parallel": running a second cable out of a block is
    // what makes it one, whether or not that block is called a split.
    final drive = await block(SignalBlockType.overdrive);
    final delay = await block(SignalBlockType.delay);
    final verb = await block(SignalBlockType.reverb);
    final routing = signalRoutingRepository(database);

    await routing.connect(sourceBlockId: drive, targetBlockId: delay);
    await routing.connect(sourceBlockId: drive, targetBlockId: verb);

    final wiring = {
      for (final cable in await cables())
        cable.targetBlockId: cable.connectionType,
    };
    expect(wiring[delay], SignalConnectionType.series);
    expect(wiring[verb], SignalConnectionType.parallel);
  });

  test('reads the wiring back as questions about it', () async {
    final drive = await block(SignalBlockType.overdrive);
    final verb = await block(SignalBlockType.reverb);
    final repository = signalRoutingRepository(database);
    await repository.connect(sourceBlockId: drive, targetBlockId: verb);

    final wiring = await repository.watchRouting(rigId).first;

    expect(wiring.pathsFrom(drive), 1);
    expect(wiring.into(verb), hasLength(1));
  });

  test('records the rig as changed when its wiring changes', () async {
    final later = moment.add(const Duration(days: 2));
    final drive = await block(SignalBlockType.overdrive);
    final verb = await block(SignalBlockType.reverb);

    final id = await signalRoutingRepository(
      database,
      clock: () => later,
    ).connect(sourceBlockId: drive, targetBlockId: verb);

    expect(
      (await database.pedalboardDao.findPedalboard(rigId))!.updatedAt,
      later,
    );

    await signalRoutingRepository(
      database,
      clock: () => later.add(const Duration(days: 1)),
    ).disconnect(id);

    expect(
      (await database.pedalboardDao.findPedalboard(rigId))!.updatedAt,
      later.add(const Duration(days: 1)),
    );
  });

  test('the rig keeps a note of which rig each cable is on', () async {
    // Stored alongside the two blocks so a rig's wiring can be read without
    // joining through them.
    final drive = await block(SignalBlockType.overdrive);
    final verb = await block(SignalBlockType.reverb);

    await signalRoutingRepository(
      database,
    ).connect(sourceBlockId: drive, targetBlockId: verb);

    expect((await cables()).single.pedalboardId, rigId);
  });

  group('what it refuses', () {
    test('a block that is no longer there', () async {
      final drive = await block(SignalBlockType.overdrive);

      expect(
        signalRoutingRepository(
          database,
        ).connect(sourceBlockId: drive, targetBlockId: 404),
        failsWith('That block is no longer on this rig.'),
      );
    });

    test('two blocks on different rigs', () async {
      final otherRigId = await pedalboardRepository(
        database,
      ).createPedalboard(const PedalboardDraft(name: 'Home Practice'));
      final drive = await block(SignalBlockType.overdrive);
      final verb = await block(SignalBlockType.reverb, onRig: otherRigId);

      expect(
        signalRoutingRepository(
          database,
        ).connect(sourceBlockId: drive, targetBlockId: verb),
        failsWith('Those two blocks are on different rigs.'),
      );
    });

    test('a block feeding itself', () async {
      final drive = await block(SignalBlockType.overdrive);

      expect(
        signalRoutingRepository(
          database,
        ).connect(sourceBlockId: drive, targetBlockId: drive),
        failsWith('A block cannot feed itself.'),
      );
    });

    test('the same pair twice', () async {
      final drive = await block(SignalBlockType.overdrive);
      final verb = await block(SignalBlockType.reverb);
      final routing = signalRoutingRepository(database);
      await routing.connect(sourceBlockId: drive, targetBlockId: verb);

      await expectLater(
        routing.connect(sourceBlockId: drive, targetBlockId: verb),
        failsWith('Those two blocks are already connected.'),
      );
      expect(await cables(), hasLength(1));
    });

    test('a loop, however long the way round', () async {
      final drive = await block(SignalBlockType.overdrive);
      final delay = await block(SignalBlockType.delay);
      final verb = await block(SignalBlockType.reverb);
      final routing = signalRoutingRepository(database);
      await routing.connect(sourceBlockId: drive, targetBlockId: delay);
      await routing.connect(sourceBlockId: delay, targetBlockId: verb);

      await expectLater(
        routing.connect(sourceBlockId: verb, targetBlockId: drive),
        failsWith('That would send signal back into itself.'),
      );
      expect(await cables(), hasLength(2));
    });

    test('pulling out a cable that is already gone', () async {
      expect(
        signalRoutingRepository(database).disconnect(404),
        failsWith('That connection is no longer on this rig.'),
      );
    });

    test('a cable running on from an output', () async {
      final out = await block(SignalBlockType.output);
      final verb = await block(SignalBlockType.reverb);

      await expectLater(
        signalRoutingRepository(
          database,
        ).connect(sourceBlockId: out, targetBlockId: verb),
        failsWith(
          'Signal leaves the rig at an output, so nothing on the rig follows '
          'it.',
        ),
      );
      expect(await cables(), isEmpty);
    });

    test('a cable out of a send, which is what a return is for', () async {
      final send = await block(SignalBlockType.send);
      final verb = await block(SignalBlockType.reverb);

      expect(
        signalRoutingRepository(
          database,
        ).connect(sourceBlockId: send, targetBlockId: verb),
        failsWith(
          'A send is where signal leaves the rig, so pair it with a return '
          'rather than cabling it on.',
        ),
      );
    });

    test('a cable into an input', () async {
      final start = await block(SignalBlockType.input);
      final verb = await block(SignalBlockType.reverb);

      expect(
        signalRoutingRepository(
          database,
        ).connect(sourceBlockId: verb, targetBlockId: start),
        failsWith(
          'An input is where signal starts, so nothing on the rig feeds it.',
        ),
      );
    });

    test('a cable into a return', () async {
      final back = await block(SignalBlockType.fxReturn);
      final verb = await block(SignalBlockType.reverb);

      expect(
        signalRoutingRepository(
          database,
        ).connect(sourceBlockId: verb, targetBlockId: back),
        failsWith(
          'A return brings signal back from outside the rig, so nothing on the '
          'rig feeds it.',
        ),
      );
    });
  });

  group('what a rig into an amplifier loop is wired as', () {
    test('the board runs into a send and on out of a return', () async {
      // The four cable method, in-app: everything before the amp runs to a send,
      // and what comes back off the amp's own send arrives at a return.
      final drive = await block(SignalBlockType.overdrive);
      final send = await block(SignalBlockType.send);
      final back = await block(SignalBlockType.fxReturn);
      final delay = await block(SignalBlockType.delay);
      final out = await block(SignalBlockType.output);
      final routing = signalRoutingRepository(database);

      await routing.connect(sourceBlockId: drive, targetBlockId: send);
      await routing.connect(sourceBlockId: back, targetBlockId: delay);
      await routing.connect(sourceBlockId: delay, targetBlockId: out);

      // Three cables, and no fourth one between the send and the return: what
      // happens in between is an amplifier the app has never seen.
      expect(await cables(), hasLength(3));
    });
  });

  group('what a cable does not outlive', () {
    test('taking a block off pulls the cables at either end', () async {
      final drive = await block(SignalBlockType.overdrive);
      final delay = await block(SignalBlockType.delay);
      final verb = await block(SignalBlockType.reverb);
      final routing = signalRoutingRepository(database);
      await routing.connect(sourceBlockId: drive, targetBlockId: delay);
      await routing.connect(sourceBlockId: delay, targetBlockId: verb);

      await signalChainRepository(database).removeBlock(delay);

      // A cable to a block that is gone is not a cable.
      expect(await cables(), isEmpty);
    });

    test('deleting the rig takes its wiring with it', () async {
      final drive = await block(SignalBlockType.overdrive);
      final verb = await block(SignalBlockType.reverb);
      await signalRoutingRepository(
        database,
      ).connect(sourceBlockId: drive, targetBlockId: verb);

      await pedalboardRepository(database).deletePedalboard(rigId);

      expect(await cables(), isEmpty);
    });

    test('pulling one out leaves the blocks where they are', () async {
      final drive = await block(SignalBlockType.overdrive);
      final verb = await block(SignalBlockType.reverb);
      final routing = signalRoutingRepository(database);
      final id = await routing.connect(
        sourceBlockId: drive,
        targetBlockId: verb,
      );

      await routing.disconnect(id);

      expect(await cables(), isEmpty);
      expect(await database.signalChainDao.blocksOf(rigId), hasLength(2));
    });
  });
}
