/// How a multi-effects unit is organised, chosen once for the whole unit.
///
/// The two modes are how these units are actually used, and they want different
/// screens: a stomp is a pedal in its own right, while a scene is one sound of a
/// patch that several pedals make together.
///
/// Every word either mode puts on screen lives here, so the widgets that show
/// them hold no copy of their own and a third mode would be one entry.
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

  String get description => switch (this) {
    MultiEffectsMode.stomp =>
      'Every stomp is one pedal, with its own controls and its own saved '
          'settings.',
    MultiEffectsMode.scene =>
      'Several pedals sit on one patch, and the patch has a scene for each '
          'sound.',
  };

  /// What the unit's tab on its own screen is called, in place of the
  /// Configurations tab an ordinary pedal gets.
  String get tabLabel => switch (this) {
    MultiEffectsMode.stomp => 'Stomps',
    MultiEffectsMode.scene => 'Patch',
  };

  /// The pedals inside the unit. They are the same rows either way; only the
  /// word a player would use for them differs.
  String get componentsLabel => switch (this) {
    MultiEffectsMode.stomp => 'Stomps',
    MultiEffectsMode.scene => 'Pedals',
  };

  String get addComponentLabel => switch (this) {
    MultiEffectsMode.stomp => 'Add stomp',
    MultiEffectsMode.scene => 'Add pedal',
  };

  String get emptyComponentsMessage => switch (this) {
    MultiEffectsMode.stomp =>
      'Add one for each stomp on the unit. Each gets its own controls and its '
          'own saved settings, exactly like a pedal on the floor.',
    MultiEffectsMode.scene =>
      'Add the pedals that make up this patch. A scene then says where each of '
          'their controls sits.',
  };
}
