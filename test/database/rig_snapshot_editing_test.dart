import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/pedalboards/data/pedalboard_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import 'package:tone_vault/features/snapshots/data/snapshot_draft.dart';
import '../support/repositories.dart';

/// The only two things a captured snapshot will accept: a corrected name or note,
/// and being deleted outright.
void main() {
  late AppDatabase database;
  late int rigId;
  late int snapshotId;
  final captured = DateTime.utc(2026, 4, 5, 9, 30);

  /// A refusal the user can read, rather than a raw driver exception.
  Matcher failsWith(String message) => throwsA(
    isA<AppFailure>().having((failure) => failure.message, 'message', message),
  );

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    rigId = await pedalboardRepository(
      database,
    ).createPedalboard(const PedalboardDraft(name: 'Hybrid Worship Rig'));
    final pedalId = await pedalRepository(database).createPedal(
      const PedalDraft(
        name: 'Caline PureSky',
        type: PedalType.analog,
        category: PedalCategory.overdrive,
      ),
    );
    await rigChainRepository(
      database,
    ).addPedal(pedalboardId: rigId, pedalId: pedalId);
    snapshotId = await rigSnapshotRepository(
      database,
      clock: () => captured,
    ).captureSnapshot(rigId, const SnapshotDraft(name: 'Easter'));
  });

  tearDown(() => database.close());

  group('renaming', () {
    test('saves the new name and notes, leaving the date alone', () async {
      await rigSnapshotRepository(database).updateSnapshot(
        snapshotId,
        const SnapshotDraft(
          name: '  Easter Sunday 2026 ',
          notes: '  Second service  ',
        ),
      );

      final stored = (await database.rigSnapshotDao.findSnapshot(snapshotId))!;
      expect(stored.name, 'Easter Sunday 2026');
      expect(stored.notes, 'Second service');
      // When the rig looked like this is the snapshot's whole point.
      expect(stored.capturedAt, captured);
    });

    test('clears a note that has been emptied', () async {
      final repository = rigSnapshotRepository(database);
      await repository.updateSnapshot(
        snapshotId,
        const SnapshotDraft(name: 'Easter', notes: 'Second service'),
      );

      await repository.updateSnapshot(
        snapshotId,
        const SnapshotDraft(name: 'Easter', notes: '   '),
      );

      // Blank is no note, not a note that reads as empty.
      expect(
        (await database.rigSnapshotDao.findSnapshot(snapshotId))!.notes,
        isNull,
      );
    });

    test('refuses a snapshot with no name', () async {
      expect(
        rigSnapshotRepository(
          database,
        ).updateSnapshot(snapshotId, const SnapshotDraft(name: '  ')),
        failsWith('Enter a name for this snapshot.'),
      );
      expect(
        (await database.rigSnapshotDao.findSnapshot(snapshotId))!.name,
        'Easter',
      );
    });

    test('says so when the snapshot is already gone', () async {
      expect(
        rigSnapshotRepository(
          database,
        ).updateSnapshot(404, const SnapshotDraft(name: 'Easter')),
        failsWith('That snapshot no longer exists.'),
      );
    });
  });

  group('deleting', () {
    test('takes the record of the day, and nothing else', () async {
      await rigSnapshotRepository(database).deleteSnapshot(snapshotId);

      expect(await database.rigSnapshotDao.findSnapshot(snapshotId), isNull);
      // The rig and its chain are what the user still owns and plays.
      expect(await database.pedalboardDao.findPedalboard(rigId), isNotNull);
      expect(
        await database.pedalboardDao.watchChain(rigId).first,
        hasLength(1),
      );
    });

    test('frees the rig to be deleted again', () async {
      await rigSnapshotRepository(database).deleteSnapshot(snapshotId);
      final slots = await database.pedalboardDao.slotsOf(rigId);
      await rigChainRepository(database).removePedal(slots.single.id);

      await pedalboardRepository(database).deletePedalboard(rigId);

      expect(await database.pedalboardDao.findPedalboard(rigId), isNull);
    });

    test('says so when the snapshot is already gone', () async {
      expect(
        rigSnapshotRepository(database).deleteSnapshot(404),
        failsWith('That snapshot no longer exists.'),
      );
    });
  });
}
