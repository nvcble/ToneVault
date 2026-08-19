import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/change_log_dao.dart';
import 'package:tone_vault/core/database/daos/pedal_dao.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/history/data/change_entry.dart';
import 'package:tone_vault/features/history/data/change_log_repository.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_repository.dart';

/// What the history layer guarantees: entries only ever accumulate, they come
/// back newest first, and they hold a pedal in place until the pedal itself goes.
void main() {
  late AppDatabase database;
  late ChangeLogRepository repository;
  late DateTime now;

  /// A pedal to hang history on, since every entry belongs to one.
  Future<Pedal> addPedal(String name) async {
    final pedals = PedalRepository(PedalDao(database));
    final id = await pedals.createPedal(
      PedalDraft(
        name: name,
        type: PedalType.analog,
        category: PedalCategory.overdrive,
      ),
    );
    return (await database.pedalDao.findPedal(id))!;
  }

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    now = DateTime.utc(2026, 8, 19, 12);
    repository = ChangeLogRepository(ChangeLogDao(database), clock: () => now);
  });

  tearDown(() => database.close());

  test('records a status change and reads it back', () async {
    final pedal = await addPedal('Caline PureSky');

    await repository.record(
      ChangeEntry.pedalStatusChanged(
        pedal: pedal.copyWith(status: PedalStatus.backup),
        previousStatus: PedalStatus.active,
        reason: 'moved to the backup board',
      ),
    );

    final entries = await repository.watchPedalChanges(pedal.id).first;
    expect(entries.single.oldText, 'Active');
    expect(entries.single.newText, 'Backup');
    expect(entries.single.reason, 'moved to the backup board');
    expect(entries.single.createdAt, now);
  });

  test('keeps every entry rather than replacing the last one', () async {
    final pedal = await addPedal('Caline PureSky');

    await repository.record(
      ChangeEntry.pedalStatusChanged(
        pedal: pedal.copyWith(status: PedalStatus.backup),
        previousStatus: PedalStatus.active,
      ),
    );
    await repository.record(
      ChangeEntry.pedalStatusChanged(
        pedal: pedal.copyWith(status: PedalStatus.storage),
        previousStatus: PedalStatus.backup,
      ),
    );

    // Append-only: the earlier entry is still there to be read.
    final entries = await repository.watchPedalChanges(pedal.id).first;
    expect(entries.map((entry) => entry.newText), ['In storage', 'Backup']);
  });

  test('orders same-instant entries by the order they were written', () async {
    final pedal = await addPedal('Caline PureSky');

    for (final status in [PedalStatus.backup, PedalStatus.storage]) {
      await repository.record(
        ChangeEntry.pedalStatusChanged(
          pedal: pedal.copyWith(status: status),
          previousStatus: PedalStatus.active,
        ),
      );
    }

    // Two changes saved in the same second still read in the order they
    // happened, which the timestamp alone cannot express.
    final entries = await repository.watchPedalChanges(pedal.id).first;
    expect(entries.first.newText, 'In storage');
  });

  test('reads the newest changes across pedals with their names', () async {
    final pureSky = await addPedal('Caline PureSky');
    final ocd = await addPedal('Fulltone OCD');

    await repository.record(
      ChangeEntry.pedalStatusChanged(
        pedal: pureSky.copyWith(status: PedalStatus.backup),
        previousStatus: PedalStatus.active,
      ),
    );
    now = now.add(const Duration(minutes: 5));
    await repository.record(
      ChangeEntry.pedalStatusChanged(
        pedal: ocd.copyWith(status: PedalStatus.storage),
        previousStatus: PedalStatus.active,
      ),
    );

    final changes = await repository.watchRecentChanges().first;
    expect(changes.map((change) => change.pedalName), [
      'Fulltone OCD',
      'Caline PureSky',
    ]);
  });

  test('reads no more entries than it was asked for', () async {
    final pedal = await addPedal('Caline PureSky');

    for (var index = 0; index < 5; index++) {
      now = now.add(const Duration(minutes: 1));
      await repository.record(
        ChangeEntry.pedalStatusChanged(
          pedal: pedal.copyWith(status: PedalStatus.backup),
          previousStatus: PedalStatus.active,
        ),
      );
    }

    // Bounded so a rig with years of history still opens quickly.
    expect(await repository.watchRecentChanges(limit: 2).first, hasLength(2));
    expect(
      await repository.watchPedalChanges(pedal.id, limit: 3).first,
      hasLength(3),
    );
  });

  test('holds a pedal in place until its history is cleared too', () async {
    final pedal = await addPedal('Caline PureSky');
    await repository.record(
      ChangeEntry.pedalStatusChanged(
        pedal: pedal.copyWith(status: PedalStatus.backup),
        previousStatus: PedalStatus.active,
      ),
    );

    // History cannot be orphaned by accident: the foreign key restricts the
    // delete, so removing a pedal has to say so explicitly.
    await expectLater(
      database.pedalDao.deletePedal(pedal.id),
      throwsA(isNotNull),
    );

    await database.changeLogDao.deleteForPedal(pedal.id);
    expect(await database.pedalDao.deletePedal(pedal.id), isTrue);
  });

  test('reports a change it could not record in words', () async {
    final missing = await addPedal('Caline PureSky');
    expect(await database.pedalDao.deletePedal(missing.id), isTrue);

    await expectLater(
      repository.record(
        ChangeEntry.pedalStatusChanged(
          pedal: missing,
          previousStatus: PedalStatus.active,
        ),
      ),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.message,
          'message',
          'Could not record this change.',
        ),
      ),
    );
  });
}
