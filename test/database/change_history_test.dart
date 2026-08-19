import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/change_log_dao.dart';
import 'package:tone_vault/core/enums/change_type.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/configurations/data/configuration_draft.dart';
import 'package:tone_vault/features/controls/data/control_draft.dart';
import 'package:tone_vault/features/history/data/change_entry.dart';
import 'package:tone_vault/features/history/data/change_log_repository.dart';
import 'package:tone_vault/features/pedals/data/pedal_draft.dart';
import '../support/repositories.dart';

/// A change log that refuses to write, to prove the change is rolled back with
/// it rather than left behind with no record of itself.
class _BrokenChangeLog extends ChangeLogRepository {
  _BrokenChangeLog(super.dao);

  @override
  Future<void> record(ChangeEntry entry) async => throw Exception('disk gone');
}

/// What each edit leaves behind in the history.
void main() {
  late AppDatabase database;
  late int pedalId;
  late int volumeId;
  late int configurationId;

  /// Oldest first, so a test reads down the timeline in the order it happened.
  Future<List<ChangeLog>> history() async {
    final entries = await database.changeLogDao.entriesOf(pedalId);
    return entries..sort((a, b) => a.id.compareTo(b.id));
  }

  Future<List<ChangeLog>> entriesOfType(ChangeType type) async =>
      (await history()).where((entry) => entry.changeType == type).toList();

  /// Most of these tests move the one knob the pedal starts out with.
  Future<void> setVolume(double value, {String? reason}) =>
      configurationValueRepository(database).setValue(
        configurationId: configurationId,
        controlId: volumeId,
        value: value,
        reason: reason,
      );

  Future<void> clearVolume({String? reason}) =>
      configurationValueRepository(database).clearValue(
        configurationId: configurationId,
        controlId: volumeId,
        reason: reason,
      );

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());

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
    configurationId = await configurationRepository(database)
        .createConfiguration(
          pedalId,
          const ConfigurationDraft(name: 'Worship Lead'),
        );
  });

  tearDown(() => database.close());

  test('records the control and the configuration as they arrived', () async {
    final entries = await history();

    expect(entries.map((entry) => entry.changeType), [
      ChangeType.controlAdded,
      ChangeType.configurationCreated,
    ]);
    expect(entries.first.controlName, 'Volume');
    expect(entries.last.configurationName, 'Worship Lead');
  });

  test('records a control leaving by name, not by id', () async {
    await controlRepository(database).deleteControl(volumeId);

    final removal = (await history()).last;
    expect(removal.changeType, ChangeType.controlRemoved);
    // The control is gone, so the name is the only thing left that reads.
    expect(removal.controlName, 'Volume');
    expect(removal.controlId, isNull);
  });

  test('records a knob moving, with the reason given for it', () async {
    await setVolume(0.5);
    await setVolume(0.75, reason: 'needed more saturation for lead');

    final moves = await entriesOfType(ChangeType.controlValueChanged);

    // Stored as numbers in the control's own domain; a reading is rendered from
    // the control, never written into the log.
    expect(moves.first.oldValue, isNull);
    expect(moves.first.newValue, 0.5);
    expect(moves.last.oldValue, 0.5);
    expect(moves.last.newValue, 0.75);
    expect(moves.last.reason, 'needed more saturation for lead');
    expect(moves.last.controlName, 'Volume');
  });

  test('records nothing when a knob is saved where it already sits', () async {
    await setVolume(0.5);
    final before = (await history()).length;
    await setVolume(0.5);

    // Saving a control into the position it is already in is not a change.
    expect(await history(), hasLength(before));
  });

  test('records a cleared control as having no position now', () async {
    await setVolume(0.5);

    await clearVolume(reason: 'set by ear from now on');

    final cleared = (await history()).last;
    expect(cleared.oldValue, 0.5);
    expect(cleared.newValue, isNull);
    expect(cleared.reason, 'set by ear from now on');
  });

  test('records nothing when clearing a control that was never set', () async {
    final before = (await history()).length;

    await clearVolume();

    expect(await history(), hasLength(before));
  });

  test('records a rename but not a rewritten note', () async {
    final configurations = configurationRepository(database);

    await configurations.updateConfiguration(
      configurationId,
      const ConfigurationDraft(name: 'Lead', notes: 'Bridge only'),
    );
    await configurations.updateConfiguration(
      configurationId,
      const ConfigurationDraft(name: 'Lead', notes: 'Bridge and chorus'),
    );

    // Notes are the user describing a configuration, not changing it.
    final renames = await entriesOfType(ChangeType.configurationRenamed);
    expect(renames, hasLength(1));
    expect(renames.single.oldText, 'Worship Lead');
    expect(renames.single.newText, 'Lead');
  });

  test('outlives the configuration it was recorded against', () async {
    await setVolume(0.5);

    await configurationRepository(
      database,
    ).deleteConfiguration(configurationId);

    // The foreign keys let go, and the copied name is what keeps every entry
    // about this configuration readable. Adding the control is the one entry
    // here that was never about a configuration at all.
    final entries = (await history())
        .where((entry) => entry.changeType != ChangeType.controlAdded)
        .toList();
    expect(entries.map((entry) => entry.changeType), [
      ChangeType.configurationCreated,
      ChangeType.controlValueChanged,
      ChangeType.configurationDeleted,
    ]);
    expect(
      entries.every((entry) => entry.configurationName == 'Worship Lead'),
      isTrue,
    );
    expect(entries.every((entry) => entry.configurationId == null), isTrue);
  });

  test('records a status change but not an edited brand', () async {
    final pedals = pedalRepository(database);
    PedalDraft branded({PedalStatus status = PedalStatus.active}) => PedalDraft(
      name: 'Caline PureSky',
      brand: 'Caline',
      type: PedalType.analog,
      category: PedalCategory.overdrive,
      status: status,
    );

    // Filling in the brand corrects the record of the pedal; moving it to the
    // backup bag is something that happened to the rig.
    await pedals.updatePedal(pedalId, branded());
    await pedals.updatePedal(pedalId, branded(status: PedalStatus.backup));

    final statusChanges = await entriesOfType(ChangeType.pedalStatusChanged);
    expect(statusChanges, hasLength(1));
    expect(statusChanges.single.oldText, 'Active');
    expect(statusChanges.single.newText, 'Backup');
  });

  test('leaves the change undone when it cannot be recorded', () async {
    final controls = controlRepository(
      database,
      changeLog: _BrokenChangeLog(ChangeLogDao(database)),
    );

    await expectLater(
      controls.createControl(
        pedalId,
        ControlDraft.ofType(ControlType.clock, name: 'Tone'),
      ),
      throwsA(isNotNull),
    );

    // One transaction covers the change and its history entry, so an unrecorded
    // change is no change at all.
    final controlNames = (await database.pedalControlDao.controlsOf(
      pedalId,
    )).map((control) => control.name);
    expect(controlNames, ['Volume']);
  });
}
