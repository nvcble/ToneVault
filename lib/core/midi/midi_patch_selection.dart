import 'midi_message.dart';
import 'patch_selection_defaults.dart';

/// Standard MIDI Bank Select CC numbers - not specific to any device, and not
/// invented: both are part of the MIDI specification itself.
const int bankSelectMsbCc = 0;
const int bankSelectLsbCc = 32;

/// Builds the message sequence for loading [patchNumber] (counted from 1),
/// applying [override] on top of [defaults] field by field.
///
/// Patch 1 is sent as Program Change 0 - the near-universal convention for
/// devices numbered from one - which is itself part of what
/// [PatchSelectionDefaults.verificationStatus] has not confirmed.
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
        ControlChangeMessage(channel: channel, controller: bankSelectMsbCc, value: bankSelectMsb),
      );
    }
    if (bankSelectLsb != null) {
      messages.add(
        ControlChangeMessage(channel: channel, controller: bankSelectLsbCc, value: bankSelectLsb),
      );
    }
  }
  messages.add(ProgramChangeMessage(channel: channel, program: patchNumber - 1));
  return messages;
}
