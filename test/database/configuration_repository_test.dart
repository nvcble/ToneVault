import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/configurations/data/configuration_draft.dart';
import 'package:tone_vault/features/configurations/data/configuration_repository.dart';
import 'package:tone_vault/features/controls/data/control_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import '../support/repositories.dart';

/// Naming, renaming and deleting a configuration. Setting the positions it
/// holds is covered by configuration_value_test.dart.
void main() {
  late AppDatabase database;
  late ConfigurationRepository repository;
  late int pedalId;
  late int volumeId;
  var now = DateTime.utc(2026, 8, 19, 10);

  setUp(() async {
    now = DateTime.utc(2026, 8, 19, 10);
    database = AppDatabase(NativeDatabase.memory());
    repository = configurationRepository(database, clock: () => now);

    pedalId = await pedalRepository(database).createPedal(
      const PedalDraft(
        name: 'Caline PureSky',
        type: PedalType.analog,
        category: PedalCategory.overdrive,
      ),
    );
    volumeId = await controlRepository(database).createControl(
      pedalId,
      ControlDraft.ofType(ControlType.clock, name: 'Volume'),
    );
  });

  tearDown(() => database.close());

  group('createConfiguration', () {
    test('stores it under a trimmed name, timestamped', () async {
      final id = await repository.createConfiguration(
        pedalId,
        const ConfigurationDraft(name: '  Worship Lead  ', notes: '   '),
      );

      final stored = await database.configurationDao.findConfiguration(id);
      expect(stored?.name, 'Worship Lead');
      // Blank notes are absent rather than an empty string.
      expect(stored?.notes, isNull);
      expect(stored?.createdAt, now);
      expect(stored?.updatedAt, now);
    });

    test('stores the positions it starts out with', () async {
      final id = await repository.createConfiguration(
        pedalId,
        ConfigurationDraft(name: 'Clean Boost', values: {volumeId: 0.75}),
      );

      final values = await database.configurationDao.valuesOf(id);
      expect(values.single.controlId, volumeId);
      expect(values.single.value, 0.75);
    });

    test('reports a configuration without a name', () async {
      await expectLater(
        repository.createConfiguration(
          pedalId,
          const ConfigurationDraft(name: '  '),
        ),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.message,
            'message',
            'Enter a configuration name.',
          ),
        ),
      );
    });

    test('reports a name the pedal already uses, whatever its case', () async {
      await repository.createConfiguration(
        pedalId,
        const ConfigurationDraft(name: 'Worship Lead'),
      );

      await expectLater(
        repository.createConfiguration(
          pedalId,
          const ConfigurationDraft(name: 'worship lead'),
        ),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.message,
            'message',
            'This pedal already has a configuration called "worship lead".',
          ),
        ),
      );
    });

    test('refuses a starting position the control cannot be in', () async {
      // A clock knob stores 0..1, so 1.5 is past the end stop.
      await expectLater(
        repository.createConfiguration(
          pedalId,
          ConfigurationDraft(name: 'Impossible', values: {volumeId: 1.5}),
        ),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.message,
            'message',
            'Volume cannot be set to that.',
          ),
        ),
      );
    });

    test('refuses a control that belongs to another pedal', () async {
      final otherPedal = await pedalRepository(database).createPedal(
        const PedalDraft(
          name: 'NUX MG-30',
          type: PedalType.digital,
          category: PedalCategory.multiEffects,
        ),
      );
      final otherControl = await controlRepository(database).createControl(
        otherPedal,
        ControlDraft.ofType(ControlType.clock, name: 'Volume'),
      );

      await expectLater(
        repository.createConfiguration(
          pedalId,
          ConfigurationDraft(name: 'Borrowed', values: {otherControl: 0.5}),
        ),
        throwsA(isA<AppFailure>()),
      );
    });
  });

  group('updateConfiguration', () {
    test('renames it and moves its timestamp, keeping its positions', () async {
      final id = await repository.createConfiguration(
        pedalId,
        ConfigurationDraft(name: 'Worship Lead', values: {volumeId: 0.5}),
      );

      now = DateTime.utc(2026, 8, 20, 11);
      await repository.updateConfiguration(
        id,
        const ConfigurationDraft(name: 'Lead', notes: 'Bridge only'),
      );

      final stored = await database.configurationDao.findConfiguration(id);
      expect(stored?.name, 'Lead');
      expect(stored?.notes, 'Bridge only');
      expect(stored?.createdAt, DateTime.utc(2026, 8, 19, 10));
      expect(stored?.updatedAt, now);
      // Renaming is not a settings change.
      expect(await database.configurationDao.valuesOf(id), hasLength(1));
    });

    test('lets a configuration keep its own name', () async {
      final id = await repository.createConfiguration(
        pedalId,
        const ConfigurationDraft(name: 'Worship Lead'),
      );

      await repository.updateConfiguration(
        id,
        const ConfigurationDraft(name: 'Worship Lead', notes: 'Verses'),
      );

      final stored = await database.configurationDao.findConfiguration(id);
      expect(stored?.notes, 'Verses');
    });

    test('reports a configuration that is already gone', () async {
      await expectLater(
        repository.updateConfiguration(
          404,
          const ConfigurationDraft(name: 'Ghost'),
        ),
        throwsA(isA<AppFailure>()),
      );
    });
  });

  group('deleteConfiguration', () {
    test('takes the positions it held with it', () async {
      final id = await repository.createConfiguration(
        pedalId,
        ConfigurationDraft(name: 'Worship Lead', values: {volumeId: 0.5}),
      );

      await repository.deleteConfiguration(id);

      expect(
        await database.configurationDao.configurationsOf(pedalId),
        isEmpty,
      );
      expect(await database.configurationDao.valuesOf(id), isEmpty);
    });

    test('reports a configuration that is already gone', () async {
      await expectLater(
        repository.deleteConfiguration(404),
        throwsA(isA<AppFailure>()),
      );
    });
  });
}
