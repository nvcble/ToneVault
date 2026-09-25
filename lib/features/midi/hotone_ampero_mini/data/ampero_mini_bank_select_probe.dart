/// Candidate ways of reaching a factory patch, none of them confirmed.
///
/// A plain Program Change moves this pedal to any of its 99 user patches but
/// did nothing for F01-1 (VERIFIED ON HARDWARE, 2026-09-16), and 198 patches
/// cannot all be addressed by a seven-bit program number anyway - so some extra
/// mechanism exists or the factory half is simply not remotely selectable.
/// Bank Select is the mechanism the MIDI specification reserves for this, and
/// Hotone documents it for the Ampero II, this pedal's sibling.
///
/// Every layout here is EXPERIMENTAL: a hypothesis to try against the hardware,
/// never a described behaviour. Nothing in this file may be presented as
/// working - only the pedal's own display can settle that, which is why the
/// probe UI asks the user to watch it.
library;

import '../../../../core/midi/midi_message.dart';
import '../../../../core/midi/midi_patch_selection.dart';
import '../../../../core/midi/midi_support_level.dart';
import '../../../../core/midi/patch_selection_defaults.dart';
import 'ampero_mini_patch_layout.dart';

/// One candidate: a Bank Select pair, then a Program Change.
class AmperoMiniBankSelectAttempt {
  const AmperoMiniBankSelectAttempt({
    required this.msb,
    required this.lsb,
    required this.program,
    required this.hypothesis,
  });

  /// CC 0. Always sent.
  final int msb;

  /// CC 32, or null to send no LSB at all - some devices use the MSB alone.
  final int? lsb;

  /// The Program Change value, 0-127.
  final int program;

  /// Why this layout is worth a try, in the user's terms.
  final String hypothesis;

  /// The exact messages this attempt puts on the wire, built by the generic
  /// [buildPatchSelectionMessages] so the probe cannot drift from how a
  /// confirmed selection would be sent.
  List<MidiMessage> messages(int channel) => buildPatchSelectionMessages(
    defaults: const PatchSelectionDefaults(
      usesBankSelect: true,
      verificationStatus: MidiSupportLevel.needsHardwareVerification,
    ),
    override: PatchSelectionOverride(
      usesBankSelect: true,
      bankSelectMsb: msb,
      bankSelectLsb: lsb,
    ),
    channel: channel,
    patchNumber: program,
  );

  String get summary =>
      'CC0=$msb${lsb == null ? '' : ', CC32=$lsb'}, PC $program';
}

/// The layouts to try for [patchIndex], most plausible first.
///
/// Only ever four, and each varies one thing: whether the bank rides in the
/// MSB or the LSB, whether an LSB is sent at all, and whether the program
/// number counts from F01-1 or is the absolute patch index. A layout whose
/// program number will not fit in seven bits is dropped rather than truncated.
List<AmperoMiniBankSelectAttempt> amperoMiniBankSelectAttempts(int patchIndex) {
  final withinHalf = patchIndex - amperoMiniUserPatchCount;
  return [
    AmperoMiniBankSelectAttempt(
      msb: 1,
      lsb: 0,
      program: withinHalf,
      hypothesis: 'The factory half as bank 1, counted from F01-1.',
    ),
    AmperoMiniBankSelectAttempt(
      msb: 0,
      lsb: 1,
      program: withinHalf,
      hypothesis: 'The same, with the bank in the LSB instead of the MSB.',
    ),
    AmperoMiniBankSelectAttempt(
      msb: 1,
      lsb: null,
      program: withinHalf,
      hypothesis: 'Bank 1 with no LSB sent at all.',
    ),
    AmperoMiniBankSelectAttempt(
      msb: 0,
      lsb: 0,
      program: patchIndex,
      hypothesis:
          'Bank 0 and the absolute index - in case the plain Program Change '
          'only failed because the pedal was left in another bank.',
    ),
  ].where((attempt) => attempt.program >= 0 && attempt.program <= 127).toList();
}
