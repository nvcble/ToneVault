import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/configuration_dao.dart';
import 'package:tone_vault/core/database/daos/pedal_control_dao.dart';
import 'package:tone_vault/core/database/daos/pedal_dao.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/core/errors/app_failure.dart';
import 'package:tone_vault/features/configurations/data/configuration_draft.dart';
import 'package:tone_vault/features/configurations/data/configuration_repository.dart';
import 'package:tone_vault/features/controls/data/control_draft.dart';
import 'package:tone_vault/features/controls/data/control_repository.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_repository.dart';

/// Where each control sits within one configuration.
void main() {
  late AppDatabase database;
  late ControlRepository controls;
  late ConfigurationRepository repository;
  late int pedalId;
  late int volumeId;
  late int configurationId;
  var now = DateTime.utc(2026, 8, 19, 10);

  setUp(() async {
    now = DateTime.utc(2026, 8, 19, 10);
    database = AppDatabase(NativeDatabase.memory());
    controls = ControlRepository(PedalControlDao(database));
    repository = ConfigurationRepository(
      ConfigurationDao(database),
      PedalControlDao(database),
      clock: () => now,
    );

    pedalId = await PedalRepository(PedalDao(database)).createPedal(
      const PedalDraft(
        name: 'Caline PureSky',
        type: PedalType.analog,
        category: PedalCategory.overdrive,
      ),
    );
    volumeId = await controls.createControl(
      pedalId,
      ControlDraft.ofType(ControlType.clock, name: 'Volume'),
    );
    configurationId = await repository.createConfiguration(
      pedalId,
      const ConfigurationDraft(name: 'Worship Lead'),
    );
  });

  tearDown(() => database.close());

  Future<double?> storedValue(int controlId) async {
    final values = await database.configurationDao.valuesOf(configurationId);
    return values
        .where((value) => value.controlId == controlId)
        .map((value) => value.value)
        .firstOrNull;
  }

  group('setValue', () {
    test('records where the control sits', () async {
      await repository.setValue(
        configurationId: configurationId,
        controlId: volumeId,
        value: 0.75,
      );

      expect(await storedValue(volumeId), 0.75);
    });

    test('moves the control rather than storing it twice', () async {
      await repository.setValue(
        configurationId: configurationId,
        controlId: volumeId,
        value: 0.25,
      );
      await repository.setValue(
        configurationId: configurationId,
        controlId: volumeId,
        value: 0.5,
      );

      // The {configurationId, controlId} unique key is what keeps a knob to one
      // position per configuration.
      final values = await database.configurationDao.valuesOf(configurationId);
      expect(values, hasLength(1));
      expect(values.single.value, 0.5);
    });

    test('marks the configuration as changed', () async {
      now = DateTime.utc(2026, 8, 20, 11);

      await repository.setValue(
        configurationId: configurationId,
        controlId: volumeId,
        value: 0.5,
      );

      final stored = await database.configurationDao.findConfiguration(
        configurationId,
      );
      expect(stored?.updatedAt, now);
    });

    test('refuses a position outside the control\'s own domain', () async {
      await expectLater(
        repository.setValue(
          configurationId: configurationId,
          controlId: volumeId,
          value: -0.1,
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

    test('refuses a position between two positions of a selection', () async {
      final modeId = await controls.createControl(
        pedalId,
        const ControlDraft(
          name: 'Mode',
          type: ControlType.selection,
          minValue: 0,
          maxValue: 0,
          options: ['Bright', 'Dark'],
        ),
      );

      await expectLater(
        repository.setValue(
          configurationId: configurationId,
          controlId: modeId,
          value: 0.5,
        ),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.message,
            'message',
            'Pick one of Mode\'s positions.',
          ),
        ),
      );
    });

    test('refuses a control from another pedal', () async {
      final otherPedal = await PedalRepository(PedalDao(database)).createPedal(
        const PedalDraft(
          name: 'NUX MG-30',
          type: PedalType.digital,
          category: PedalCategory.multiEffects,
        ),
      );
      final otherControl = await controls.createControl(
        otherPedal,
        ControlDraft.ofType(ControlType.clock, name: 'Volume'),
      );

      await expectLater(
        repository.setValue(
          configurationId: configurationId,
          controlId: otherControl,
          value: 0.5,
        ),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.message,
            'message',
            'That control is no longer on this pedal.',
          ),
        ),
      );
    });

    test('reports a configuration that is already gone', () async {
      await expectLater(
        repository.setValue(
          configurationId: 404,
          controlId: volumeId,
          value: 0.5,
        ),
        throwsA(isA<AppFailure>()),
      );
    });
  });

  group('clearValue', () {
    test('leaves the control unset and the others alone', () async {
      final toneId = await controls.createControl(
        pedalId,
        ControlDraft.ofType(ControlType.clock, name: 'Tone'),
      );
      await repository.setValue(
        configurationId: configurationId,
        controlId: volumeId,
        value: 0.5,
      );
      await repository.setValue(
        configurationId: configurationId,
        controlId: toneId,
        value: 0.25,
      );

      await repository.clearValue(
        configurationId: configurationId,
        controlId: volumeId,
      );

      expect(await storedValue(volumeId), isNull);
      expect(await storedValue(toneId), 0.25);
    });

    test('accepts a control that was never set', () async {
      await repository.clearValue(
        configurationId: configurationId,
        controlId: volumeId,
      );

      expect(await storedValue(volumeId), isNull);
    });
  });
}
