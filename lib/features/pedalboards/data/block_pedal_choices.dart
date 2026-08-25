import '../../../core/database/app_database.dart';
import '../../../core/database/daos/signal_chain_dao.dart';
import '../../../core/enums/pedal_status.dart';
import '../../../core/enums/signal_block_type.dart';
import 'block_type_match.dart';

/// The pedals a block could hold, split into the ones that suit it and the rest.
typedef PedalChoices = ({List<Pedal> suited, List<Pedal> others});

/// Which of the inventory can go in a block of [blockType], and which fit it.
///
/// A pedal already elsewhere on this rig cannot go on twice, and neither a sold
/// pedal nor one that has been replaced is around to plug in. A backup or a
/// stored pedal is offered: putting one on a board is how a rig gets planned.
/// [exceptBlockId] is the block being filled, so whatever is already in it stays
/// on the list rather than the block excluding itself.
///
/// [suited] is what the block asks for, by category; everything else owned is
/// still offered under [others], because it is the user's board and a fuzz in
/// the overdrive slot is their call. Where no category stands for the block -
/// an input, an IR loader, a DI - nothing is singled out and all of it is others.
///
/// The repository refuses a duplicate anyway; this is what the picker offers, so
/// the user is not led into a refusal.
PedalChoices pedalChoices({
  required List<Pedal> pedals,
  required List<ChainBlock> chain,
  required SignalBlockType blockType,
  int? exceptBlockId,
}) {
  final alreadyOn = {
    for (final entry in chain)
      if (entry.block.id != exceptBlockId && entry.pedal != null)
        entry.pedal!.id,
  };
  final wanted = categoriesFor(blockType);

  final suited = <Pedal>[];
  final others = <Pedal>[];
  for (final pedal in pedals) {
    if (alreadyOn.contains(pedal.id) ||
        !pedal.status.isOwned ||
        pedal.status == PedalStatus.replaced) {
      continue;
    }
    (wanted.contains(pedal.category) ? suited : others).add(pedal);
  }

  return (suited: suited, others: others);
}
