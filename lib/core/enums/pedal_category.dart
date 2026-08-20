/// What a pedal does. Declaration order follows a conventional signal chain,
/// so iterating the enum gives a sensible default ordering in pickers.
enum PedalCategory {
  tuner,
  compressor,
  equalizer,
  boost,
  overdrive,
  distortion,
  fuzz,
  noiseGate,
  modulation,
  chorus,
  flanger,
  phaser,
  tremolo,
  delay,
  reverb,
  ampSim,
  cabinetIr,
  multiEffects,
  looper,
  utility,
  other;

  String get label => switch (this) {
    PedalCategory.tuner => 'Tuner',
    PedalCategory.compressor => 'Compressor',
    PedalCategory.equalizer => 'EQ',
    PedalCategory.boost => 'Boost',
    PedalCategory.overdrive => 'Overdrive',
    PedalCategory.distortion => 'Distortion',
    PedalCategory.fuzz => 'Fuzz',
    PedalCategory.noiseGate => 'Noise Gate',
    PedalCategory.modulation => 'Modulation',
    PedalCategory.chorus => 'Chorus',
    PedalCategory.flanger => 'Flanger',
    PedalCategory.phaser => 'Phaser',
    PedalCategory.tremolo => 'Tremolo',
    PedalCategory.delay => 'Delay',
    PedalCategory.reverb => 'Reverb',
    PedalCategory.ampSim => 'Amp Sim',
    PedalCategory.cabinetIr => 'Cab / IR',
    PedalCategory.multiEffects => 'Multi Effects',
    PedalCategory.looper => 'Looper',
    PedalCategory.utility => 'Utility',
    PedalCategory.other => 'Other',
  };

  /// Whether a pedal of this category is dialled in on controls of its own.
  ///
  /// A multi-effects unit is not: its sounds live in patches, each with scenes
  /// of the pedals inside it, not on knobs across its face, so a list of its own
  /// controls has nothing to hold. Everything that offers control editing asks
  /// this rather than naming the category, so a second such category only has to
  /// be added here.
  bool get hasOwnControls => this != PedalCategory.multiEffects;
}
