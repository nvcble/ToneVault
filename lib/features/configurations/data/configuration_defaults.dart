import '../../../core/database/app_database.dart';

/// The positions a new configuration of these controls starts out with.
///
/// Only controls that declare a default are included. A knob whose default was
/// never recorded is left unset rather than filled in with a guess: a
/// configuration is a record of where the pedal actually was, and inventing
/// 12:00 for a knob nobody touched would make that record wrong.
Map<int, double> configurationDefaults(List<PedalControl> controls) {
  return {
    for (final control in controls)
      if (control.defaultValue != null) control.id: control.defaultValue!,
  };
}
