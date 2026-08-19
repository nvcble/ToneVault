/// How a pedal generates its sound, which drives how its controls are
/// presented: analog pedals lean on clock-face knobs, digital devices on
/// numeric values.
enum PedalType {
  analog,
  digital,
  hybrid;

  String get label => switch (this) {
    PedalType.analog => 'Analog',
    PedalType.digital => 'Digital',
    PedalType.hybrid => 'Hybrid',
  };
}
