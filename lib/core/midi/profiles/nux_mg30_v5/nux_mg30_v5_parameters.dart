import '../../midi_block_definition.dart';
import '../../midi_parameter_definition.dart';
import '../../midi_parameter_names.dart';
import 'nux_mg30_v5_block_specs.dart';
import 'nux_mg30_v5_model_names.dart';

String _modelParameterName(NuxBlockSpec block) => '${block.label} model';

/// What the unit calls this knob, where that has been transcribed from the
/// manual, and the chart's own numbering everywhere else - see
/// [NuxBlockSpec.knobNames].
String _knobParameterName(NuxBlockSpec block, int index) =>
    index < block.knobNames.length
    ? block.knobNames[index]
    : '${block.label} Knob ${index + 1}';

/// Knob CCs whose range is not the 0-100 every other knob uses, exactly as
/// the chart states it: Modulation Knob 5 and Delay Knob 4 are 6-position
/// selectors, and the first two IR knobs are narrower still.
const Map<int, (double min, double max)> _rangeOverrides = {
  52: (0, 6), // Modulation Knob 5
  57: (0, 6), // Delay Knob 4
  66: (0, 7), // IR Knob 1
  67: (0, 2), // IR Knob 2
};

/// The parameters named individually in the chart rather than numbered as a
/// block's knobs - the Send/Return loop's own controls, and everything below
/// block level: patch-wide, pedal and scene selection, and the drum/looper.
///
/// Drum and looper control is out of scope for the patch/scene/block work the
/// MIDI module brief describes, but the CCs are still confirmed, so they are
/// kept here rather than dropped.
const List<MidiParameterDefinition> nuxMg30V5GlobalParameters = [
  MidiParameterDefinition(
    name: 'Patch Volume (toggle)',
    min: 1,
    max: 1,
    messageType: MidiParameterMessageType.controlChange,
    ccNumber: 11,
  ),
  MidiParameterDefinition(
    name: 'Send',
    min: 0,
    max: 100,
    messageType: MidiParameterMessageType.controlChange,
    ccNumber: 72,
  ),
  MidiParameterDefinition(
    name: 'Return',
    min: 0,
    max: 100,
    messageType: MidiParameterMessageType.controlChange,
    ccNumber: 73,
  ),
  MidiParameterDefinition(
    name: 'SR Routing',
    min: 0,
    max: 1,
    messageType: MidiParameterMessageType.controlChange,
    ccNumber: 74,
  ),
  MidiParameterDefinition(
    name: 'Patch Min',
    min: 0,
    max: 100,
    messageType: MidiParameterMessageType.controlChange,
    ccNumber: 75,
  ),
  MidiParameterDefinition(
    name: 'Patch Max',
    min: 0,
    max: 100,
    messageType: MidiParameterMessageType.controlChange,
    ccNumber: 76,
  ),
  MidiParameterDefinition(
    name: 'Patch Volume',
    min: 0,
    max: 100,
    messageType: MidiParameterMessageType.controlChange,
    ccNumber: 77,
  ),
  MidiParameterDefinition(
    name: 'Current Block',
    min: 0,
    max: 100,
    messageType: MidiParameterMessageType.controlChange,
    ccNumber: 78,
  ),
  MidiParameterDefinition(
    name: 'Pedal',
    min: 0,
    max: 100,
    messageType: MidiParameterMessageType.controlChange,
    ccNumber: 79,
  ),
  // CC 80 is what this app's own V5 chart transcription names for Scene.
  // Flagged rather than changed: the GPL-3.0 `mg30-controller` reference
  // project reads Scene from CC 79 (0x4F) instead on its firmware
  // (v4.0.3, see its `device.dart`) - a real conflict between the two
  // sources, unresolved until tried against this app's own V5 unit.
  MidiParameterDefinition(
    name: MidiParameterNames.scene,
    min: 0,
    max: 100,
    messageType: MidiParameterMessageType.controlChange,
    ccNumber: 80,
  ),
  MidiParameterDefinition(
    name: 'Drum Enable',
    min: 0,
    max: 100,
    messageType: MidiParameterMessageType.controlChange,
    ccNumber: 81,
  ),
  MidiParameterDefinition(
    name: 'Drum Type',
    min: 0,
    max: 100,
    messageType: MidiParameterMessageType.controlChange,
    ccNumber: 82,
  ),
  MidiParameterDefinition(
    name: 'Drum Level',
    min: 0,
    max: 100,
    messageType: MidiParameterMessageType.controlChange,
    ccNumber: 83,
  ),
  MidiParameterDefinition(
    name: 'Loop Level',
    min: 0,
    max: 100,
    messageType: MidiParameterMessageType.controlChange,
    ccNumber: 84,
  ),
  MidiParameterDefinition(
    name: 'Loop State',
    min: 0,
    max: 100,
    messageType: MidiParameterMessageType.controlChange,
    ccNumber: 85,
  ),
];

/// Tap tempo and the two assignable footswitches - controls the unit really
/// has, with no CC number of their own here, and no known way to reach them
/// over MIDI at all.
///
/// The chart's 86 rows stop at CC 85 and name none of these three. An earlier
/// note here said QuickTone's Custom MIDI page was where a player points them
/// at a CC of their choice; **that was wrong, and checking the real thing
/// disproved it** (QuickTone 2.4.12.27, 2026-10-14): there is no Tap Tempo row
/// on that page, and assigning a CC to Tap Tempo here and tapping it left the
/// unit's tempo where it was. Switch A and B have not been checked the same
/// way, so they are "no CC known" rather than "no CC exists" - but the page
/// that was supposed to carry all three does not carry the one that was
/// looked for.
///
/// They stay listed with [MidiParameterDefinition.ccNumber] null rather than
/// with a guessed number, so the control appears and says plainly that nothing
/// is assigned to it. Assigning one on the CC Mapping screen is still allowed
/// - the user may yet find a route this app does not know about - but it is
/// not expected to work, and a CC picked at random is likely to be a real amp
/// parameter the unit *will* act on. Inventing a number here would have done
/// that silently.
const List<MidiParameterDefinition> nuxMg30V5AssignableParameters = [
  MidiParameterDefinition(
    name: MidiParameterNames.tapTempo,
    min: 0,
    max: 127,
    messageType: MidiParameterMessageType.controlChange,
  ),
  MidiParameterDefinition(
    name: MidiParameterNames.switchA,
    min: 0,
    max: 127,
    messageType: MidiParameterMessageType.controlChange,
  ),
  MidiParameterDefinition(
    name: MidiParameterNames.switchB,
    min: 0,
    max: 127,
    messageType: MidiParameterMessageType.controlChange,
  ),
];

/// Every CC the V5 MIDI implementation chart confirms, built from
/// [nuxMg30V5Blocks] and [nuxMg30V5GlobalParameters] rather than transcribed
/// by hand, so the block table stays the one place a chart correction has to
/// be made - plus [nuxMg30V5AssignableParameters], which carry no CC.
final List<MidiParameterDefinition> nuxMg30V5Parameters = _buildParameters();

List<MidiParameterDefinition> _buildParameters() {
  final definitions = <MidiParameterDefinition>[];

  for (final block in nuxMg30V5Blocks) {
    final typeSelectCc = block.typeSelectCc;
    // Null for the Volume block alone, which the chart gives no CC: nothing to
    // list, and listing a made-up CC is how a wrong message gets sent.
    if (typeSelectCc != null) {
      definitions.add(
        MidiParameterDefinition(
          name: _modelParameterName(block),
          min: 1,
          max: block.modelCount.toDouble(),
          messageType: MidiParameterMessageType.controlChange,
          ccNumber: typeSelectCc,
        ),
      );
    }

    for (var index = 0; index < block.knobCcs.length; index++) {
      final cc = block.knobCcs[index];
      final (min, max) = _rangeOverrides[cc] ?? (0.0, 100.0);
      definitions.add(
        MidiParameterDefinition(
          name: _knobParameterName(block, index),
          min: min,
          max: max,
          messageType: MidiParameterMessageType.controlChange,
          ccNumber: cc,
        ),
      );
    }
  }

  definitions.addAll(nuxMg30V5GlobalParameters);
  definitions.addAll(nuxMg30V5AssignableParameters);
  return definitions;
}

/// One definition per block of the chain, in chain order - every one of them,
/// so the gear seeded for a linked unit is the chain the player sees on it.
///
/// Send/Return's controls are the ones the chart names rather than numbers, and
/// Volume's are none at all: a block with nothing to set is still a block of the
/// chain, and leaving it out is what made the app's list disagree with the unit.
final List<MidiBlockDefinition> nuxMg30V5BlockDefinitions =
    _buildBlockDefinitions();

List<MidiBlockDefinition> _buildBlockDefinitions() {
  return [
    for (final block in nuxMg30V5Blocks)
      MidiBlockDefinition(
        label: block.label,
        modelParameterName: _modelParameterName(block),
        modelCount: block.modelCount,
        // Only where the chart gives the block a type-select CC: naming the
        // models of a block nothing can select would offer a control that
        // silently sends nothing - the Volume block.
        modelNames: block.typeSelectCc == null
            ? const []
            : nuxMg30V5ModelNames[block.block] ?? const [],
        knobParameterNames: block.namedParameters.isNotEmpty
            ? block.namedParameters
            : [
                for (var index = 0; index < block.knobCcs.length; index++)
                  _knobParameterName(block, index),
              ],
      ),
  ];
}
