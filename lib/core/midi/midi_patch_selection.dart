import 'midi_message.dart';
import 'patch_selection_defaults.dart';

/// Standard MIDI Bank Select CC numbers - not specific to any device, and not
/// invented: both are part of the MIDI specification itself.
const int bankSelectMsbCc = 0;
const int bankSelectLsbCc = 32;

/// Builds the message sequence for loading [patchNumber] (0-127), applying
/// [override] on top of [defaults] field by field.
///
/// [patchNumber] *is* the Program Change value: patch numbers are counted from
/// 0, the same as the wire, so there is no off-by-one to get wrong here. Which
/// physical preset the device puts at Program Change 0 is a separate question,
/// and one [PatchSelectionDefaults.verificationStatus] has not confirmed.
///
/// Purely a builder: whether the caller actually sends this sequence is a
/// decision made above this function, not by it.
List<MidiMessage> buildPatchSelectionMessages({
  required PatchSelectionDefaults defaults,
  PatchSelectionOverride? override,
  required int channel,
  required int patchNumber,
}) {
  final usesBankSelect = override?.usesBankSelect ?? defaults.usesBankSelect;
  final bankSelectMsb = override?.bankSelectMsb ?? defaults.bankSelectMsb;
  final bankSelectLsb = override?.bankSelectLsb ?? defaults.bankSelectLsb;

  final messages = <MidiMessage>[];
  if (usesBankSelect) {
    if (bankSelectMsb != null) {
      messages.add(
        ControlChangeMessage(
          channel: channel,
          controller: bankSelectMsbCc,
          value: bankSelectMsb,
        ),
      );
    }
    if (bankSelectLsb != null) {
      messages.add(
        ControlChangeMessage(
          channel: channel,
          controller: bankSelectLsbCc,
          value: bankSelectLsb,
        ),
      );
    }
  }
  messages.add(ProgramChangeMessage(channel: channel, program: patchNumber));
  return messages;
}
