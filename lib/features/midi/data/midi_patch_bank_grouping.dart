import '../../../core/database/daos/midi_patch_program_number_dao.dart';

/// One "Bank" heading in the Patch Browser, with the patches shown under it.
///
/// Purely a display grouping computed from [NumberedPatch.programNumber] -
/// nothing about the MG-30's real memory layout is confirmed, so this must
/// never be read as a claim about how the device actually organizes patches.
/// See `nuxMg30V5Capabilities` for what is and is not verified.
typedef PatchBank = ({int bankNumber, List<NumberedPatch> patches});

/// Groups [patches] (already ordered by [NumberedPatch.programNumber]) into
/// banks of [slotsPerBank], numbered from 1.
///
/// Program numbers themselves start at 0, so Bank 01 holds 0-3 at the default
/// size - not 1-4. Treating them as 1-based put five slots in the first bank
/// once 0 became a legal number.
///
/// [slotsPerBank] defaults to 4, matching the brief's own "01A/01B/01C/01D"
/// example; it is a display convenience, not a verified device constant, so
/// it stays a parameter rather than a device-profile field.
List<PatchBank> groupPatchesByBank(List<NumberedPatch> patches, {int slotsPerBank = 4}) {
  final banks = <int, List<NumberedPatch>>{};
  for (final patch in patches) {
    final bankNumber = (patch.programNumber ~/ slotsPerBank) + 1;
    banks.putIfAbsent(bankNumber, () => []).add(patch);
  }
  return [
    for (final bankNumber in banks.keys.toList()..sort())
      (bankNumber: bankNumber, patches: banks[bankNumber]!),
  ];
}
