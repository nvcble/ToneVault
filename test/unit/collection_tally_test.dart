import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/dashboard/data/collection_tally.dart';

/// The counts on the home screen: what is counted, and what the lines under the
/// numbers say.
void main() {
  final moment = DateTime.utc(2026, 8, 19, 12);

  Pedal pedal(int id, PedalStatus status) => Pedal(
    id: id,
    name: 'Pedal $id',
    type: PedalType.analog,
    category: PedalCategory.overdrive,
    status: status,
    createdAt: moment,
    updatedAt: moment,
  );

  Pedalboard rig(int id, String name, {DateTime? changedAt}) => Pedalboard(
    id: id,
    name: name,
    createdAt: moment,
    updatedAt: changedAt ?? moment,
  );

  test('counts the gear the user still has', () async {
    final tally = tallyCollection(
      pedals: [
        pedal(1, PedalStatus.active),
        pedal(2, PedalStatus.active),
        pedal(3, PedalStatus.storage),
        // Replaced is still owned: the pedal is in a drawer, not gone.
        pedal(4, PedalStatus.replaced),
        pedal(5, PedalStatus.sold),
      ],
      rigs: [rig(1, 'Fly Rig')],
    );

    expect(tally.pedals, 4);
    expect(tally.inUse, 2);
    expect(tally.rigs, 1);
  });

  test('names the rig that was touched most recently', () async {
    final tally = tallyCollection(
      pedals: const [],
      // Ordered by name, as the rigs tab streams them.
      rigs: [
        rig(1, 'Fly Rig', changedAt: moment),
        rig(2, 'Hybrid Worship Rig', changedAt: DateTime.utc(2026, 8, 20)),
        rig(3, 'Studio Board', changedAt: DateTime.utc(2026, 7)),
      ],
    );

    expect(tally.latestRig, 'Hybrid Worship Rig');
  });

  test('says how much of the collection is in play', () async {
    final some = tallyCollection(
      pedals: [pedal(1, PedalStatus.active), pedal(2, PedalStatus.storage)],
      rigs: const [],
    );

    expect(describePedals(some), '1 in use');
  });

  test('does not make a fraction of it when all of it is in use', () async {
    final all = tallyCollection(
      pedals: [pedal(1, PedalStatus.active)],
      rigs: const [],
    );

    expect(describePedals(all), 'All in use');
  });

  test('an empty collection reads as empty, not as zero', () async {
    final nothing = tallyCollection(pedals: const [], rigs: const []);

    expect(nothing.latestRig, isNull);
    expect(describePedals(nothing), 'None yet');
    expect(describeRigs(nothing), 'None yet');
  });

  test('a sold pedal is not counted, so the lines agree', () async {
    // Owned and in use are both 1, so the card must not claim a fraction.
    final sold = tallyCollection(
      pedals: [pedal(1, PedalStatus.active), pedal(2, PedalStatus.sold)],
      rigs: [rig(1, 'Fly Rig')],
    );

    expect(sold.pedals, 1);
    expect(describePedals(sold), 'All in use');
    expect(describeRigs(sold), 'Latest: Fly Rig');
  });
}
