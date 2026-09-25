import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/midi/data/midi_patch_recent_repository.dart';
import 'package:tone_vault/features/patches/data/patch_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';

import '../support/repositories.dart';

void main() {
  late AppDatabase database;
  late int unitId;
  late int firstPatchId;
  late int secondPatchId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    unitId = await pedalRepository(database).createPedal(
      const PedalDraft(
        name: 'NUX MG-30 (V5)',
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
      ),
    );
    firstPatchId = await patchRepository(
      database,
    ).createPatch(unitId, const PatchDraft(name: 'Worship Lead'));
    secondPatchId = await patchRepository(
      database,
    ).createPatch(unitId, const PatchDraft(name: 'Clean Verse'));
  });

  tearDown(() => database.close());

  test('has no recents until one is recorded', () async {
    final recents = await midiPatchRecentRepository(
      database,
    ).watchRecents().first;

    expect(recents, isEmpty);
  });

  test('recordUsed adds a patch to recents', () async {
    final repository = midiPatchRecentRepository(database);

    await repository.recordUsed(firstPatchId);

    final recents = await repository.watchRecents().first;
    expect(recents.map((r) => r.patchId), [firstPatchId]);
  });

  test('recordUsed moves an already-recent patch back to the front', () async {
    final repository = midiPatchRecentRepository(database);
    var second = 0;
    DateTime tick() => DateTime(2026).add(Duration(seconds: second++));
    await repository.recordUsed(firstPatchId, clock: tick);
    await repository.recordUsed(secondPatchId, clock: tick);

    await repository.recordUsed(firstPatchId, clock: tick);

    final recents = await repository.watchRecents().first;
    expect(recents.map((r) => r.patchId), [firstPatchId, secondPatchId]);
  });

  group('recentNumberedPatches', () {
    test(
      'cross-references recents against numbered patches, newest first',
      () async {
        await midiPatchProgramRepository(
          database,
        ).setNumber(patchId: firstPatchId, programNumber: 1);
        await midiPatchProgramRepository(
          database,
        ).setNumber(patchId: secondPatchId, programNumber: 2);
        final numbered = await midiPatchProgramRepository(
          database,
        ).watchNumberedPatches(unitId).first;

        final repository = midiPatchRecentRepository(database);
        var second = 0;
        DateTime tick() => DateTime(2026).add(Duration(seconds: second++));
        await repository.recordUsed(firstPatchId, clock: tick);
        await repository.recordUsed(secondPatchId, clock: tick);
        final recents = await repository.watchRecents().first;

        final result = recentNumberedPatches(numbered, recents: recents);

        expect(result.map((n) => n.patch.id), [secondPatchId, firstPatchId]);
      },
    );

    test(
      'leaves out a recent whose patch no longer has a program number',
      () async {
        await midiPatchProgramRepository(
          database,
        ).setNumber(patchId: firstPatchId, programNumber: 1);
        final numbered = await midiPatchProgramRepository(
          database,
        ).watchNumberedPatches(unitId).first;

        final repository = midiPatchRecentRepository(database);
        await repository.recordUsed(firstPatchId);
        await repository.recordUsed(secondPatchId);
        final recents = await repository.watchRecents().first;

        final result = recentNumberedPatches(numbered, recents: recents);

        expect(result.map((n) => n.patch.id), [firstPatchId]);
      },
    );
  });
}
