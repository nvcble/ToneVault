import 'dart:convert';

import 'package:drift/drift.dart' show DataClass, ValueSerializer;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/backup_dao.dart';
import '../../../core/database/migrations.dart';
import '../../../core/errors/app_failure.dart';
import '../../../shared/formatting/app_date_format.dart';
import 'vault_value_serializer.dart';

/// The version of the backup file's own layout - the header keys and the shape
/// around the tables, not the schema of the tables themselves.
///
/// It moves only if that layout changes, so a file always says plainly whether
/// this app knows how to read it.
const int backupFormatVersion = 1;

/// What a backup file is called: the app, and the day it was taken.
///
/// The date is the user's own rather than UTC. A file named for yesterday
/// because the phone is west of Greenwich is a file they cannot find again.
String backupFileName(DateTime exportedAt) =>
    'tonevault-backup-${formatDate(exportedAt.toLocal())}.json';

/// A backup file, read.
typedef VaultBackup = ({
  int formatVersion,
  int schemaVersion,
  DateTime exportedAt,
  VaultRows rows,
});

const _serializer = VaultValueSerializer();

/// The whole vault as a JSON document.
///
/// Indented on purpose: a backup is the user's own copy of their gear, and one
/// they can open and read is worth more than one that saves a few bytes. Each
/// table is a list of rows keyed by column, exactly as the database holds them,
/// so nothing has to be interpreted on the way back in.
String encodeVaultBackup(VaultRows rows, {required DateTime exportedAt}) {
  final document = <String, dynamic>{
    'formatVersion': backupFormatVersion,
    'schemaVersion': currentSchemaVersion,
    'exportedAt': _serializer.toJson<DateTime>(exportedAt),
    'tables': {
      'pedals': _encode(rows.pedals),
      'controls': _encode(rows.controls),
      'configurations': _encode(rows.configurations),
      'configurationValues': _encode(rows.configurationValues),
      'changeLogs': _encode(rows.changeLogs),
      'replacements': _encode(rows.replacements),
      'pedalboards': _encode(rows.pedalboards),
      'slots': _encode(rows.slots),
      'snapshots': _encode(rows.snapshots),
      'snapshotEntries': _encode(rows.snapshotEntries),
      'snapshotValues': _encode(rows.snapshotValues),
    },
  };

  return const JsonEncoder.withIndent('  ').convert(document);
}

/// Reads a backup file, or refuses it in words the user can act on.
///
/// Nothing is written anywhere: this only turns text into rows, so a file that
/// turns out to be a photo or a half-downloaded document is found out before the
/// vault is touched.
///
/// A file from a newer app is refused rather than guessed at, and so is one from
/// an older schema: filling in columns that version never had would invent
/// settings the user never dialled in. Restoring those becomes possible when
/// there is a second schema version to convert from.
VaultBackup decodeVaultBackup(String source) {
  final document = _document(source);
  final formatVersion = document['formatVersion'];
  final schemaVersion = document['schemaVersion'];

  if (formatVersion is! int || schemaVersion is! int) {
    throw _notABackup();
  }
  if (formatVersion > backupFormatVersion ||
      schemaVersion > currentSchemaVersion) {
    throw const AppFailure(
      'That backup was made by a newer version of ToneVault. Update the app, '
      'then try again.',
    );
  }
  if (formatVersion < backupFormatVersion) {
    throw _notABackup();
  }
  if (schemaVersion < currentSchemaVersion) {
    throw const AppFailure(
      'That backup was made by an older version of ToneVault and cannot be '
      'restored into this one.',
    );
  }

  final tables = document['tables'];
  if (tables is! Map<String, dynamic>) {
    throw _damaged();
  }

  try {
    return (
      formatVersion: formatVersion,
      schemaVersion: schemaVersion,
      exportedAt: _serializer.fromJson<DateTime>(document['exportedAt']),
      rows: _rows(tables),
    );
  } on AppFailure {
    rethrow;
  } catch (error) {
    // A column missing from a row, a number where a name belongs: whatever the
    // driver or the data class complains about, the user hears one thing.
    throw _damaged(error);
  }
}

List<Map<String, dynamic>> _encode(List<DataClass> rows) => [
  for (final row in rows) row.toJson(serializer: _serializer),
];

VaultRows _rows(Map<String, dynamic> tables) => (
  pedals: _decode(tables, 'pedals', Pedal.fromJson),
  controls: _decode(tables, 'controls', PedalControl.fromJson),
  configurations: _decode(tables, 'configurations', Configuration.fromJson),
  configurationValues: _decode(
    tables,
    'configurationValues',
    ConfigurationValue.fromJson,
  ),
  changeLogs: _decode(tables, 'changeLogs', ChangeLog.fromJson),
  replacements: _decode(tables, 'replacements', PedalReplacement.fromJson),
  pedalboards: _decode(tables, 'pedalboards', Pedalboard.fromJson),
  slots: _decode(tables, 'slots', PedalboardSlot.fromJson),
  snapshots: _decode(tables, 'snapshots', RigSnapshot.fromJson),
  snapshotEntries: _decode(
    tables,
    'snapshotEntries',
    RigSnapshotEntry.fromJson,
  ),
  snapshotValues: _decode(tables, 'snapshotValues', RigSnapshotValue.fromJson),
);

/// One table's rows, read through the data class drift generated for it.
///
/// A missing table is refused rather than read as empty: a file we wrote always
/// carries all eleven, so one that does not is not a file to restore from.
List<T> _decode<T>(
  Map<String, dynamic> tables,
  String key,
  T Function(Map<String, dynamic>, {ValueSerializer? serializer}) read,
) {
  final rows = tables[key];
  if (rows is! List) {
    throw _damaged();
  }

  return [
    for (final row in rows)
      if (row is Map<String, dynamic>)
        read(row, serializer: _serializer)
      else
        throw _damaged(),
  ];
}

Map<String, dynamic> _document(String source) {
  try {
    final decoded = json.decode(source);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
  } on FormatException {
    throw _notABackup();
  }
  throw _notABackup();
}

AppFailure _notABackup() =>
    const AppFailure('That file is not a ToneVault backup.');

AppFailure _damaged([Object? cause]) => AppFailure(
  'That backup file is damaged, so nothing was restored from it.',
  cause: cause,
);
