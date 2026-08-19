import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/controls/data/control_draft.dart';
import 'package:tone_vault/features/history/data/change_entry.dart';
import 'package:tone_vault/features/history/data/change_log_repository.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import '../support/repositories.dart';

/// What the history layer guarantees: entries only ever accumulate, they come
/// back newest first, and they hold a pedal in place for as long as they exist.
/// What each edit records is covered by change_history_test.dart.
void main() {
  late AppDatabase database;
  late ChangeLogRepository repository;
  late DateTime now;

  /// A pedal to hang history on, since every entry belongs to one.
  Future<Pedal> addPedal(String name) async {
    final pedals = pedalRepository(database);
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
    repository = changeLogRepository(database, clock: () => now);
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
    expect(entries.single.entry.oldText, 'Active');
    expect(entries.single.entry.newText, 'Backup');
    expect(entries.single.entry.reason, 'moved to the backup board');
    expect(entries.single.entry.createdAt, now);
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
    expect(entries.map((change) => change.entry.newText), [
      'In storage',
      'Backup',
    ]);
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
    expect(entries.first.entry.newText, 'In storage');
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

  test('brings the control along until it is removed', () async {
    final pedal = await addPedal('Caline PureSky');
    final controls = controlRepository(database);
    final volumeId = await controls.createControl(
      pedal.id,
      ControlDraft.ofType(ControlType.clock, name: 'Volume'),
    );

    // The definition is what says a stored 0.5 reads as 12:00, so it is read
    // along with the entry for as long as it resolves.
    final changes = await repository.watchPedalChanges(pedal.id).first;
    expect(changes.single.control?.name, 'Volume');

    await controls.deleteControl(volumeId);

    // Two entries now, the control having been added and then removed. Neither
    // can reach the control any more, and both still name it.
    final afterRemoval = await repository.watchPedalChanges(pedal.id).first;
    expect(afterRemoval, hasLength(2));
    expect(afterRemoval.every((change) => change.control == null), isTrue);
    expect(afterRemoval.first.entry.controlName, 'Volume');
  });

  test('holds a pedal in place once anything is recorded about it', () async {
    final pedal = await addPedal('Caline PureSky');
    await repository.record(
      ChangeEntry.pedalStatusChanged(
        pedal: pedal.copyWith(status: PedalStatus.backup),
        previousStatus: PedalStatus.active,
      ),
    );

    // History outlives the urge to tidy up: the foreign key restricts the
    // delete, and PedalRepository turns that into an offer to retire the pedal
    // instead. There is deliberately no way to drop a pedal's entries.
    await expectLater(
      database.pedalDao.deletePedal(pedal.id),
      throwsA(isNotNull),
    );
    expect(await database.changeLogDao.entriesOf(pedal.id), hasLength(1));
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
