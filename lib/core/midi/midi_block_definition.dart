/// One block of a device's signal chain, generic across any device profile -
/// the engine and the gear-seeding logic that reads this never see a NUX
/// block name directly, only this shape.
///
/// [modelParameterName] and each of [knobParameterNames] name a row in the
/// same profile's `parameterDefinitions`, so a caller resolves the CC for
/// either the same way: by parameter name.
class MidiBlockDefinition {
  const MidiBlockDefinition({
    required this.label,
    required this.modelParameterName,
    required this.modelCount,
    required this.knobParameterNames,
    this.modelNames = const [],
  });

  final String label;
  final String modelParameterName;
  final int modelCount;
  final List<String> knobParameterNames;

  /// What the device calls each model, in model-code order, where the profile
  /// knows them - so the seeded model control reads "BRIT 800" rather than 12.
  ///
  /// Empty leaves the control a plain 1..[modelCount] number, which is all a
  /// profile without a name table can honestly offer.
  final List<String> modelNames;
}
