import 'package:drift/drift.dart';

/// A named rig, such as "Hybrid Worship Rig" or "Home Practice".
///
/// The ordered signal chain that belongs to a pedalboard arrives with the
/// pedalboard feature; this table only carries the rig's identity for now.
class Pedalboards extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 80).unique()();

  TextColumn get description => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
