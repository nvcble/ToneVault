import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/pedalboards/data/pedalboard_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import '../support/repositories.dart';

/// Building a rig's signal chain: what goes on it, in what order, and what
/// happens to the order when something comes off.
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

  Future<int> put(int pedalId, {int? onRig, DateTime? at}) {
    return rigChainRepository(
      database,
      clock: at == null ? null : () => at,
    ).addPedal(pedalboardId: onRig ?? rigId, pedalId: pedalId);
  }

  /// The chain as the screen reads it: pedal names in signal order.
  Future<List<String>> chain([int? boardId]) async {
    final slots = await database.pedalboardDao
        .watchChain(boardId ?? rigId)
        .first;
    return [for (final entry in slots) entry.pedal.name];
  }

  Future<List<int>> positions() async {
    final slots = await database.pedalboardDao.slotsOf(rigId);
    return [for (final slot in slots) slot.position];
  }

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    rigId = await pedalboardRepository(
      database,
      clock: () => moment,
    ).createPedalboard(const PedalboardDraft(name: 'Hybrid Worship Rig'));
  });

  tearDown(() => database.close());

  test(
    'adds pedals to the end of the chain, in the order signal runs',
    () async {
      await put(await addPedal('Boss TU-3'));
      await put(await addPedal('Caline PureSky'));
      await put(await addPedal('Strymon Flint'));

      expect(await chain(), ['Boss TU-3', 'Caline PureSky', 'Strymon Flint']);
      expect(await positions(), [0, 1, 2]);
    },
  );

  test('records the rig as changed when a pedal goes on it', () async {
    final later = moment.add(const Duration(days: 2));

    await put(await addPedal('Boss TU-3'), at: later);

    final rig = (await database.pedalboardDao.findPedalboard(rigId))!;
    expect(rig.updatedAt, later);
    expect(rig.createdAt, moment);
  });

  test('refuses the same pedal twice, naming both', () async {
    final tuner = await addPedal('Boss TU-3');
    await put(tuner);

    expect(
      put(tuner),
      failsWith('Boss TU-3 is already on Hybrid Worship Rig.'),
    );
    expect(await chain(), ['Boss TU-3']);
  });

  test('the same pedal can be on two different rigs', () async {
    final tuner = await addPedal('Boss TU-3');
    final secondRigId = await pedalboardRepository(
      database,
    ).createPedalboard(const PedalboardDraft(name: 'Home Practice'));

    await put(tuner);
    await put(tuner, onRig: secondRigId);

    expect(await chain(), ['Boss TU-3']);
    expect(await chain(secondRigId), ['Boss TU-3']);
  });

  test('says so when the rig or the pedal is already gone', () async {
    expect(
      put(await addPedal('Boss TU-3'), onRig: 404),
      failsWith('That rig no longer exists.'),
    );
    expect(put(404), failsWith('That pedal no longer exists.'));
  });

  group('taking a pedal off', () {
    test('closes the gap it leaves in the chain', () async {
      await put(await addPedal('Boss TU-3'));
      final slotId = await put(await addPedal('Caline PureSky'));
      await put(await addPedal('Strymon Flint'));

      await rigChainRepository(database).removePedal(slotId);

      expect(await chain(), ['Boss TU-3', 'Strymon Flint']);
      // Renumbered rather than left as 0 and 2.
      expect(await positions(), [0, 1]);
    });

    test('keeps the pedal itself, which is still owned', () async {
      final pedalId = await addPedal('Caline PureSky');
      final slotId = await put(pedalId);

      await rigChainRepository(database).removePedal(slotId);

      expect(
        (await database.pedalDao.findPedal(pedalId))!.name,
        'Caline PureSky',
      );
    });

    test('says so when it is no longer on the rig', () async {
      expect(
        rigChainRepository(database).removePedal(404),
        failsWith('That pedal is no longer on this rig.'),
      );
    });
  });

  group('reordering', () {
    test('renumbers the chain into the given order', () async {
      final tuner = await put(await addPedal('Boss TU-3'));
      final drive = await put(await addPedal('Caline PureSky'));
      final reverb = await put(await addPedal('Strymon Flint'));

      await rigChainRepository(
        database,
      ).reorderChain(rigId, [reverb, tuner, drive]);

      expect(await chain(), ['Strymon Flint', 'Boss TU-3', 'Caline PureSky']);
      expect(await positions(), [0, 1, 2]);
    });

    test('refuses a list that no longer matches the rig', () async {
      final tuner = await put(await addPedal('Boss TU-3'));
      final drive = await put(await addPedal('Caline PureSky'));

      // A pedal was added on another screen after this list was built.
      await put(await addPedal('Strymon Flint'));

      expect(
        rigChainRepository(database).reorderChain(rigId, [drive, tuner]),
        failsWith(
          'This rig changed while you were reordering it. Reopen the rig and '
          'try again.',
        ),
      );
      expect(await chain(), ['Boss TU-3', 'Caline PureSky', 'Strymon Flint']);
    });
  });

  group('deleting either end', () {
    test('deleting a rig takes its chain with it, not the pedals', () async {
      final pedalId = await addPedal('Caline PureSky');
      await put(pedalId);

      await pedalboardRepository(database).deletePedalboard(rigId);

      expect(await database.pedalboardDao.slotsOf(rigId), isEmpty);
      expect(await database.pedalDao.findPedal(pedalId), isNotNull);
    });

    test('a pedal on a rig cannot be deleted until it comes off', () async {
      final pedalId = await addPedal('Caline PureSky');
      final slotId = await put(pedalId);

      // Awaited, because what happens next depends on the refusal having
      // already happened.
      await expectLater(
        pedalRepository(database).deletePedal(pedalId),
        failsWith(
          'This pedal is on a rig, or has configurations, history or snapshots '
          'attached. Take it off the rig, or change its status rather than '
          'deleting it.',
        ),
      );

      await rigChainRepository(database).removePedal(slotId);
      await pedalRepository(database).deletePedal(pedalId);

      expect(await database.pedalDao.findPedal(pedalId), isNull);
    });
  });
}
