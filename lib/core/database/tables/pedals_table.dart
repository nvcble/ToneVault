import 'package:drift/drift.dart';

import '../../enums/pedal_category.dart';
import '../../enums/pedal_status.dart';
import '../../enums/pedal_type.dart';

/// An owned piece of gear: a stompbox, a multi-effects unit, or anything else
/// that sits in the signal chain.
///
/// Rows are never deleted once history references them; see [PedalStatus].
@TableIndex(name: 'idx_pedals_status', columns: {#status})
@TableIndex(name: 'idx_pedals_name', columns: {#name})
class Pedals extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  TextColumn get brand => text().withLength(min: 1, max: 60).nullable()();

  TextColumn get type => textEnum<PedalType>()();

  TextColumn get category => textEnum<PedalCategory>()();

  TextColumn get status =>
      textEnum<PedalStatus>().withDefault(Constant(PedalStatus.active.name))();

  /// Path to an image file in the app's documents directory. Photos are kept
  /// outside the database so the file stays small and easy to back up.
  TextColumn get photoPath => text().nullable()();

  DateTimeColumn get purchaseDate => dateTime().nullable()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
