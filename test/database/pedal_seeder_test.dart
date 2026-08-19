import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/pedal_dao.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/pedals/data/dev_seed_pedals.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_repository.dart';
import 'package:tone_vault/features/pedals/data/pedal_seeder.dart';

void main() {
  late AppDatabase database;
  late PedalRepository repository;
  late PedalSeeder seeder;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = PedalRepository(PedalDao(database));
    seeder = PedalSeeder(repository);
  });

  tearDown(() => database.close());

  test('adds every sample pedal to an empty inventory', () async {
    final added = await seeder.seed();

    expect(added, devSeedPedals.length);
    final pedals = await repository.watchPedals().first;
    expect(pedals, hasLength(devSeedPedals.length));
    expect(
      pedals.map((pedal) => pedal.name),
      containsAll(['Caline PureSky', 'NUX MG-30', 'Flamma FC03']),
    );
  });

  test('refuses to run twice, which would duplicate every pedal', () async {
    await seeder.seed();

    await expectLater(seeder.seed(), throwsA(isA<AppFailure>()));
    expect(
      await repository.watchPedals().first,
      hasLength(devSeedPedals.length),
    );
  });

  test('refuses when the inventory has any pedal in it', () async {
    await repository.createPedal(
      const PedalDraft(
        name: 'Boss DS-1',
        type: PedalType.analog,
        category: PedalCategory.distortion,
      ),
    );

    await expectLater(seeder.seed(), throwsA(isA<AppFailure>()));
    expect(await repository.watchPedals().first, hasLength(1));
  });

  test('every sample pedal passes validation', () async {
    // Seed data goes through the repository, so a bad entry here would be a
    // failed write rather than a silently odd row.
    await seeder.seed();

    final pedals = await repository.watchPedals().first;
    for (final pedal in pedals) {
      expect(pedal.brand, isNotNull, reason: '${pedal.name} has no brand');
    }
  });
}
