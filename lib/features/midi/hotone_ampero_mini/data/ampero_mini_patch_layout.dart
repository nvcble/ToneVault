/// How the Ampero Mini's patches are laid out, and what MIDI can reach.
library;

/// OFFICIAL - Hotone's own spec table lists
/// `Patches: 198 (99 user patches, 99 factory patches)`.
const int amperoMiniUserPatchCount = 99;
const int amperoMiniFactoryPatchCount = 99;
const int amperoMiniPatchCount =
    amperoMiniUserPatchCount + amperoMiniFactoryPatchCount;

/// VERIFIED ON HARDWARE: the pedal's own labels are bank-and-slot, and 99
/// patches per half divides into exactly 33 banks of 3 - see
/// [amperoMiniPatchLabel] for the boundary that pins it.
const int amperoMiniPatchesPerBank = 3;

/// 33 user banks P01..P33, then 33 factory banks F01..F33.
const int amperoMiniBanksPerSection =
    amperoMiniUserPatchCount ~/ amperoMiniPatchesPerBank;

/// Whether patch [patchIndex] can be selected from this app at all.
///
/// Only the user patches can be. VERIFIED ON HARDWARE (2026-09-16), from one
/// positive and one negative result in the same session: Program Change 1
/// loaded P01-2, while Program Change 99 - F01-1, the first factory patch -
/// left the pedal on whatever it already had. So the program number equals the
/// patch index, and the pedal's Program Change map covers its 99 user patches
/// and stops there.
///
/// Reaching the factory half would need Bank Select, which is UNVERIFIED on
/// this pedal and so is never sent: a program number the pedal ignores looks
/// exactly like a working selection from this side, which is the bug this
/// replaces.
bool amperoMiniIsSelectableOverMidi(int patchIndex) =>
    amperoMiniIsUserPatch(patchIndex);

/// Whether [patchIndex] is one of the user patches rather than a factory one.
bool amperoMiniIsUserPatch(int patchIndex) =>
    patchIndex >= 0 && patchIndex < amperoMiniUserPatchCount;

/// The pedal's own name for the patch at absolute zero-based [patchIndex], so
/// the app and the hardware display agree.
///
/// VERIFIED ON HARDWARE (2026-09-16): the user compared the app against the
/// pedal and reported index 98 showing as `P33-3`, with `F01-1` as the very
/// next patch. That fixes three things at once - banks are numbered from 01,
/// the user half ends at P33-3, and the factory half is prefixed `F` and
/// restarts its bank numbering at F01.
///
/// It also corrects an earlier reading of the footswitch capture. That capture
/// was labelled by hand as starting at P01-1 for index 3, which put every bank
/// one too low; index 3 is really P02-1. The comparison above is the better
/// evidence because it is anchored to a boundary the official 99/99 split
/// predicts independently.
String amperoMiniPatchLabel(int patchIndex) {
  final isUser = amperoMiniIsUserPatch(patchIndex);
  final offset = isUser ? patchIndex : patchIndex - amperoMiniUserPatchCount;
  final bank = offset ~/ amperoMiniPatchesPerBank + 1;
  final slot = offset % amperoMiniPatchesPerBank + 1;
  return '${isUser ? 'P' : 'F'}${bank.toString().padLeft(2, '0')}-$slot';
}
