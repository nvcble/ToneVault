import 'package:drift/drift.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/change_type.dart';
import 'package:tone_vault/core/enums/control_type.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';

/// A vault with one row in every table, for anything that has to handle the
/// whole database at once.
///
/// Written straight through the tables rather than through the repositories: a
/// backup has to carry whatever is in there, including the rows no repository
/// would write today.
Future<void> fillVault(AppDatabase database) async {
  final moment = DateTime.utc(2026, 8, 19, 12);

  final drivePedalId = await database
      .into(database.pedals)
      .insert(
        PedalsCompanion.insert(
          name: 'Caline PureSky',
          brand: const Value('Caline'),
          type: PedalType.analog,
          category: PedalCategory.overdrive,
          status: const Value(PedalStatus.active),
          purchaseDate: Value(moment),
          createdAt: moment,
          updatedAt: moment,
        ),
      );

  // A second pedal, so a replacement has two sides to it.
  final sparePedalId = await database
      .into(database.pedals)
      .insert(
        PedalsCompanion.insert(
          name: 'Boss SD-1',
          type: PedalType.analog,
          category: PedalCategory.overdrive,
          status: const Value(PedalStatus.replaced),
          createdAt: moment,
          updatedAt: moment,
        ),
      );

  final controlId = await database
      .into(database.pedalControls)
      .insert(
        PedalControlsCompanion.insert(
          pedalId: drivePedalId,
          name: 'Gain',
          controlType: ControlType.clock,
          minValue: 0,
          maxValue: 1,
          step: const Value(0.05),
          displayOrder: 0,
        ),
      );

  final configurationId = await database
      .into(database.configurations)
      .insert(
        ConfigurationsCompanion.insert(
          pedalId: drivePedalId,
          name: 'Worship Lead',
          notes: const Value('Edge of breakup'),
          createdAt: moment,
          updatedAt: moment,
        ),
      );

  await database
      .into(database.configurationValues)
      .insert(
        ConfigurationValuesCompanion.insert(
          configurationId: configurationId,
          controlId: controlId,
          value: 0.7,
        ),
      );

  await database
      .into(database.changeLogs)
      .insert(
        ChangeLogsCompanion.insert(
          pedalId: drivePedalId,
          configurationId: Value(configurationId),
          controlId: Value(controlId),
          controlName: const Value('Gain'),
          changeType: ChangeType.controlValueChanged,
          oldValue: const Value(0.5),
          newValue: const Value(0.7),
          createdAt: moment,
        ),
      );

  await database
      .into(database.pedalReplacements)
      .insert(
        PedalReplacementsCompanion.insert(
          oldPedalId: sparePedalId,
          newPedalId: drivePedalId,
          reason: const Value('Quieter'),
          replacedAt: moment,
        ),
      );

  final pedalboardId = await database
      .into(database.pedalboards)
      .insert(
        PedalboardsCompanion.insert(
          name: 'Hybrid Worship Rig',
          description: const Value('MG-30 into the desk'),
          createdAt: moment,
          updatedAt: moment,
        ),
      );

  await database
      .into(database.pedalboardSlots)
      .insert(
        PedalboardSlotsCompanion.insert(
          pedalboardId: pedalboardId,
          pedalId: drivePedalId,
          position: 0,
        ),
      );

  final snapshotId = await database
      .into(database.rigSnapshots)
      .insert(
        RigSnapshotsCompanion.insert(
          pedalboardId: pedalboardId,
          name: 'Easter 2026',
          notes: const Value('Second service'),
          capturedAt: moment,
        ),
      );

  final entryId = await database
      .into(database.rigSnapshotEntries)
      .insert(
        RigSnapshotEntriesCompanion.insert(
          snapshotId: snapshotId,
          pedalId: drivePedalId,
          position: 0,
          configurationName: const Value('Worship Lead'),
        ),
      );

  await database
      .into(database.rigSnapshotValues)
      .insert(
        RigSnapshotValuesCompanion.insert(
          entryId: entryId,
          controlName: 'Gain',
          controlType: ControlType.clock,
          value: 0.7,
          displayOrder: 0,
        ),
      );
}
