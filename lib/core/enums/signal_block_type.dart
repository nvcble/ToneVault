/// What one block of a rig's signal chain is there to do.
///
/// Declaration order follows a conventional chain, from the guitar through to
/// the output, so iterating the enum gives a sensible order in the picker.
///
/// This is deliberately not [PedalCategory]. A block says what the rig needs at
/// that point in the chain, which is a decision the user makes before owning
/// anything to put in it; a category says what a pedal they own actually is.
/// `blockTypeFor` maps between the two.
enum SignalBlockType {
  input,
  tuner,
  wah,
  compressor,
  gate,
  boost,
  overdrive,
  distortion,
  fuzz,
  eq,
  modulation,
  chorus,
  flanger,
  phaser,
  tremolo,
  pitch,
  delay,
  reverb,
  amp,
  cab,
  ir,
  multiEffect,
  looper,
  di,
  utility,
  // Structural rather than effects: a rig can split anywhere, so these sit with
  // the other plumbing instead of somewhere in the middle of the dirt.
  split,
  merge,
  // Where signal leaves the board for something else to do its part, and where
  // it comes back. A send is not an output: the signal is expected back, and the
  // pair of them is what a rig into an amplifier's effects loop is made of.
  //
  // Dart already has `return`, so the value is named for what it is on a board.
  send,
  fxReturn,
  output,
  custom;

  String get label => switch (this) {
    SignalBlockType.input => 'Input',
    SignalBlockType.tuner => 'Tuner',
    SignalBlockType.wah => 'Wah',
    SignalBlockType.compressor => 'Compressor',
    SignalBlockType.gate => 'Gate',
    SignalBlockType.boost => 'Boost',
    SignalBlockType.overdrive => 'Overdrive',
    SignalBlockType.distortion => 'Distortion',
    SignalBlockType.fuzz => 'Fuzz',
    SignalBlockType.eq => 'EQ',
    SignalBlockType.modulation => 'Modulation',
    SignalBlockType.chorus => 'Chorus',
    SignalBlockType.flanger => 'Flanger',
    SignalBlockType.phaser => 'Phaser',
    SignalBlockType.tremolo => 'Tremolo',
    SignalBlockType.pitch => 'Pitch',
    SignalBlockType.delay => 'Delay',
    SignalBlockType.reverb => 'Reverb',
    SignalBlockType.amp => 'Amp',
    SignalBlockType.cab => 'Cab',
    SignalBlockType.ir => 'IR',
    SignalBlockType.multiEffect => 'Multi FX',
    SignalBlockType.looper => 'Looper',
    SignalBlockType.di => 'DI',
    SignalBlockType.utility => 'Utility',
    SignalBlockType.split => 'Split',
    SignalBlockType.merge => 'Merge',
    SignalBlockType.send => 'Send',
    SignalBlockType.fxReturn => 'Return',
    SignalBlockType.output => 'Output',
    SignalBlockType.custom => 'Custom',
  };

  /// Whether signal leaves the rig here, so the block is asked where it goes.
  bool get carriesDestination => this == output || this == send;

  /// Whether signal arrives from outside here, so the block is asked what it
  /// comes from.
  bool get carriesSource => this == input || this == fxReturn;

  /// Whether this block is one of the edges of the rig rather than something in
  /// the middle of it. An edge is described by where it reaches to, which is a
  /// different question from which pedal fills it - and usually no pedal does.
  bool get isBoundary => carriesDestination || carriesSource;
}
