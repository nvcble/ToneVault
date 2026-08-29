import '../../../core/database/app_database.dart';
import '../../../core/enums/pedal_status.dart';

/// What the home screen counts up.
typedef CollectionTally = ({int pedals, int inUse});

/// Counts the collection from the list the Pedals tab already streams.
///
/// Sold pedals are left out of the total: they are kept for their history, not
/// as gear the user still has. [PedalStatus.isOwned] is the same rule the rest
/// of the app goes by.
CollectionTally tallyCollection({required List<Pedal> pedals}) {
  final owned = pedals.where((pedal) => pedal.status.isOwned);

  return (
    pedals: owned.length,
    inUse: owned.where((pedal) => pedal.status == PedalStatus.active).length,
  );
}

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
