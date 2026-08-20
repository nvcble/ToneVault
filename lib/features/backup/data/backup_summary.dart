import '../../../core/database/daos/backup_dao.dart';
import '../../../shared/formatting/app_date_format.dart';
import 'backup_document.dart';

/// How much is in a vault, in the terms the user thinks in.
///
/// Controls, configuration values and snapshot readings are left out on purpose:
/// nobody counts their knobs. These three are what a person can check against
/// their own memory of what they own.
typedef VaultTally = ({int pedals, int rigs, int snapshots});

VaultTally tallyVault(VaultRows rows) => (
  pedals: rows.pedals.length,
  rigs: rows.pedalboards.length,
  snapshots: rows.snapshots.length,
);

/// What a backup holds, for the confirmation asked before it replaces
/// everything.
///
/// A restore cannot be undone, so the question has to be answerable: the date it
/// was taken and how much is in it are what tell the user whether this is the
/// file they meant.
String describeBackup(VaultBackup backup) {
  final tally = tallyVault(backup.rows);

  return 'Taken ${formatDateTime(backup.exportedAt)}, with '
      '${_count(tally.pedals, 'pedal')}, ${_count(tally.rigs, 'rig')} and '
      '${_count(tally.snapshots, 'snapshot')} in it.';
}

/// What a finished restore put in place, for the report afterwards.
String describeRestored(VaultRows rows) {
  final tally = tallyVault(rows);

  return 'Restored ${_count(tally.pedals, 'pedal')}, '
      '${_count(tally.rigs, 'rig')} and '
      '${_count(tally.snapshots, 'snapshot')}.';
}

/// "1 pedal", "12 pedals", "no pedals" - a backup of an empty vault is a real
/// thing to be told about, and "0 pedals" reads like a fault.
String _count(int howMany, String thing) => switch (howMany) {
  0 => 'no ${thing}s',
  1 => '1 $thing',
  _ => '$howMany ${thing}s',
};
