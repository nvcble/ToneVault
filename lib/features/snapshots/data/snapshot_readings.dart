import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';

/// Freezes one pedal's readings: the positions in [values], described by the
/// [controls] they belong to, ready to store under [entryId].
///
/// Everything needed to read a number back later is copied alongside it, because
/// the control it came from can be renamed, re-scaled or deleted afterwards. The
/// number itself stays in the control's own domain - never a formatted string.
///
/// A control the configuration never set is left out: an unset knob is not a
/// reading, and inventing one would put a position in the record that nobody
/// dialled in. That leaves gaps in [RigSnapshotValues.displayOrder], which only
/// ever orders the list, so a gap costs nothing.
List<RigSnapshotValuesCompanion> frozenReadings({
  required int entryId,
  required List<PedalControl> controls,
  required List<ConfigurationValue> values,
}) {
  final positions = {for (final value in values) value.controlId: value.value};

  return [
    for (final control in controls)
      if (positions[control.id] case final double position)
        RigSnapshotValuesCompanion.insert(
          entryId: entryId,
          controlName: control.name,
          controlType: control.controlType,
          value: position,
          unit: Value(control.unit),
          options: Value(control.options),
          displayOrder: control.displayOrder,
        ),
  ];
}
