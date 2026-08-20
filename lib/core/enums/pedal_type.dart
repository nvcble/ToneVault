/// How a pedal generates its sound, which drives how its controls are
/// presented: analog pedals lean on clock-face knobs, digital devices on
/// numeric values.
///
/// Stored by name rather than by position, so a new type can be added anywhere
/// in this list without a migration and without moving any existing pedal.
enum PedalType {
  analog,
  digital,
  hybrid,
  multiEffects;

  String get label => switch (this) {
    PedalType.analog => 'Analog',
    PedalType.digital => 'Digital',
    PedalType.hybrid => 'Hybrid',
    PedalType.multiEffects => 'Multi-effects',
  };

  /// Whether a pedal of this type is dialled in on controls of its own.
  ///
  /// A multi-effects unit is not: its sounds live in patches and stomps inside
  /// the unit, not on knobs across its face, so a list of its own controls has
  /// nothing to hold. Everything that offers control editing asks this rather
  /// than naming the type, so a second such type only has to be added here.
  bool get hasOwnControls => this != PedalType.multiEffects;
}
