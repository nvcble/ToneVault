import 'package:drift/drift.dart';

import '../../enums/control_type.dart';
import 'rig_snapshot_entries_table.dart';

/// Where one knob was set, frozen at the moment the snapshot was taken.
///
/// Everything needed to read the number back is copied alongside it, because the
/// control it came from can be renamed, re-scaled or deleted afterwards:
/// [controlName] to say which knob, [controlType], [unit] and [options] because
/// those are what `formatControlValue` reads a value with, and [displayOrder] so
/// the knobs list in the order they sat on the pedal.
///
/// [value] stays a plain number in the control's own domain, never a formatted
/// string: a clock knob is normalized `0..1` here just as it is everywhere else.
class RigSnapshotValues extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get entryId => integer().references(
    RigSnapshotEntries,
    #id,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get controlName => text().withLength(min: 1, max: 60)();

  TextColumn get controlType => textEnum<ControlType>()();

  RealColumn get value => real()();

  TextColumn get unit => text().withLength(min: 1, max: 12).nullable()();

  /// Position names of a selection control as they read that day, as a JSON
  /// array of strings. Null for every other control type.
  TextColumn get options => text().nullable()();

  IntColumn get displayOrder => integer()();

  /// One reading per knob. This also gives SQLite an index led by [entryId],
  /// which is how the values of a snapshot are looked up, so the table needs no
  /// index of its own.
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {entryId, controlName},
  ];
}
