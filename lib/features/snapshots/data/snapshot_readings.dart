import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pedal_control_dao.dart';

/// Freezes one entry's readings: the [positions] the setting holds, described by
/// the [controls] they belong to, ready to store under [entryId].
///
/// Everything needed to read a number back later is copied alongside it, because
/// the control it came from can be renamed, re-scaled or deleted afterwards. The
/// number itself stays in the control's own domain - never a formatted string.
///
/// The pedal each control is on is copied too. For an ordinary pedal that is the
/// pedal the entry is filed under, but a scene of a multi-effects unit freezes
/// knobs from several pedals inside it, and "Level at 2:30" says nothing when
/// three of them have a Level.
///
/// A control the setting never dialled in is left out: an unset knob is not a
/// reading, and inventing one would put a position in the record that nobody
/// chose. That leaves gaps in [RigSnapshotValues.displayOrder], which only ever
/// orders the list, so a gap costs nothing.
List<RigSnapshotValuesCompanion> frozenReadings({
  required int entryId,
  required List<OwnedControl> controls,
  required Map<int, double> positions,
}) {
  return [
    for (final owned in controls)
      if (positions[owned.control.id] case final double position)
        RigSnapshotValuesCompanion.insert(
          entryId: entryId,
          controlName: owned.control.name,
          controlPedalName: Value(owned.owner.name),
          controlType: owned.control.controlType,
          value: position,
          unit: Value(owned.control.unit),
          options: Value(owned.control.options),
          displayOrder: owned.control.displayOrder,
        ),
  ];
}
