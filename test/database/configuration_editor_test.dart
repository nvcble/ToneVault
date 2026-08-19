import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/pedal_control_dao.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/configurations/data/configuration_draft.dart';
import 'package:tone_vault/features/configurations/providers/configuration_editor.dart';
import 'package:tone_vault/features/controls/data/control_draft.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import '../support/repositories.dart';

/// What the configuration screens do when a button is pressed. The repository
/// rules themselves are covered by configuration_repository_test.dart.
void main() {
  late AppDatabase database;
  late ConfigurationEditor editor;
  late int pedalId;
  late int volumeId;
  late int toneId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    editor = ConfigurationEditor(
      configurationRepository(database),
      configurationValueRepository(database),
      PedalControlDao(database),
    );

    pedalId = await pedalRepository(database).createPedal(
      const PedalDraft(
        name: 'Caline PureSky',
        type: PedalType.analog,
        category: PedalCategory.overdrive,
      ),
    );

    final controls = controlRepository(database);
    volumeId = await controls.createControl(
      pedalId,
      const ControlDraft(
        name: 'Volume',
        type: ControlType.clock,
        minValue: 0,
        maxValue: 1,
        step: 0.05,
        defaultValue: 0.75,
      ),
    );
    // No default: this knob is set by ear rather than to a marked position.
    toneId = await controls.createControl(
      pedalId,
      ControlDraft.ofType(ControlType.clock, name: 'Tone'),
    );
  });

  tearDown(() => database.close());

  test(
    'starts a new configuration on the defaults its controls declare',
    () async {
      final configurationId = await editor.save(
        const ConfigurationDraft(name: 'Worship Lead'),
        pedalId: pedalId,
      );

      final values = await database.configurationDao.valuesOf(configurationId);
      expect(values.single.controlId, volumeId);
      expect(values.single.value, 0.75);
      // A control with no default is honestly unset rather than assumed to be at
      // one end of its sweep.
      expect(values.map((value) => value.controlId), isNot(contains(toneId)));
    },
  );

  test('leaves the positions alone when a configuration is renamed', () async {
    final configurationId = await editor.save(
      const ConfigurationDraft(name: 'Worship Lead'),
      pedalId: pedalId,
    );

    final sameId = await editor.save(
      const ConfigurationDraft(name: 'Lead', notes: 'Bridge only'),
      pedalId: pedalId,
      configurationId: configurationId,
    );

    // The same configuration, so the screen it opens afterwards is the one that
    // was just renamed.
    expect(sameId, configurationId);
    final stored = await database.configurationDao.findConfiguration(sameId);
    expect(stored?.name, 'Lead');
    expect(await database.configurationDao.valuesOf(sameId), hasLength(1));
  });

  test('sets and clears one control at a time', () async {
    final configurationId = await editor.save(
      const ConfigurationDraft(name: 'Worship Lead'),
      pedalId: pedalId,
    );

    await editor.setValue(
      configurationId: configurationId,
      controlId: toneId,
      value: 0.25,
    );
    expect(
      await database.configurationDao.valuesOf(configurationId),
      hasLength(2),
    );

    await editor.clearValue(
      configurationId: configurationId,
      controlId: toneId,
    );

    final values = await database.configurationDao.valuesOf(configurationId);
    expect(values.single.controlId, volumeId);
  });
}
