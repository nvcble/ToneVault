import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/change_logs_table.dart';
import '../tables/configuration_values_table.dart';
import '../tables/configurations_table.dart';
import '../tables/pedal_controls_table.dart';
import '../tables/pedal_replacements_table.dart';
import '../tables/pedalboard_slots_table.dart';
import '../tables/pedalboards_table.dart';
import '../tables/pedals_table.dart';
import '../tables/rig_snapshot_entries_table.dart';
import '../tables/rig_snapshot_values_table.dart';
import '../tables/rig_snapshots_table.dart';

part 'backup_dao.g.dart';

/// Every row in the vault, table by table.
///
/// The fields are declared parent before child, which is the order foreign keys
/// allow them to be written in.
typedef VaultRows = ({
  List<Pedal> pedals,
  List<PedalControl> controls,
  List<Configuration> configurations,
  List<ConfigurationValue> configurationValues,
  List<ChangeLog> changeLogs,
  List<PedalReplacement> replacements,
  List<Pedalboard> pedalboards,
  List<PedalboardSlot> slots,
  List<RigSnapshot> snapshots,
  List<RigSnapshotEntry> snapshotEntries,
  List<RigSnapshotValue> snapshotValues,
});

/// Reads and replaces the whole vault, for backup and restore.
///
/// This is the one place that touches every table at once. Turning rows into a
/// file and back belongs to the backup feature; this class only moves them in
/// and out of the database, with ids intact so a restored vault reads exactly
/// like the one that was backed up.
@DriftAccessor(
  tables: [
    Pedals,
    PedalControls,
    Configurations,
    ConfigurationValues,
    ChangeLogs,
    PedalReplacements,
    Pedalboards,
    PedalboardSlots,
    RigSnapshots,
    RigSnapshotEntries,
    RigSnapshotValues,
  ],
)
class BackupDao extends DatabaseAccessor<AppDatabase> with _$BackupDaoMixin {
  BackupDao(super.attachedDatabase);

  /// The whole vault, read in one transaction so a write part-way through cannot
  /// produce a backup that is half one thing and half another.
  Future<VaultRows> readEverything() {
    return transaction(
      () async => (
        pedals: await select(pedals).get(),
        controls: await select(pedalControls).get(),
        configurations: await select(configurations).get(),
        configurationValues: await select(configurationValues).get(),
        changeLogs: await select(changeLogs).get(),
        replacements: await select(pedalReplacements).get(),
        pedalboards: await select(pedalboards).get(),
        slots: await select(pedalboardSlots).get(),
        snapshots: await select(rigSnapshots).get(),
        snapshotEntries: await select(rigSnapshotEntries).get(),
        snapshotValues: await select(rigSnapshotValues).get(),
      ),
    );
  }

  /// Empties the vault and writes [rows] in its place, all or nothing.
  ///
  /// One transaction, so a file that turns out to reference a pedal that is not
  /// in it leaves the vault exactly as it was rather than half replaced.
  Future<void> writeEverything(VaultRows rows) {
    return transaction(() async {
      await _deleteEverything();

      // Parent before child, so every reference has something to point at by
      // the time it is written.
      await batch((batch) {
        batch.insertAll(pedals, rows.pedals);
        batch.insertAll(pedalControls, rows.controls);
        batch.insertAll(configurations, rows.configurations);
        batch.insertAll(configurationValues, rows.configurationValues);
        batch.insertAll(changeLogs, rows.changeLogs);
        batch.insertAll(pedalReplacements, rows.replacements);
        batch.insertAll(pedalboards, rows.pedalboards);
        batch.insertAll(pedalboardSlots, rows.slots);
        batch.insertAll(rigSnapshots, rows.snapshots);
        batch.insertAll(rigSnapshotEntries, rows.snapshotEntries);
        batch.insertAll(rigSnapshotValues, rows.snapshotValues);
      });
    });
  }

  /// Child before parent, the reverse of the write order, so no delete is
  /// refused by a row still pointing at what it is deleting.
  Future<void> _deleteEverything() async {
    await delete(rigSnapshotValues).go();
    await delete(rigSnapshotEntries).go();
    await delete(rigSnapshots).go();
    await delete(pedalboardSlots).go();
    await delete(pedalboards).go();
    await delete(pedalReplacements).go();
    await delete(changeLogs).go();
    await delete(configurationValues).go();
    await delete(configurations).go();
    await delete(pedalControls).go();
    await delete(pedals).go();
  }
}
