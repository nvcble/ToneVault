/// A user's own CC number for one named parameter of one device profile,
/// where it differs from the device profile's shipped default.
///
/// The domain shape of a `MidiParameterOverride` database row, kept free of
/// Drift so the resolution logic in `midi_parameter_resolution.dart` has
/// nothing to do with persistence and can be tested without a database.
class MidiParameterOverride {
  const MidiParameterOverride({
    required this.parameterName,
    required this.ccNumber,
  });

  final String parameterName;
  final int ccNumber;
}
