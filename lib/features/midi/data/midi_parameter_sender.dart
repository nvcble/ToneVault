import '../../../core/errors/app_failure.dart';
import '../../../core/midi/midi_device_profile.dart';
import '../../../core/midi/midi_engine.dart';
import '../../../core/midi/midi_parameter_definition.dart';
import '../../../core/midi/midi_parameter_resolution.dart';

/// Sends one named parameter's value, resolving its CC through whichever
/// effective mapping the caller already has - see
/// `MidiParameterMappingRepository.watchEffectiveParameters`.
///
/// The one path every "Scene", "Current Block", "Pedal", block-model-select
/// and knob control in the app sends through: none of them is special-cased,
/// because all of them are just a named [MidiParameterDefinition].
class MidiParameterSender {
  const MidiParameterSender(this._engine);

  final MidiEngine _engine;

  Future<void> send({
    required MidiDeviceProfile profile,
    required List<MidiParameterDefinition> effectiveParameters,
    required String parameterName,
    required int value,
  }) async {
    final message = buildParameterMessage(
      effectiveParameters: effectiveParameters,
      parameterName: parameterName,
      channel: profile.defaultChannel,
      value: value,
    );
    if (message == null) {
      throw AppFailure(
        '"$parameterName" has no CC mapped to it, so it cannot be sent.',
      );
    }
    await guardFailure(
      () => _engine.send(message),
      'Could not send "$parameterName".',
    );
  }
}
