import 'package:drift/drift.dart';

import '../../enums/control_type.dart';
import 'pedals_table.dart';

/// A single knob, switch or parameter belonging to one pedal.
///
/// Controls are always defined per pedal rather than hardcoded per model, so
/// the settings UI can render any device from these rows alone.
@TableIndex(
  name: 'idx_pedal_controls_pedal_order',
  columns: {#pedalId, #displayOrder},
)
class PedalControls extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get pedalId =>
      integer().references(Pedals, #id, onDelete: KeyAction.restrict)();

  TextColumn get name => text().withLength(min: 1, max: 60)();

  TextColumn get controlType => textEnum<ControlType>()();

  /// Inclusive bounds every stored value for this control must fall inside.
  /// Clock controls use a normalized `0..1` domain; percentage controls `0..100`.
  RealColumn get minValue => real()();

  RealColumn get maxValue => real()();

  /// Increment the control snaps to, or null when it is continuous.
  RealColumn get step => real().nullable()();

  RealColumn get defaultValue => real().nullable()();

  /// Display-only suffix such as `dB`, `ms` or `Hz`.
  TextColumn get unit => text().withLength(min: 1, max: 12).nullable()();

  /// Position names of a selection control, as a JSON array of strings.
  ///
  /// Null for every other control type. A handful of labels is never queried on
  /// its own, so they stay on the control instead of earning a child table, and
  /// the stored value remains a plain number: the position within this list.
  /// Read and written through `decodeControlOptions` / `encodeControlOptions`.
  TextColumn get options => text().nullable()();

  IntColumn get displayOrder => integer()();

  /// Two knobs on the same pedal sharing a name would make configurations
  /// ambiguous to read.
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {pedalId, name},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (max_value > min_value)',
    'CHECK (step IS NULL OR step > 0)',
  ];
}
