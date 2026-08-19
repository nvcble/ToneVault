import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/pedal_dao.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_repository.dart';
import 'package:tone_vault/features/pedals/providers/pedal_editor.dart';

void main() {
  late AppDatabase database;
  late PedalRepository repository;
  late PedalEditor editor;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = PedalRepository(PedalDao(database));
    editor = PedalEditor(repository);
  });

  tearDown(() => database.close());

  const draft = PedalDraft(
    name: 'Caline PureSky',
    type: PedalType.analog,
    category: PedalCategory.overdrive,
  );

  test('save without an id adds a pedal', () async {
    await editor.save(draft);

    final pedals = await repository.watchPedals().first;
    expect(pedals.map((pedal) => pedal.name), ['Caline PureSky']);
  });

  test(
    'save with an id changes that pedal instead of adding another',
    () async {
      await editor.save(draft);
      final pedalId = (await repository.watchPedals().first).single.id;

      await editor.save(
        const PedalDraft(
          name: 'Caline PureSky',
          type: PedalType.analog,
          category: PedalCategory.overdrive,
          status: PedalStatus.backup,
        ),
        pedalId: pedalId,
      );

      final pedals = await repository.watchPedals().first;
      expect(pedals, hasLength(1));
      expect(pedals.single.status, PedalStatus.backup);
    },
  );

  test('delete removes the pedal', () async {
    await editor.save(draft);
    final pedalId = (await repository.watchPedals().first).single.id;

    await editor.delete(pedalId);

    expect(await repository.watchPedals().first, isEmpty);
  });
}
