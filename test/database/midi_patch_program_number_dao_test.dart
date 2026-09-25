import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/patches/data/patch_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';

import '../support/repositories.dart';

void main() {
  late AppDatabase database;
  late int unitId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    unitId = await pedalRepository(database).createPedal(
      const PedalDraft(
        name: 'NUX MG-30 (V5)',
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
      ),
    );
  });

  tearDown(() => database.close());

  test(
    'orders numbered patches by their program number, not creation order',
    () async {
      final second = await patchRepository(
        database,
      ).createPatch(unitId, const PatchDraft(name: 'Second'));
      final first = await patchRepository(
        database,
      ).createPatch(unitId, const PatchDraft(name: 'First'));
      await midiPatchProgramRepository(
        database,
      ).setNumber(patchId: second, programNumber: 2);
      await midiPatchProgramRepository(
        database,
      ).setNumber(patchId: first, programNumber: 1);

      final numbered = await midiPatchProgramRepository(
        database,
      ).watchNumberedPatches(unitId).first;

      expect(numbered.map((n) => n.patch.name), ['First', 'Second']);
      expect(numbered.map((n) => n.programNumber), [1, 2]);
    },
  );

  test('leaves out a patch with no program number', () async {
    final numberedId = await patchRepository(
      database,
    ).createPatch(unitId, const PatchDraft(name: 'Numbered'));
    await patchRepository(
      database,
    ).createPatch(unitId, const PatchDraft(name: 'Unnumbered'));
    await midiPatchProgramRepository(
      database,
    ).setNumber(patchId: numberedId, programNumber: 1);

    final numbered = await midiPatchProgramRepository(
      database,
    ).watchNumberedPatches(unitId).first;

    expect(numbered.map((n) => n.patch.name), ['Numbered']);
  });

  test('leaves out numbered patches belonging to a different unit', () async {
    final otherUnitId = await pedalRepository(database).createPedal(
      const PedalDraft(
        name: 'Another unit',
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
      ),
    );
    final otherPatchId = await patchRepository(
      database,
    ).createPatch(otherUnitId, const PatchDraft(name: 'Elsewhere'));
    await midiPatchProgramRepository(
      database,
    ).setNumber(patchId: otherPatchId, programNumber: 1);

    final numbered = await midiPatchProgramRepository(
      database,
    ).watchNumberedPatches(unitId).first;

    expect(numbered, isEmpty);
  });
}
