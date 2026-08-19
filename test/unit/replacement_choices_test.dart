import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/pedal_replacement_dao.dart';
import 'package:tone_vault/core/enums/pedal_category.dart';
import 'package:tone_vault/core/enums/pedal_status.dart';
import 'package:tone_vault/core/enums/pedal_type.dart';
import 'package:tone_vault/features/replacements/data/replacement_choices.dart';

/// Which pedals a swap may name, and which side of a recorded swap a pedal is
/// on. Pure rules, so no database.
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

  final pureSky = pedal(1, 'Caline PureSky');
  final mg30 = pedal(2, 'NUX MG-30');

  PedalSwap swap({
    required Pedal outgoing,
    required Pedal incoming,
    int id = 1,
  }) {
    return (
      replacement: PedalReplacement(
        id: id,
        oldPedalId: outgoing.id,
        newPedalId: incoming.id,
        replacedAt: moment,
      ),
      outgoing: outgoing,
      incoming: incoming,
    );
  }

  group('replacementCandidates', () {
    test('offers the rest of the inventory', () {
      final candidates = replacementCandidates(
        outgoing: pureSky,
        pedals: [pureSky, mg30, pedal(3, 'Vox Wah')],
      );

      expect(candidates.map((candidate) => candidate.name), [
        'NUX MG-30',
        'Vox Wah',
      ]);
    });

    test('never offers the pedal being replaced', () {
      final candidates = replacementCandidates(
        outgoing: pureSky,
        pedals: [pureSky],
      );

      expect(candidates, isEmpty);
    });

    test('leaves out pedals that are not in the rig to take over', () {
      // One was sold and one has already been retired by something else;
      // neither can stand in for anything now.
      final candidates = replacementCandidates(
        outgoing: pureSky,
        pedals: [
          pedal(3, 'Sold Wah', status: PedalStatus.sold),
          pedal(4, 'Old Boss', status: PedalStatus.replaced),
          pedal(5, 'Spare OD', status: PedalStatus.backup),
        ],
      );

      expect(candidates.map((candidate) => candidate.name), ['Spare OD']);
    });
  });

  group('retirementOf and takeoversBy', () {
    test('reads one swap from both sides', () {
      final swaps = [swap(outgoing: pureSky, incoming: mg30)];

      expect(retirementOf(pureSky.id, swaps)?.incoming.name, 'NUX MG-30');
      expect(takeoversBy(pureSky.id, swaps), isEmpty);

      expect(retirementOf(mg30.id, swaps), isNull);
      expect(
        takeoversBy(mg30.id, swaps).single.outgoing.name,
        'Caline PureSky',
      );
    });

    test('holds every pedal one stood in for', () {
      final swaps = [
        swap(outgoing: pedal(3, 'Vox Wah'), incoming: mg30, id: 2),
        swap(outgoing: pureSky, incoming: mg30),
      ];

      expect(takeoversBy(mg30.id, swaps).map((it) => it.outgoing.name), [
        'Vox Wah',
        'Caline PureSky',
      ]);
    });

    test('says nothing about a pedal that was never swapped', () {
      expect(retirementOf(pureSky.id, const []), isNull);
      expect(takeoversBy(pureSky.id, const []), isEmpty);
    });
  });
}
