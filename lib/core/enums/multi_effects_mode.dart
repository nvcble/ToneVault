/// How a multi-effects unit was said to be organised, back when a unit had to be
/// declared as one or the other.
///
/// No screen asks anymore: a multi-effects unit keeps patches, each patch keeps
/// scenes, and each scene keeps the pedals it uses, so there is nothing to
/// choose between. The enum stays because `pedals.multi_effects_mode` still
/// holds the values written before that, and dropping it would leave the column
/// unreadable.
///
/// Stored by name rather than by position, so the order here can change without
/// a migration.
enum MultiEffectsMode {
  stomp,
  scene;

  String get label => switch (this) {
    MultiEffectsMode.stomp => 'Stomp mode',
    MultiEffectsMode.scene => 'Scene mode',
  };
}

// Kept for tracking: the words each mode put on screen. They went with the mode
// selector - a unit's tab is 'Patch' either way now, and what is inside it is a
// patch, its scenes, and the pedals in each scene.
//
//   String get description => switch (this) {
//     MultiEffectsMode.stomp =>
//       'Every stomp is one pedal, with its own controls and its own saved '
//           'settings.',
//     MultiEffectsMode.scene =>
//       'Several pedals sit on one patch, and the patch has a scene for each '
//           'sound.',
//   };
//
//   String get tabLabel => switch (this) {
//     MultiEffectsMode.stomp => 'Stomps',
//     MultiEffectsMode.scene => 'Patch',
//   };
//
//   String get componentsLabel => switch (this) {
//     MultiEffectsMode.stomp => 'Stomps',
//     MultiEffectsMode.scene => 'Pedals',
//   };
//
//   String get addComponentLabel => switch (this) {
//     MultiEffectsMode.stomp => 'Add stomp',
//     MultiEffectsMode.scene => 'Add pedal',
//   };
//
//   String get emptyComponentsMessage => switch (this) {
//     MultiEffectsMode.stomp =>
//       'Add one for each stomp on the unit. Each gets its own controls and its '
//           'own saved settings, exactly like a pedal on the floor.',
//     MultiEffectsMode.scene =>
//       'Add the pedals that make up this patch. A scene then says where each of '
//           'their controls sits.',
//   };
