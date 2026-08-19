import '../../../core/enums/pedal_category.dart';
import '../../../core/enums/pedal_type.dart';
import 'pedal_draft.dart';

/// Sample pedals for filling an empty database while developing.
///
/// Development data only. Nothing seeds itself: this is reachable from a debug
/// build's settings screen and is left out of release builds, so a real
/// inventory is only ever what its owner entered.
const List<PedalDraft> devSeedPedals = [
  PedalDraft(
    name: 'Caline PureSky',
    brand: 'Caline',
    type: PedalType.analog,
    category: PedalCategory.overdrive,
  ),
  PedalDraft(
    name: 'MV Electronics Shredhead',
    brand: 'MV Electronics',
    type: PedalType.analog,
    category: PedalCategory.distortion,
  ),
  PedalDraft(
    name: 'Mooer Yellow Comp',
    brand: 'Mooer',
    type: PedalType.analog,
    category: PedalCategory.compressor,
  ),
  PedalDraft(
    name: 'Valeton EP1',
    brand: 'Valeton',
    type: PedalType.analog,
    category: PedalCategory.utility,
  ),
  PedalDraft(
    name: 'Rowin Noise Gate',
    brand: 'Rowin',
    type: PedalType.analog,
    category: PedalCategory.noiseGate,
  ),
  PedalDraft(
    name: 'Joyo American Sound',
    brand: 'Joyo',
    type: PedalType.analog,
    category: PedalCategory.ampSim,
  ),
  PedalDraft(
    name: 'NUX MG-30',
    brand: 'NUX',
    type: PedalType.digital,
    category: PedalCategory.multiEffects,
  ),
  PedalDraft(
    name: 'MVave Mini Universe',
    brand: 'MVave',
    type: PedalType.digital,
    category: PedalCategory.reverb,
  ),
  PedalDraft(
    name: 'Flamma FC03',
    brand: 'Flamma',
    type: PedalType.digital,
    category: PedalCategory.chorus,
  ),
];
