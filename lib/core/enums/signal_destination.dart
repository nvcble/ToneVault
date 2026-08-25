/// Where signal goes when it leaves a rig.
///
/// A rig does not always end at an amplifier. It can end at the desk, at an
/// interface, in a pair of headphones, or in the front of an amp whose own effects
/// loop then brings it back - and a rig that ends in two of those at once is
/// ordinary rather than exotic, which is why this is asked of a block rather than
/// of the rig.
///
/// [physicalAmpInput] and [physicalAmpFxReturn] are two different sockets on the
/// same amplifier and are never interchangeable: the first is the front of the
/// amp, ahead of its preamp, and the second is the far side of its effects loop.
enum SignalDestination {
  physicalAmpInput,
  physicalAmpFxReturn,
  foh,
  audioInterface,
  di,
  monitor,
  headphones,
  externalDevice,
  custom;

  String get label => switch (this) {
    SignalDestination.physicalAmpInput => 'Amp input',
    SignalDestination.physicalAmpFxReturn => 'Amp FX return',
    SignalDestination.foh => 'Front of house',
    SignalDestination.audioInterface => 'Audio interface',
    SignalDestination.di => 'DI box',
    SignalDestination.monitor => 'Monitor',
    SignalDestination.headphones => 'Headphones',
    SignalDestination.externalDevice => 'Another device',
    SignalDestination.custom => 'Something else',
  };

  /// Whether this names a socket on a physical amplifier, which is worth spelling
  /// out on screen so a pedalboard's own send is never read as the amp's.
  bool get isPhysicalAmp =>
      this == physicalAmpInput || this == physicalAmpFxReturn;
}
