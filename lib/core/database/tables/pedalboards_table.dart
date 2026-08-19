import 'package:drift/drift.dart';

/// A named rig, such as "Hybrid Worship Rig" or "Home Practice".
///
/// This table carries the rig's identity only. The ordered signal chain that
/// belongs to it is in `pedalboard_slots`, one row per pedal on the rig.
class Pedalboards extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 80).unique()();

  TextColumn get description => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
