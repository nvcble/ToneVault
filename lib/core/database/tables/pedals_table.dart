import 'package:drift/drift.dart';

import '../../enums/multi_effects_mode.dart';
import '../../enums/pedal_category.dart';
import '../../enums/pedal_status.dart';
import '../../enums/pedal_type.dart';

/// An owned piece of gear: a stompbox, a multi-effects unit, or anything else
/// that sits in the signal chain.
///
/// Also the stomps and blocks inside a multi-effects unit, through
/// [hostPedalId]. One of those is a pedal in every respect that matters here -
/// it has controls, configurations and history of its own - so it is a row in
/// this table rather than a shape of its own, and every screen written for a
/// pedal works on it unchanged.
///
/// Rows are never deleted once history references them; see [PedalStatus].
@TableIndex(name: 'idx_pedals_status', columns: {#status})
@TableIndex(name: 'idx_pedals_name', columns: {#name})
@TableIndex(name: 'idx_pedals_host', columns: {#hostPedalId})
class Pedals extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  TextColumn get brand => text().withLength(min: 1, max: 60).nullable()();

  TextColumn get type => textEnum<PedalType>()();

  TextColumn get category => textEnum<PedalCategory>()();

  TextColumn get status =>
      textEnum<PedalStatus>().withDefault(Constant(PedalStatus.active.name))();

  /// The multi-effects unit this pedal is part of, or null when it stands on
  /// its own floor.
  ///
  /// RESTRICT for the same reason every other reference to a pedal is: a unit
  /// with stomps still attached is retired, not deleted, so nothing it holds is
  /// swept away with it.
  IntColumn get hostPedalId => integer().nullable().references(
    Pedals,
    #id,
    onDelete: KeyAction.restrict,
  )();

  /// How a multi-effects unit is organised, which the unit's own screen reads to
  /// decide what to show. Null on everything else, which is every pedal that is
  /// not a [PedalType.multiEffects].
  TextColumn get multiEffectsMode => textEnum<MultiEffectsMode>().nullable()();

  /// Path to an image file in the app's documents directory. Photos are kept
  /// outside the database so the file stays small and easy to back up.
  TextColumn get photoPath => text().nullable()();

  DateTimeColumn get purchaseDate => dateTime().nullable()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
