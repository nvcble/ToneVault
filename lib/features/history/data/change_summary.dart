import '../../../core/database/app_database.dart';
import '../../../core/enums/change_type.dart';
import '../../../core/values/control_options.dart';
import '../../../core/values/control_value_label.dart';
import '../../../shared/formatting/app_date_format.dart';

/// Turns a stored history entry into the sentences shown on the timeline.
///
/// Kept out of the widgets because this is where the append-only log earns its
/// keep: every event type has to read as something, including the ones whose
/// configuration or control has since been deleted and whose foreign keys are
/// therefore null. The entry's copies of the names are what make that possible.
///
/// Nothing here is ever stored. Values live in the database as numbers in their
/// control's own domain, and a reading such as "2:30" is rendered from the
/// control each time it is shown.
String changeHeadline(ChangeLog entry, {PedalControl? control}) {
  final controlName = entry.controlName ?? 'A control';
  final configurationName = entry.configurationName ?? 'A configuration';

  return switch (entry.changeType) {
    ChangeType.controlValueChanged => _valueChange(entry, controlName, control),
    ChangeType.configurationCreated => '$configurationName created',
    ChangeType.configurationRenamed =>
      '${entry.oldText ?? configurationName} renamed to '
          '${entry.newText ?? configurationName}',
    ChangeType.configurationDeleted => '$configurationName deleted',
    ChangeType.controlAdded => '$controlName added',
    ChangeType.controlRemoved => '$controlName removed',
    ChangeType.pedalStatusChanged =>
      'Moved from ${entry.oldText ?? 'its previous status'} to '
          '${entry.newText ?? 'another status'}',
    ChangeType.pedalReplaced =>
      'Replaced by ${entry.newText ?? 'another pedal'}',
  };
}

/// What the change was made to, and when.
///
/// The pedal name is passed in rather than read from the entry, since a pedal's
/// own history tab has it in the app bar already and repeating it on every row
/// would waste the width.
String changeContext(ChangeLog entry, {String? pedalName}) {
  // Only a moved control needs telling which configuration it was moved in: the
  // configuration events already name it in the headline.
  final configuration = entry.changeType == ChangeType.controlValueChanged
      ? entry.configurationName
      : null;

  return [
    ?pedalName,
    ?configuration,
    formatDateTime(entry.createdAt),
  ].join(' · ');
}

String _valueChange(ChangeLog entry, String name, PedalControl? control) {
  final oldValue = entry.oldValue;
  final newValue = entry.newValue;

  if (newValue == null) {
    // Clearing a control says the configuration no longer specifies it, so where
    // it used to sit is the only part worth keeping in the sentence.
    return oldValue == null
        ? '$name cleared'
        : '$name cleared, was ${_reading(oldValue, control)}';
  }

  final reading = _reading(newValue, control);
  return oldValue == null
      ? '$name set to $reading'
      : '$name moved from ${_reading(oldValue, control)} to $reading';
}

/// A stored number read the way its own control reads it, or as the bare number
/// once that control has been removed and there is nothing left to read it with.
String _reading(double value, PedalControl? control) {
  if (control == null) {
    return formatControlNumber(value);
  }

  return formatControlValue(
    value,
    type: control.controlType,
    unit: control.unit,
    options: decodeControlOptions(control.options),
  );
}
