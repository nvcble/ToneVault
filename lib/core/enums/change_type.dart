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
  pedalReplaced;

  String get label => switch (this) {
    ChangeType.controlValueChanged => 'Setting changed',
    ChangeType.configurationCreated => 'Configuration created',
    ChangeType.configurationRenamed => 'Configuration renamed',
    ChangeType.configurationDeleted => 'Configuration deleted',
    ChangeType.controlAdded => 'Control added',
    ChangeType.controlRemoved => 'Control removed',
    ChangeType.pedalStatusChanged => 'Status changed',
    ChangeType.pedalReplaced => 'Pedal replaced',
  };

  /// Whether this event carries numeric old/new values worth rendering as a
  /// `35 -> 40` transition.
  bool get hasValueTransition => this == ChangeType.controlValueChanged;
}
