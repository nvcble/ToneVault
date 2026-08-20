import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/change_log_dao.dart';
import 'package:tone_vault/core/enums/change_type.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/controls/data/control_draft.dart';
import 'package:tone_vault/features/patches/data/patch_draft.dart';
import 'package:tone_vault/features/patches/data/scene_duplicator.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import '../support/broken_change_log.dart';
import '../support/repositories.dart';

/// Copying a scene.
///
/// A chorus is usually the verse with one pedal louder, so what is pinned down
/// here is that the copy arrives complete - the pedals it uses and where their
/// controls sit - and that it is a scene of its own afterwards, not a view of the
/// one it came from.
void main() {
  late AppDatabase database;
  late SceneDuplicator duplicator;
  late int unitId;
  late int screamerId;
  late int driveId;
  late int patchId;
  late int verseId;
  final now = DateTime.utc(2026, 8, 21, 10);

  /// A refusal the user can read, rather than a raw driver exception.
  Matcher failsWith(String message) => throwsA(
    isA<AppFailure>().having((failure) => failure.message, 'message', message),
  );

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    duplicator = sceneDuplicator(database, clock: () => now);

    unitId = await pedalRepository(database).createPedal(
      const PedalDraft(
        name: 'Valeton GP-200',
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
      ),
    );
    screamerId = await pedalRepository(database).createPedal(
      PedalDraft(
        name: 'Tube Screamer',
        type: PedalType.digital,
        category: PedalCategory.overdrive,
        hostPedalId: unitId,
      ),
    );
    driveId = await controlRepository(database).createControl(
      screamerId,
      const ControlDraft(
        name: 'Drive',
        type: ControlType.clock,
        minValue: 0,
        maxValue: 1,
        step: 0.05,
      ),
    );

    patchId = await patchRepository(
      database,
    ).createPatch(unitId, const PatchDraft(name: 'Worship Clean'));
    verseId = await sceneRepository(database).createScene(
      patchId,
      const SceneDraft(name: 'Verse', notes: 'Quiet, capo 2'),
    );
    await scenePedalRepository(
      database,
    ).addPedal(sceneId: verseId, pedalId: screamerId);
    await sceneValueRepository(
      database,
    ).setValue(sceneId: verseId, controlId: driveId, value: 0.75);
  });

  tearDown(() => database.close());

  Future<Scene> sceneOf(int sceneId) async =>
      (await database.patchDao.findScene(sceneId))!;

  test('the copy is a scene of the same patch, under a free name', () async {
    final copyId = await duplicator.duplicate(verseId);

    final copy = await sceneOf(copyId);
    expect(copy.patchId, patchId);
    // The user asked for another scene like this one, not to name it first.
    expect(copy.name, 'Verse copy');
    expect(copy.createdAt, now);
  });

  test('the copy carries the details, notes and all', () async {
    final copyId = await duplicator.duplicate(verseId);

    expect((await sceneOf(copyId)).notes, 'Quiet, capo 2');
  });

  test('the copy uses the same pedals, not copies of them', () async {
    final copyId = await duplicator.duplicate(verseId);

    // One row of gear reached from both scenes: the Tube Screamer's own controls
    // and history are the unit's, entered once.
    final pedals = await database.sceneDao.scenePedalsOf(copyId);
    expect(pedals.single.id, screamerId);
    expect(
      await pedalRepository(database).watchComponentPedals(unitId).first,
      hasLength(1),
    );
  });

  test('and holds where their controls sat', () async {
    final copyId = await duplicator.duplicate(verseId);

    // Without the positions, a duplicated scene would be an empty scene with a
    // familiar name.
    final values = await database.sceneDao.valuesOf(copyId);
    expect(values.single.controlId, driveId);
    expect(values.single.value, 0.75);
  });

  test('the scene it came from is left exactly as it was', () async {
    await duplicator.duplicate(verseId);

    final source = await sceneOf(verseId);
    expect(source.name, 'Verse');
    expect(await database.sceneDao.scenePedalsOf(verseId), hasLength(1));
    expect((await database.sceneDao.valuesOf(verseId)).single.value, 0.75);
  });

  test('a second copy is named apart from the first', () async {
    await duplicator.duplicate(verseId);

    final secondId = await duplicator.duplicate(verseId);

    expect((await sceneOf(secondId)).name, 'Verse copy 2');
  });

  test('copying the copy is allowed, and named from it', () async {
    final copyId = await duplicator.duplicate(verseId);

    final secondId = await duplicator.duplicate(copyId);

    // "Verse copy copy" reads oddly, but it says which row it came from, and the
    // name is the user's to change.
    expect((await sceneOf(secondId)).name, 'Verse copy copy');
  });

  test('an empty scene copies to an empty scene', () async {
    final emptyId = await sceneRepository(
      database,
    ).createScene(patchId, const SceneDraft(name: 'Intro'));

    final copyId = await duplicator.duplicate(emptyId);

    expect(await database.sceneDao.scenePedalsOf(copyId), isEmpty);
    expect(await database.sceneDao.valuesOf(copyId), isEmpty);
  });

  test('the copy is recorded as a scene arriving', () async {
    await duplicator.duplicate(verseId);

    // A copy is a new sound in the patch, which is the same event as any other
    // scene being added - so it needs no change type of its own.
    final entries = await database.changeLogDao.entriesOf(unitId);
    final created = entries
        .where((entry) => entry.changeType == ChangeType.sceneCreated)
        .toList();
    expect(created.last.configurationName, 'Worship Clean · Verse copy');
  });

  test('a scene that is gone is refused, in words', () async {
    await sceneRepository(database).deleteScene(verseId);

    await expectLater(
      duplicator.duplicate(verseId),
      failsWith('That scene no longer exists.'),
    );
  });

  test('a history that cannot be written takes the copy with it', () async {
    final failing = sceneDuplicator(
      database,
      changeLog: BrokenChangeLog(ChangeLogDao(database)),
    );

    await expectLater(
      failing.duplicate(verseId),
      failsWith('Could not duplicate this scene.'),
    );
    // Append-only means the log is not optional: a copy the history does not
    // mention would be a scene that appeared out of nowhere.
    expect(await database.patchDao.scenesOf(patchId), hasLength(1));
  });
}
