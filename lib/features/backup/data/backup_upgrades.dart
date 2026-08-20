import '../../../core/database/migrations.dart';

/// The oldest backup file this app can still read.
///
/// Eight because that is where the export shipped: no released version of
/// ToneVault ever wrote a file saying less, so a file that claims to is not one
/// of ours. The floor is a fact about what went out, not a limit on what could be
/// converted.
const int oldestReadableSchemaVersion = 8;

/// Brings the tables of an older backup file up to the schema this app reads.
///
/// One branch per schema version, in ascending order, deliberately the same shape
/// as `buildMigrationStrategy`: a file is walked forward a version at a time
/// rather than special-cased per pair of versions, so the next schema adds one
/// branch here and leaves the rest alone.
///
/// A table that version never had arrives empty, which is the only honest
/// reading: rows invented for it would be gear the user never entered. A column
/// added later is the case to watch - it has to be filled in here with the same
/// value the migration gives a row that was already there, or the row will not
/// decode at all.
///
/// Only what the file is missing is filled in. A file that says it is current and
/// has a table missing is still a damaged file, and is refused as one.
Map<String, dynamic> upgradeBackupTables(
  Map<String, dynamic> tables, {
  required int from,
}) {
  if (from >= currentSchemaVersion) {
    return tables;
  }

  final upgraded = Map<String, dynamic>.of(tables);

  if (from < 9) {
    // v9 added the sounds of a multi-effects unit: its patches, their scenes, the
    // pedals in each scene and where those pedals' controls sit. A file from
    // before it has none of that, and there is nothing in it to work them out
    // from either.
    for (final table in const [
      'patches',
      'scenes',
      'scenePedals',
      'sceneValues',
    ]) {
      upgraded.putIfAbsent(table, () => const <dynamic>[]);
    }
  }

  return upgraded;
}
