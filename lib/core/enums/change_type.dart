/// What kind of event a change log entry records.
///
/// Without this, a log row's meaning would have to be inferred from which of
/// its nullable columns happen to be set. Storing the intent explicitly keeps
/// the history timeline renderable without guessing.
enum ChangeType {
  controlValueChanged,
  configurationCreated,
  configurationRenamed,
  configurationDeleted,
  controlAdded,
  controlRemoved,
  pedalStatusChanged,
  pedalReplaced,
  // The patches of a multi-effects unit and the scenes inside them. Appended
  // rather than filed next to the configuration events because the column stores
  // the name of the value, so nothing depends on the order here.
  patchCreated,
  patchRenamed,
  patchDeleted,
  sceneCreated,
  sceneRenamed,
  sceneDeleted;

  String get label => switch (this) {
    ChangeType.controlValueChanged => 'Setting changed',
    ChangeType.configurationCreated => 'Configuration created',
    ChangeType.configurationRenamed => 'Configuration renamed',
    ChangeType.configurationDeleted => 'Configuration deleted',
    ChangeType.controlAdded => 'Control added',
    ChangeType.controlRemoved => 'Control removed',
    ChangeType.pedalStatusChanged => 'Status changed',
    ChangeType.pedalReplaced => 'Pedal replaced',
    ChangeType.patchCreated => 'Patch created',
    ChangeType.patchRenamed => 'Patch renamed',
    ChangeType.patchDeleted => 'Patch deleted',
    ChangeType.sceneCreated => 'Scene created',
    ChangeType.sceneRenamed => 'Scene renamed',
    ChangeType.sceneDeleted => 'Scene deleted',
  };

  /// Whether this event carries numeric old/new values worth rendering as a
  /// `35 -> 40` transition.
  bool get hasValueTransition => this == ChangeType.controlValueChanged;
}
