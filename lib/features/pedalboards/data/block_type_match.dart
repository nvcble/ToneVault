import '../../../core/enums/pedal_category.dart';
import '../../../core/enums/signal_block_type.dart';

/// What a pedal of each category is for, said as a block of a signal chain.
///
/// Most categories name the same thing a block does, so the map only has to
/// carry the few that are spelled differently or have no block of their own.
/// Anything missing falls through to [SignalBlockType.custom], which is what
/// `other` deserves and what a category added later gets until it is listed.
const Map<PedalCategory, SignalBlockType> _blockTypes = {
  PedalCategory.tuner: SignalBlockType.tuner,
  PedalCategory.compressor: SignalBlockType.compressor,
  PedalCategory.equalizer: SignalBlockType.eq,
  PedalCategory.boost: SignalBlockType.boost,
  PedalCategory.overdrive: SignalBlockType.overdrive,
  PedalCategory.distortion: SignalBlockType.distortion,
  PedalCategory.fuzz: SignalBlockType.fuzz,
  PedalCategory.noiseGate: SignalBlockType.gate,
  PedalCategory.modulation: SignalBlockType.modulation,
  PedalCategory.chorus: SignalBlockType.chorus,
  PedalCategory.flanger: SignalBlockType.flanger,
  PedalCategory.phaser: SignalBlockType.phaser,
  PedalCategory.tremolo: SignalBlockType.tremolo,
  PedalCategory.delay: SignalBlockType.delay,
  PedalCategory.reverb: SignalBlockType.reverb,
  PedalCategory.ampSim: SignalBlockType.amp,
  PedalCategory.cabinetIr: SignalBlockType.cab,
  PedalCategory.multiEffects: SignalBlockType.multiEffect,
  PedalCategory.looper: SignalBlockType.looper,
  PedalCategory.utility: SignalBlockType.utility,
};

/// The block a pedal of [category] would fill, used to pick a type for the user
/// when they add a block by choosing the pedal that goes in it.
SignalBlockType blockTypeFor(PedalCategory category) =>
    _blockTypes[category] ?? SignalBlockType.custom;

/// The categories worth offering first for a block of [type].
///
/// Empty where no category matches - a rig can plan an input, an IR loader or a
/// DI without any category standing for one - and the picker then falls back to
/// offering everything rather than nothing.
Set<PedalCategory> categoriesFor(SignalBlockType type) => {
  for (final entry in _blockTypes.entries)
    if (entry.value == type) entry.key,
};
