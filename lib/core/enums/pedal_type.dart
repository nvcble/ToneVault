/// How a pedal generates its sound, which drives how its controls are
/// presented: analog pedals lean on clock-face knobs, digital devices on
/// numeric values.
///
/// Deliberately says nothing about what a pedal *is*: a multi-effects unit is a
/// digital pedal of category [PedalCategory.multiEffects], and it is the
/// category that decides what its screen holds. See
/// `PedalCategory.hasOwnControls`.
///
/// Stored by name rather than by position, so a new type can be added anywhere
/// in this list without a migration and without moving any existing pedal.
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

// Kept for tracking: `multiEffects` used to be a fourth type, and
// `hasOwnControls` used to be answered here. Filing a unit as a type meant a
// digital multi-effects unit could not also be called digital, and every screen
// had to read the type to learn what a pedal does - which is the category's job.
// The rule now lives on `PedalCategory.hasOwnControls`, and the v8 migration
// rewrites the rows that were stored as this type.
//
//   multiEffects;
//   PedalType.multiEffects => 'Multi-effects',
//   bool get hasOwnControls => this != PedalType.multiEffects;
