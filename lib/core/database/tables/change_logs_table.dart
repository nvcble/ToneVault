import 'package:drift/drift.dart';

import '../../enums/change_type.dart';
import 'configurations_table.dart';
import 'pedal_controls_table.dart';
import 'pedals_table.dart';

/// Append-only record of every meaningful change to a pedal or its settings.
///
/// Rows are never updated or deleted. [configurationName] and [controlName]
/// duplicate data that is otherwise reachable through the foreign keys, on
/// purpose: a configuration or control can be removed later, and a history
/// entry that renders as "null changed from null to null" is worthless. The
/// foreign keys are kept for navigation while they still resolve.
@TableIndex(name: 'idx_change_logs_pedal_time', columns: {#pedalId, #createdAt})
@TableIndex(name: 'idx_change_logs_configuration', columns: {#configurationId})
class ChangeLogs extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get pedalId =>
      integer().references(Pedals, #id, onDelete: KeyAction.restrict)();

  IntColumn get configurationId => integer().nullable().references(
    Configurations,
    #id,
    onDelete: KeyAction.setNull,
  )();

  IntColumn get controlId => integer().nullable().references(
    PedalControls,
    #id,
    onDelete: KeyAction.setNull,
  )();

  TextColumn get configurationName =>
      text().withLength(min: 1, max: 80).nullable()();

  TextColumn get controlName => text().withLength(min: 1, max: 60).nullable()();

  TextColumn get changeType => textEnum<ChangeType>()();

  /// Set only for events that move a control, in that control's own domain.
  RealColumn get oldValue => real().nullable()();

  RealColumn get newValue => real().nullable()();

  /// The same transition for events that change text rather than a number: a
  /// configuration's name, a pedal's status, or which pedal took over from
  /// which. Kept separate from [reason] so the user can still explain a rename.
  TextColumn get oldText => text().nullable()();

  TextColumn get newText => text().nullable()();

  /// The user's own explanation, e.g. "needed more saturation for lead".
  TextColumn get reason => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
}
