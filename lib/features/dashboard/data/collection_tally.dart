import '../../../core/database/app_database.dart';
import '../../../core/enums/pedal_status.dart';

/// What the home screen counts up.
typedef CollectionTally = ({
  int pedals,
  int inUse,
  int rigs,
  String? latestRig,
});

/// Counts the collection from the lists the tabs already stream.
///
/// Sold pedals are left out of the total: they are kept for their history, not
/// as gear the user still has. [PedalStatus.isOwned] is the same rule the rest
/// of the app goes by.
CollectionTally tallyCollection({
  required List<Pedal> pedals,
  required List<Pedalboard> rigs,
}) {
  final owned = pedals.where((pedal) => pedal.status.isOwned);

  return (
    pedals: owned.length,
    inUse: owned.where((pedal) => pedal.status == PedalStatus.active).length,
    rigs: rigs.length,
    latestRig: _latestRig(rigs)?.name,
  );
}

/// The rig touched most recently, which is the one being worked on.
///
/// The rigs arrive ordered by name, so the newest has to be looked for.
Pedalboard? _latestRig(List<Pedalboard> rigs) => rigs.isEmpty
    ? null
    : rigs.reduce(
        (newest, rig) => rig.updatedAt.isAfter(newest.updatedAt) ? rig : newest,
      );

/// The line under the pedal count: how much of the collection is in play.
String describePedals(CollectionTally tally) {
  if (tally.pedals == 0) {
    return 'None yet';
  }
  if (tally.inUse == tally.pedals) {
    return 'All in use';
  }
  return '${tally.inUse} in use';
}

/// The line under the rig count. A name is more use than another number.
String describeRigs(CollectionTally tally) {
  final latest = tally.latestRig;
  return latest == null ? 'None yet' : 'Latest: $latest';
}
