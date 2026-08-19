import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/pedal_dao.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_repository.dart';

void main() {
  late AppDatabase database;
  late PedalRepository repository;
  late DateTime now;

  setUp(() {
    now = DateTime.utc(2026, 8, 19, 10);
    database = AppDatabase(NativeDatabase.memory());
    repository = PedalRepository(PedalDao(database), clock: () => now);
  });

  tearDown(() => database.close());

  const draft = PedalDraft(
    name: 'Caline PureSky',
    type: PedalType.analog,
    category: PedalCategory.overdrive,
    brand: 'Caline',
  );

  Future<Pedal> readPedal(int pedalId) {
    return (database.select(
      database.pedals,
    )..where((row) => row.id.equals(pedalId))).getSingle();
  }

  group('createPedal', () {
    test('stores the pedal and stamps both timestamps', () async {
      final pedalId = await repository.createPedal(draft);
      final pedal = await readPedal(pedalId);

      expect(pedal.name, 'Caline PureSky');
      expect(pedal.brand, 'Caline');
      expect(pedal.type, PedalType.analog);
      expect(pedal.category, PedalCategory.overdrive);
      expect(pedal.status, PedalStatus.active);
      expect(pedal.createdAt, now);
      expect(pedal.updatedAt, now);
    });

    test('normalizes input before storing it', () async {
      final pedalId = await repository.createPedal(
        const PedalDraft(
          name: '  Mooer Yellow Comp  ',
          type: PedalType.analog,
          category: PedalCategory.compressor,
          brand: '   ',
          notes: '',
        ),
      );
      final pedal = await readPedal(pedalId);

      expect(pedal.name, 'Mooer Yellow Comp');
      expect(pedal.brand, isNull);
      expect(pedal.notes, isNull);
    });

    test('rejects a blank name without writing a row', () async {
      await expectLater(
        repository.createPedal(
          const PedalDraft(
            name: '   ',
            type: PedalType.digital,
            category: PedalCategory.reverb,
          ),
        ),
        throwsA(isA<AppFailure>()),
      );

      final pedals = await database.select(database.pedals).get();
      expect(pedals, isEmpty);
    });

    test('rejects a purchase date in the future', () async {
      await expectLater(
        repository.createPedal(
          PedalDraft(
            name: 'NUX MG-30',
            type: PedalType.digital,
            category: PedalCategory.multiEffects,
            purchaseDate: now.add(const Duration(days: 1)),
          ),
        ),
        throwsA(isA<AppFailure>()),
      );
    });
  });

  group('updatePedal', () {
    test('applies changes and bumps updatedAt but keeps createdAt', () async {
      final pedalId = await repository.createPedal(draft);
      final createdAt = (await readPedal(pedalId)).createdAt;

      now = now.add(const Duration(days: 2));
      await repository.updatePedal(
        pedalId,
        const PedalDraft(
          name: 'Caline PureSky',
          type: PedalType.analog,
          category: PedalCategory.reverb,
          status: PedalStatus.backup,
        ),
      );

      final pedal = await readPedal(pedalId);
      expect(pedal.category, PedalCategory.reverb);
      expect(pedal.status, PedalStatus.backup);
      expect(pedal.brand, isNull, reason: 'a cleared brand should be unset');
      expect(pedal.createdAt, createdAt);
      expect(pedal.updatedAt, now);
    });

    test('fails when the pedal is gone', () async {
      await expectLater(
        repository.updatePedal(404, draft),
        throwsA(isA<AppFailure>()),
      );
    });
  });

  group('deletePedal', () {
    test('removes a pedal nothing references', () async {
      final pedalId = await repository.createPedal(draft);
      await repository.deletePedal(pedalId);

      expect(await database.select(database.pedals).get(), isEmpty);
    });

    test('fails when the pedal is gone', () async {
      await expectLater(
        repository.deletePedal(404),
        throwsA(isA<AppFailure>()),
      );
    });

    test('refuses to delete a pedal that has a configuration', () async {
      final pedalId = await repository.createPedal(draft);
      await database
          .into(database.configurations)
          .insert(
            ConfigurationsCompanion.insert(
              pedalId: pedalId,
              name: 'Worship Lead',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await expectLater(
        repository.deletePedal(pedalId),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.message,
            'message',
            contains('Change its status'),
          ),
        ),
      );

      expect(await database.select(database.pedals).get(), hasLength(1));
    });
  });

  group('watchPedals', () {
    test('orders by name regardless of case', () async {
      for (final name in ['joyo American Sound', 'Zoom MS-50G', 'Boss DS-1']) {
        await repository.createPedal(
          PedalDraft(
            name: name,
            type: PedalType.analog,
            category: PedalCategory.other,
          ),
        );
      }

      final pedals = await repository.watchPedals().first;
      expect(pedals.map((pedal) => pedal.name), [
        'Boss DS-1',
        'joyo American Sound',
        'Zoom MS-50G',
      ]);
    });

    test('emits again when a pedal is added', () async {
      final counts = <int>[];
      final subscription = repository.watchPedals().listen(
        (pedals) => counts.add(pedals.length),
      );

      // Wait for the initial query to land before writing, otherwise the insert
      // can beat the first emission and the assertion becomes a coin toss.
      await pumpEventQueue();
      expect(counts, [0]);

      await repository.createPedal(draft);
      await pumpEventQueue();
      expect(counts, [0, 1]);

      await subscription.cancel();
    });
  });
}
