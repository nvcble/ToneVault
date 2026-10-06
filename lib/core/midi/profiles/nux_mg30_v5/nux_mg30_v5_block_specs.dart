import 'nux_mg30_v5_block.dart';

/// One block's confirmed shape from the V5 MIDI implementation chart: the CC
/// that selects which model it runs, how many models it has, and the CCs of
/// its own knobs (in the chart's own "Knob 1", "Knob 2"... order).
///
/// The Send/Return block's three parameters have real names in the chart
/// (Send, Return, SR Routing) rather than numbered knobs, so it carries no
/// [knobCcs] here - they are listed by name in `nux_mg30_v5_parameters.dart`
/// instead.
class NuxBlockSpec {
  const NuxBlockSpec({
    required this.block,
    required this.label,
    required this.modelCount,
    this.typeSelectCc,
    this.knobCcs = const [],
    this.namedParameters = const [],
    this.knobNames = const [],
  });

  final NuxMg30Block block;
  final String label;

  /// CC that picks which model this block runs, or null for a block the chart
  /// gives no CC at all - the Volume block, which the unit still shows in its
  /// chain.
  ///
  /// The chart documents its valid range as 1..[modelCount] rather than
  /// 0..[modelCount] - whether 0 bypasses the block instead is not stated, so
  /// [MidiSupportLevel.partiallySupported] is what `nuxMg30V5Capabilities`
  /// gives `MidiFeature.blockBypass`.
  final int? typeSelectCc;

  final int modelCount;
  final List<int> knobCcs;

  /// Controls the chart names rather than numbers, listed in
  /// `nuxMg30V5GlobalParameters` - the Send/Return loop's Send, Return and SR
  /// Routing. Used in place of [knobCcs] for that block.
  final List<String> namedParameters;

  /// What the unit itself calls each of [knobCcs], in the same order - "Gain",
  /// "Bass", "Middle" and so on, from the MG-30 manual.
  ///
  /// Empty until that table is transcribed, and a block may be filled in on its
  /// own: wherever it is empty the chart's own "Knob 1", "Knob 2"... is used, so
  /// a knob is never given a name nothing confirmed.
  final List<String> knobNames;
}

/// Every block of the NUX MG-30 (V5) signal chain, in the order signal reaches
/// them - which is the order the chart lists their type-select CCs (IDs 1-10,
/// then IDs 13 onward for the knobs), and the order the unit shows them in.
const List<NuxBlockSpec> nuxMg30V5Blocks = [
  NuxBlockSpec(
    block: NuxMg30Block.wah,
    label: 'Wah',
    typeSelectCc: 0,
    modelCount: 5,
    knobCcs: [12, 13],
  ),
  NuxBlockSpec(
    block: NuxMg30Block.compressor,
    label: 'Compressor',
    typeSelectCc: 1,
    modelCount: 3,
    knobCcs: [14, 15, 16, 17],
  ),
  NuxBlockSpec(
    block: NuxMg30Block.effect,
    label: 'Effect',
    typeSelectCc: 2,
    modelCount: 15,
    knobCcs: [18, 19, 20, 21, 22, 23],
  ),
  NuxBlockSpec(
    block: NuxMg30Block.amp,
    label: 'Amp',
    typeSelectCc: 3,
    modelCount: 35,
    knobCcs: [24, 25, 26, 27, 28, 29, 30, 31],
  ),
  NuxBlockSpec(
    block: NuxMg30Block.eq,
    label: 'EQ',
    typeSelectCc: 4,
    modelCount: 4,
    knobCcs: [32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43],
  ),
  NuxBlockSpec(
    block: NuxMg30Block.noiseGate,
    label: 'Noise Gate',
    typeSelectCc: 5,
    modelCount: 1,
    knobCcs: [44, 45, 46, 47],
  ),
  NuxBlockSpec(
    block: NuxMg30Block.modulation,
    label: 'Modulation',
    typeSelectCc: 6,
    modelCount: 14,
    knobCcs: [48, 49, 50, 51, 52, 53],
  ),
  NuxBlockSpec(
    block: NuxMg30Block.delay,
    label: 'Delay',
    typeSelectCc: 7,
    modelCount: 8,
    knobCcs: [54, 55, 56, 57, 58, 59, 60, 61],
  ),
  NuxBlockSpec(
    block: NuxMg30Block.reverb,
    label: 'Reverb',
    typeSelectCc: 8,
    modelCount: 6,
    knobCcs: [62, 63, 64, 65],
  ),
  NuxBlockSpec(
    block: NuxMg30Block.ir,
    label: 'IR',
    typeSelectCc: 9,
    modelCount: 25,
    knobCcs: [66, 67, 68, 69, 70, 71],
  ),
  NuxBlockSpec(
    block: NuxMg30Block.sendReturn,
    label: 'Send/Return',
    typeSelectCc: 10,
    modelCount: 1,
    namedParameters: ['Send', 'Return', 'SR Routing'],
  ),
  // Last in the chain and absent from the chart: no CC selects a model for it
  // and none moves it, so it carries no controls. It is here because the unit
  // lists it, and a chain the app shows without it is not the one in front of
  // the player.
  NuxBlockSpec(block: NuxMg30Block.volume, label: 'Volume', modelCount: 1),
];
