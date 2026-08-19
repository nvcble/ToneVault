import 'package:drift/drift.dart';

/// Schema history. Every version bump gets an entry here and a matching branch
/// in [buildMigrationStrategy], so user data is never dropped to fix a schema.
///
/// - v1: pedals, pedal_controls, configurations, configuration_values,
///   change_logs, pedal_replacements, pedalboards.
/// - v2: pedal_controls.options, the position names of a selection control.
const int currentSchemaVersion = 2;

MigrationStrategy buildMigrationStrategy(GeneratedDatabase database) {
  return MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      // Steps run in ascending order and each one preserves existing rows.
      //
      // They are written as literal SQL on purpose: a shipped migration has to
      // keep doing exactly what it did on the day it shipped, even after the
      // Dart table definition it came from has moved on. Deriving the statement
      // from the current definition instead would quietly rewrite history.
      if (from < 2) {
        await database.customStatement(
          'ALTER TABLE pedal_controls ADD COLUMN options TEXT NULL;',
        );
      }

      if (to > currentSchemaVersion) {
        throw StateError('No migration registered up to schema $to.');
      }
    },
    beforeOpen: (details) async {
      // SQLite disables foreign keys per connection, so without this the
      // restrict/cascade rules declared on the tables would do nothing.
      await database.customStatement('PRAGMA foreign_keys = ON;');
    },
  );
}
