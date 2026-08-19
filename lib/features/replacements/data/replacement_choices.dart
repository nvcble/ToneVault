import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pedal_replacement_dao.dart';
import '../../../core/enums/pedal_status.dart';

/// Which pedals may take over from [outgoing], out of the whole inventory.
///
/// A pedal cannot replace itself, and neither a pedal that has already been
/// retired by something else nor one that has been sold is in the rig to take
/// anything over. The repository refuses the rest; this is what the picker
/// offers, so the user is not led into a refusal.
List<Pedal> replacementCandidates({
  required Pedal outgoing,
  required List<Pedal> pedals,
}) {
  return pedals
      .where(
        (pedal) =>
            pedal.id != outgoing.id &&
            pedal.status.isOwned &&
            pedal.status != PedalStatus.replaced,
      )
      .toList();
}

/// The swap that retired [pedalId], if it has been replaced.
///
/// Only ever one: the repository refuses a second swap against the same pedal.
PedalSwap? retirementOf(int pedalId, List<PedalSwap> swaps) {
  final retirements = swaps.where(
    (swap) => swap.replacement.oldPedalId == pedalId,
  );
  return retirements.isEmpty ? null : retirements.first;
}

/// The swaps where [pedalId] is the pedal that took over, newest first.
///
/// A pedal can stand in for several over the years, so this is a list.
List<PedalSwap> takeoversBy(int pedalId, List<PedalSwap> swaps) {
  return swaps.where((swap) => swap.replacement.newPedalId == pedalId).toList();
}
