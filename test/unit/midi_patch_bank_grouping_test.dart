import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/database/app_database.dart';
import 'package:tone_vault/core/database/daos/midi_patch_program_number_dao.dart';
import 'package:tone_vault/features/midi/data/midi_patch_bank_grouping.dart';

NumberedPatch _numbered(int programNumber) => (
  patch: Patch(
    id: programNumber,
    pedalId: 1,
    name: 'Patch $programNumber',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  ),
  programNumber: programNumber,
);

void main() {
  test('groups consecutive program numbers into banks of the given size', () {
    // Numbers start at 0, so Bank 01 is 0-3 and slot 4 opens Bank 02 - reading
    // them as 1-based put five slots in the first bank.
    final banks = groupPatchesByBank([
      _numbered(0),
      _numbered(1),
      _numbered(2),
      _numbered(3),
      _numbered(4),
    ]);

    expect(banks, hasLength(2));
    expect(banks[0].bankNumber, 1);
    expect(banks[0].patches.map((p) => p.programNumber), [0, 1, 2, 3]);
    expect(banks[1].bankNumber, 2);
    expect(banks[1].patches.map((p) => p.programNumber), [4]);
  });

  test('the last program number of all lands in the last bank', () {
    final banks = groupPatchesByBank([_numbered(127)]);

    expect(banks.single.bankNumber, 32);
  });

  test('a program number the user assigned outside any tidy range still lands in a bank', () {
    final banks = groupPatchesByBank([_numbered(0), _numbered(37)]);

    expect(banks.map((b) => b.bankNumber), [1, 10]);
  });

  test('returns nothing for an empty patch list', () {
    expect(groupPatchesByBank(const []), isEmpty);
  });
}
