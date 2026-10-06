/// How the MG-30 itself displays a slot: bank 01-32 and letter A-D, so slot 0
/// reads "01A" and slot 127 reads "32D".
///
/// The four-slots-per-bank numbering comes from the community `mg30-controller`
/// project's own bank arithmetic and matches the MIDI module brief's "01A/01B"
/// examples; it is a label for the program number, never a claim about the
/// device's memory layout. Program numbers themselves start at 0.
String mg30SlotLabel(int slot) {
  const letters = 'ABCD';
  final bank = (slot ~/ letters.length) + 1;
  return '${bank.toString().padLeft(2, '0')}${letters[slot % letters.length]}';
}
