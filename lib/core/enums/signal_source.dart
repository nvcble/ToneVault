/// Where signal comes from when it arrives at a rig.
///
/// A rig does not always begin at the guitar. The four cable method has a second
/// beginning part-way through - what the amplifier's effects loop sends back - and
/// a re-amping setup begins at an interface. Stored, so a rig can say which.
enum SignalSource {
  guitar,
  physicalAmpFxSend,
  audioInterface,
  externalDevice,
  custom;

  String get label => switch (this) {
    SignalSource.guitar => 'Guitar',
    SignalSource.physicalAmpFxSend => 'Amp FX send',
    SignalSource.audioInterface => 'Audio interface',
    SignalSource.externalDevice => 'Another device',
    SignalSource.custom => 'Something else',
  };

  /// Whether this names a socket on a physical amplifier. The amp's FX send is
  /// the amp sending to the board, which is the opposite direction to the board's
  /// own send and the pair most easily muddled.
  bool get isPhysicalAmp => this == physicalAmpFxSend;
}
