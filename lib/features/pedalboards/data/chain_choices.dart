import '../../../core/database/app_database.dart';
import '../../../core/database/daos/pedalboard_dao.dart';
import '../../../core/enums/pedal_status.dart';

/// Which pedals can still go on a rig, out of the whole inventory.
///
/// A pedal already on this rig cannot go on twice, and neither a sold pedal nor
/// one that has been replaced is around to plug in. A backup or a stored pedal
/// is offered: putting one on a board is how a rig gets planned.
///
/// The repository refuses a duplicate anyway; this is what the picker offers, so
/// the user is not led into a refusal.
List<Pedal> addablePedals({
  required List<Pedal> pedals,
  required List<ChainSlot> chain,
}) {
  final alreadyOn = {for (final entry in chain) entry.pedal.id};

  return pedals
      .where(
        (pedal) =>
            !alreadyOn.contains(pedal.id) &&
            pedal.status.isOwned &&
            pedal.status != PedalStatus.replaced,
      )
      .toList();
}
