import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/pedalboards/data/pedalboard_draft.dart';
import '../support/repositories.dart';

/// Rigs as records: naming one, renaming it, and removing it. Real writes over an
/// in-memory database.
void main() {
  late AppDatabase database;
  final moment = DateTime.utc(2026, 8, 19, 12);

  /// A refusal the user can read, rather than a raw driver exception.
  Matcher failsWith(String message) => throwsA(
    isA<AppFailure>().having((failure) => failure.message, 'message', message),
  );

  Future<int> addRig(String name, {String? description}) {
    return pedalboardRepository(
      database,
      clock: () => moment,
    ).createPedalboard(PedalboardDraft(name: name, description: description));
  }

  Future<Pedalboard?> rig(int id) => database.pedalboardDao.findPedalboard(id);

  setUp(() => database = AppDatabase(NativeDatabase.memory()));

  tearDown(() => database.close());

  test('stores a rig with its description and timestamps', () async {
    final id = await addRig(
      '  Hybrid Worship Rig ',
      description: '  MG-30 into the desk  ',
    );

    final stored = (await rig(id))!;
    expect(stored.name, 'Hybrid Worship Rig');
    expect(stored.description, 'MG-30 into the desk');
    expect(stored.createdAt, moment);
    expect(stored.updatedAt, moment);
  });

  test('refuses a rig with no name', () async {
    expect(addRig('   '), failsWith('Enter a rig name.'));

    expect(await database.pedalboardDao.watchPedalboards().first, isEmpty);
  });

  test('refuses a second rig with the same name, whatever the case', () async {
    await addRig('Home Practice');

    // The unique key would catch the exact repeat; the check also catches the
    // one that only differs in case, and says which rig is in the way.
    expect(
      addRig('home practice'),
      failsWith('A rig called "Home Practice" already exists.'),
    );
  });

  test('lists rigs by name regardless of case', () async {
    await addRig('worship');
    await addRig('Home Practice');
    await addRig('Zoom demo');

    final rigs = await database.pedalboardDao.watchPedalboards().first;

    expect(rigs.map((board) => board.name), [
      'Home Practice',
      'worship',
      'Zoom demo',
    ]);
  });

  group('renaming', () {
    test('saves the new name and moves updatedAt on', () async {
      final id = await addRig('Home Practice', description: 'desk');
      final later = moment.add(const Duration(days: 1));

      await pedalboardRepository(database, clock: () => later).updatePedalboard(
        id,
        const PedalboardDraft(name: 'Desk Rig', description: 'desk amp'),
      );

      final stored = (await rig(id))!;
      expect(stored.name, 'Desk Rig');
      expect(stored.description, 'desk amp');
      expect(stored.createdAt, moment);
      expect(stored.updatedAt, later);
    });

    test('lets a rig keep its own name', () async {
      final id = await addRig('Home Practice');

      // Only the description is changing, and the rig itself is not a clash.
      await pedalboardRepository(database).updatePedalboard(
        id,
        const PedalboardDraft(name: 'Home Practice', description: 'quiet'),
      );

      expect((await rig(id))!.description, 'quiet');
    });

    test('refuses to take a name another rig already has', () async {
      await addRig('Home Practice');
      final id = await addRig('Worship');

      expect(
        pedalboardRepository(
          database,
        ).updatePedalboard(id, const PedalboardDraft(name: 'Home Practice')),
        failsWith('A rig called "Home Practice" already exists.'),
      );
      expect((await rig(id))!.name, 'Worship');
    });

    test('says so when the rig is already gone', () async {
      expect(
        pedalboardRepository(
          database,
        ).updatePedalboard(404, const PedalboardDraft(name: 'Ghost Rig')),
        failsWith('That rig no longer exists.'),
      );
    });
  });

  group('deleting', () {
    test('removes the rig', () async {
      final id = await addRig('Home Practice');

      await pedalboardRepository(database).deletePedalboard(id);

      expect(await rig(id), isNull);
    });

    test('frees the name for a new rig', () async {
      final id = await addRig('Home Practice');
      await pedalboardRepository(database).deletePedalboard(id);

      final replacementId = await addRig('Home Practice');

      expect((await rig(replacementId))!.name, 'Home Practice');
    });

    test('says so when the rig is already gone', () async {
      expect(
        pedalboardRepository(database).deletePedalboard(404),
        failsWith('That rig no longer exists.'),
      );
    });

    test('refuses while snapshots of the rig are kept', () async {
      final id = await addRig('Home Practice');
      await database.rigSnapshotDao.insertSnapshot(
        RigSnapshotsCompanion.insert(
          pedalboardId: id,
          name: 'Easter 2026',
          capturedAt: moment,
        ),
      );

      // Deleting the rig would take the snapshot with it, so it is refused in
      // words rather than as a constraint failure.
      await expectLater(
        pedalboardRepository(database).deletePedalboard(id),
        failsWith(
          'This rig has 1 snapshot of how it was set up. Delete those first if '
          'you no longer want the rig.',
        ),
      );
      expect(await rig(id), isNotNull);
    });
  });
}
