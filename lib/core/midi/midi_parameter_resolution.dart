import 'midi_message.dart';
import 'midi_parameter_definition.dart';
import 'midi_parameter_override.dart';

/// Applies [overrides] on top of [defaults] by parameter name, so the rest of
/// the app reads one list that already reflects a user's own remapping -
/// exactly what NUX's QuickTone app lets someone do to the MG-30 itself.
///
/// A parameter with no matching override passes through unchanged. An
/// override naming a parameter that does not exist in [defaults] is ignored
/// rather than added: a user can redirect which CC an existing function uses,
/// not invent a new function the device profile never confirmed.
List<MidiParameterDefinition> applyParameterOverrides(
  List<MidiParameterDefinition> defaults,
  List<MidiParameterOverride> overrides,
) {
  final ccByName = {
    for (final override in overrides) override.parameterName: override.ccNumber,
  };

  return [
    for (final definition in defaults)
      if (ccByName.containsKey(definition.name))
        definition.withCcNumber(ccByName[definition.name]!)
      else
        definition,
  ];
}

/// Builds a Control Change for [parameterName], reading its CC number out of
/// [effectiveParameters] - the list [applyParameterOverrides] already
/// resolved - rather than off a device profile's fixed defaults.
///
/// Null when [parameterName] does not appear in [effectiveParameters], or
/// when it is not a Control Change parameter at all.
MidiMessage? buildParameterMessage({
  required List<MidiParameterDefinition> effectiveParameters,
  required String parameterName,
  required int channel,
  required int value,
}) {
  final definition = effectiveParameters
      .where((candidate) => candidate.name == parameterName)
      .firstOrNull;
  if (definition == null ||
      definition.messageType != MidiParameterMessageType.controlChange ||
      definition.ccNumber == null) {
    return null;
  }

  return ControlChangeMessage(
    channel: channel,
    controller: definition.ccNumber!,
    value: value,
  );
}

/// One control's stored value, named the way `buildParameterMessage` reads a
/// name - never a controller number itself, since a stored value comes from
/// a `PedalControl` row and does not know what CC it is bound to.
class MidiSceneControlValue {
  const MidiSceneControlValue({required this.controlName, required this.value});

  final String controlName;
  final double value;
}

/// Builds one Control Change per entry in [values] that resolves to a real
/// parameter, in the order given. An entry naming a control the device
/// profile does not ship - a knob the user logged that has nothing to do
/// with this device - is silently skipped rather than refused, since a scene
/// can hold pedals that are not MIDI parameters at all.
List<MidiMessage> buildSceneValueMessages({
  required List<MidiParameterDefinition> effectiveParameters,
  required int channel,
  required List<MidiSceneControlValue> values,
}) {
  return [
    for (final value in values)
      buildParameterMessage(
        effectiveParameters: effectiveParameters,
        parameterName: value.controlName,
        channel: channel,
        value: value.value.round(),
      ),
  ].whereType<MidiMessage>().toList();
}
