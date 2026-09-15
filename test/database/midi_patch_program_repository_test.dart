import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/patches/data/patch_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';

import '../support/repositories.dart';

void main() {
  late AppDatabase database;
  late int patchId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    final unitId = await pedalRepository(database).createPedal(
      const PedalDraft(
        name: 'NUX MG-30 (V5)',
        type: PedalType.digital,
        category: PedalCategory.multiEffects,
      ),
    );
    patchId = await patchRepository(
      database,
    ).createPatch(unitId, const PatchDraft(name: 'Worship Lead'));
  });

  tearDown(() => database.close());

  test('has no number until one is set', () async {
    final repository = midiPatchProgramRepository(database);

    final number = await repository.watchNumber(patchId).first;

    expect(number, isNull);
  });

  test('setNumber stores the program number', () async {
    final repository = midiPatchProgramRepository(database);

    await repository.setNumber(patchId: patchId, programNumber: 21);

    final number = await repository.watchNumber(patchId).first;
    expect(number!.programNumber, 21);
  });

  test('refuses a number outside 1-128', () async {
    final repository = midiPatchProgramRepository(database);

    await expectLater(
      repository.setNumber(patchId: patchId, programNumber: 0),
      throwsA(isA<AppFailure>()),
    );
    await expectLater(
      repository.setNumber(patchId: patchId, programNumber: 129),
      throwsA(isA<AppFailure>()),
    );
  });

  test('clearNumber removes it', () async {
    final repository = midiPatchProgramRepository(database);
    await repository.setNumber(patchId: patchId, programNumber: 21);

    await repository.clearNumber(patchId);

    final number = await repository.watchNumber(patchId).first;
    expect(number, isNull);
  });
}
