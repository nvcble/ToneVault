import 'control_validator.dart';

/// A free name for a copy of the control called [name], given the names already
/// [taken] on the same pedal.
///
/// "Volume" becomes "Volume copy", and then "Volume copy 2": the user asked for
/// another control like this one, not to name it first, and the copy can be
/// renamed afterwards like any other control.
///
/// Names are compared without case, the same way `ControlRepository` decides two
/// controls clash - "Volume copy" and "volume copy" are equally ambiguous to read
/// back on one pedal.
String copyNameFor(
  String name, {
  required Iterable<String> taken,
  int maxLength = ControlValidator.nameMaxLength,
}) {
  final used = {for (final one in taken) one.trim().toLowerCase()};

  // Each attempt carries a different marker, so one of `used.length + 1` of them
  // is free and the loop cannot run on.
  var candidate = '';
  for (var copy = 1; copy <= used.length + 1; copy++) {
    candidate = _marked(name, copy == 1 ? ' copy' : ' copy $copy', maxLength);
    if (!used.contains(candidate.toLowerCase())) {
      break;
    }
  }
  return candidate;
}

/// [name] with [marker] on the end, within [maxLength].
///
/// The marker is what makes the name free and what tells the user which row is
/// the copy, so a name at the column's limit is clipped to make room for it
/// rather than the marker being dropped.
String _marked(String name, String marker, int maxLength) {
  final room = (maxLength - marker.length).clamp(0, name.length);
  return '${name.substring(0, room).trimRight()}$marker';
}
