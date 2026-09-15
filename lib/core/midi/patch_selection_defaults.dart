import 'midi_support_level.dart';

/// A device profile's best candidate for selecting a patch by number, and how
/// confident that candidate is - see [MidiSupportLevel.needsHardwareVerification].
///
/// Deliberately not a message builder itself: whether to actually send this
/// is a decision for whoever asked to load a patch, gated behind the
/// experimental opt-in the MIDI module brief requires, never something a
/// device profile decides on its own.
class PatchSelectionDefaults {
  const PatchSelectionDefaults({
    required this.usesBankSelect,
    this.bankSelectMsb,
    this.bankSelectLsb,
    required this.verificationStatus,
  });

  /// Whether Bank Select (CC 0, and CC 32 where [bankSelectLsb] is set) is
  /// sent ahead of the Program Change.
  final bool usesBankSelect;

  final int? bankSelectMsb;
  final int? bankSelectLsb;

  final MidiSupportLevel verificationStatus;
}

/// A user's own override of one or more of [PatchSelectionDefaults]' fields,
/// kept separate from the CC-mapping overrides: this is a strategy, not a
/// single named parameter.
class PatchSelectionOverride {
  const PatchSelectionOverride({this.usesBankSelect, this.bankSelectMsb, this.bankSelectLsb});

  final bool? usesBankSelect;
  final int? bankSelectMsb;
  final int? bankSelectLsb;
}
