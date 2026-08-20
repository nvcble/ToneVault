import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pedal_control_dao.dart';

/// The controls on one pedal, under the pedal they belong to.
typedef ControlGroup = ({Pedal owner, List<PedalControl> controls});

/// Collects [rows] into one group per pedal, in the order they arrived.
///
/// The query already put them in the order they should be read, so this only
/// draws the lines between one pedal and the next: an ordinary pedal comes back
/// as a single group, and a multi-effects patch as one group per pedal on it.
List<ControlGroup> groupByOwner(List<OwnedControl> rows) {
  final groups = <int, ControlGroup>{};

  for (final row in rows) {
    final group = groups.putIfAbsent(
      row.owner.id,
      () => (owner: row.owner, controls: <PedalControl>[]),
    );
    group.controls.add(row.control);
  }

  return groups.values.toList();
}
