import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/change_type.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/history/data/change_entry.dart';

/// Which columns each kind of event fills in. The point of the named
/// constructors is that a caller cannot fill in the wrong ones.
void main() {
  final timestamp = DateTime.utc(2026, 8, 19, 12);

  final pedal = Pedal(
    id: 7,
    name: 'Caline PureSky',
    type: PedalType.analog,
    category: PedalCategory.overdrive,
    status: PedalStatus.backup,
    createdAt: timestamp,
    updatedAt: timestamp,
  );

  final configuration = Configuration(
    id: 11,
    pedalId: pedal.id,
    name: 'Worship Lead',
    createdAt: timestamp,
    updatedAt: timestamp,
  );

  final control = PedalControl(
    id: 3,
    pedalId: pedal.id,
    name: 'Volume',
    controlType: ControlType.clock,
    minValue: 0,
    maxValue: 1,
    displayOrder: 0,
  );

  test('a moved control records the transition in its own domain', () {
    final entry = ChangeEntry.controlValueChanged(
      configuration: configuration,
      control: control,
      controlPedal: pedal,
      oldValue: 0.5,
      newValue: 0.75,
      reason: 'needed more saturation for lead',
    );

    // The pedal is taken from the configuration, so the entry cannot be filed
    // against a pedal the configuration does not belong to.
    expect(entry.pedalId, pedal.id);
    expect(entry.changeType, ChangeType.controlValueChanged);
    expect(entry.controlName, 'Volume');
    expect(entry.configurationName, 'Worship Lead');
    expect(entry.oldValue, 0.5);
    expect(entry.newValue, 0.75);
    expect(entry.reason, 'needed more saturation for lead');
    // Numbers, not readings: the reading is rendered from the control later.
    expect(entry.oldText, isNull);
    expect(entry.newText, isNull);
  });

  test('a control set for the first time has nothing to come from', () {
    final entry = ChangeEntry.controlValueChanged(
      configuration: configuration,
      control: control,
      controlPedal: pedal,
      oldValue: null,
      newValue: 0.25,
    );

    expect(entry.oldValue, isNull);
    expect(entry.newValue, 0.25);
  });

  test('a cleared control records that it has no position now', () {
    final entry = ChangeEntry.controlValueChanged(
      configuration: configuration,
      control: control,
      controlPedal: pedal,
      oldValue: 0.25,
      newValue: null,
    );

    expect(entry.oldValue, 0.25);
    expect(entry.newValue, isNull);
  });

  test('a control on the pedal being configured needs no naming', () {
    final entry = ChangeEntry.controlValueChanged(
      configuration: configuration,
      control: control,
      controlPedal: pedal,
      oldValue: null,
      newValue: 0.5,
    );

    // The pedal is already the one whose history this lands in, so saying it
    // again would only take up the width of the row.
    expect(entry.controlPedalName, isNull);
  });

  test('a control on a pedal inside the unit is named', () {
    // A scene of a multi-effects unit in scene mode: the configuration is the
    // unit's, and the control it moved is on one of the pedals on its patch.
    final scene = configuration.copyWith(pedalId: 40, name: 'Chorus scene');
    final patchPedal = pedal.copyWith(id: 8, name: 'Tube Screamer');

    final entry = ChangeEntry.controlValueChanged(
      configuration: scene,
      control: control,
      controlPedal: patchPedal,
      oldValue: null,
      newValue: 0.5,
    );

    // Filed under the unit, because the unit is what changed sound, and the
    // pedal named because it is the only thing that says which Volume moved.
    expect(entry.pedalId, 40);
    expect(entry.controlPedalName, 'Tube Screamer');
  });

  test('a rename records both names', () {
    final entry = ChangeEntry.configurationRenamed(
      configuration: configuration,
      previousName: 'Lead',
    );

    expect(entry.oldText, 'Lead');
    expect(entry.newText, 'Worship Lead');
    expect(entry.configurationId, configuration.id);
    // A rename moves no knob, so there is no numeric transition to show.
    expect(entry.oldValue, isNull);
  });

  test('a status change records the labels the user was shown', () {
    final entry = ChangeEntry.pedalStatusChanged(
      pedal: pedal,
      previousStatus: PedalStatus.active,
      reason: 'moved to the backup board',
    );

    expect(entry.pedalId, pedal.id);
    expect(entry.oldText, 'Active');
    expect(entry.newText, 'Backup');
    expect(entry.reason, 'moved to the backup board');
  });

  test('a removal keeps the name and lets go of the id', () {
    final removedConfiguration = ChangeEntry.configurationDeleted(
      configuration,
    );
    final removedControl = ChangeEntry.controlRemoved(control);

    // The rows are about to go, and the foreign keys would be nulled with them;
    // the names are what makes the entry still readable afterwards.
    expect(removedConfiguration.configurationId, isNull);
    expect(removedConfiguration.configurationName, 'Worship Lead');
    expect(removedControl.controlId, isNull);
    expect(removedControl.controlName, 'Volume');
  });

  test('an added control is filed against the pedal it is on', () {
    final entry = ChangeEntry.controlAdded(control);

    expect(entry.pedalId, pedal.id);
    expect(entry.controlId, control.id);
    expect(entry.changeType, ChangeType.controlAdded);
  });

  test('the companion carries the timestamp it is given', () {
    final companion = ChangeEntry.configurationCreated(
      configuration,
    ).toCompanion(timestamp);

    expect(companion.createdAt.value, timestamp);
    expect(companion.pedalId.value, pedal.id);
    expect(companion.configurationName.value, 'Worship Lead');
    // Present-and-null rather than absent, so the column is written explicitly.
    expect(companion.oldText.present, isTrue);
    expect(companion.oldText.value, isNull);
  });
}
