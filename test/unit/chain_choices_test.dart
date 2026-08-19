import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/pedalboard_dao.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/pedalboards/data/chain_choices.dart';

/// Which pedals the add picker offers for a rig. A pure rule, so no database.
void main() {
  final moment = DateTime.utc(2026, 8, 19, 12);

  Pedal pedal(int id, String name, {PedalStatus status = PedalStatus.active}) {
    return Pedal(
      id: id,
      name: name,
      type: PedalType.analog,
      category: PedalCategory.overdrive,
      status: status,
      createdAt: moment,
      updatedAt: moment,
    );
  }

  ChainSlot slot(int id, Pedal pedal, int position) {
    return (
      slot: PedalboardSlot(
        id: id,
        pedalboardId: 4,
        pedalId: pedal.id,
        position: position,
      ),
      pedal: pedal,
    );
  }

  final pureSky = pedal(1, 'Caline PureSky');
  final mg30 = pedal(2, 'NUX MG-30');
  final wah = pedal(3, 'Vox Wah');

  test('offers the inventory minus what is already on the rig', () {
    final addable = addablePedals(
      pedals: [pureSky, mg30, wah],
      chain: [slot(10, mg30, 0)],
    );

    expect(addable.map((pedal) => pedal.name), ['Caline PureSky', 'Vox Wah']);
  });

  test('offers the whole inventory to an empty rig', () {
    final addable = addablePedals(pedals: [pureSky, mg30], chain: const []);

    expect(addable, hasLength(2));
  });

  test('leaves out pedals that are not around to plug in', () {
    // One was sold and one has been superseded; neither belongs on a rig being
    // built now. A backup or a stored pedal does.
    final addable = addablePedals(
      pedals: [
        pedal(4, 'Sold Chorus', status: PedalStatus.sold),
        pedal(5, 'Old Boss', status: PedalStatus.replaced),
        pedal(6, 'Spare OD', status: PedalStatus.backup),
        pedal(7, 'Boxed Fuzz', status: PedalStatus.storage),
      ],
      chain: const [],
    );

    expect(addable.map((pedal) => pedal.name), ['Spare OD', 'Boxed Fuzz']);
  });

  test('offers nothing once every pedal is on the rig', () {
    final addable = addablePedals(
      pedals: [pureSky, mg30],
      chain: [slot(10, pureSky, 0), slot(11, mg30, 1)],
    );

    expect(addable, isEmpty);
  });

  test('a pedal on another rig is still offered to this one', () {
    // The chain passed in is only this rig's, which is what lets one pedal be
    // shared between a gig board and a practice board.
    final addable = addablePedals(pedals: [mg30], chain: const []);

    expect(addable.single.name, 'NUX MG-30');
  });
}
