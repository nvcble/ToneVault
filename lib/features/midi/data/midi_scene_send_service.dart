import '../../../core/database/daos/scene_dao.dart';
import '../../../core/midi/midi_device_profile.dart';
import '../../../core/midi/midi_engine.dart';
import '../../../core/midi/midi_parameter_definition.dart';
import '../../../core/midi/midi_parameter_resolution.dart';

/// Sends every knob and model-select value a scene holds, resolved through
/// whichever CC each control's name currently maps to.
///
/// Reads `SceneDao` directly rather than through `SceneValueRepository`:
/// this only reads what a scene holds, and writes nothing back, so it does
/// not need that repository's validation or history recording.
class MidiSceneSendService {
  const MidiSceneSendService(this._sceneDao, this._engine);

  final SceneDao _sceneDao;
  final MidiEngine _engine;

  /// Returns how many of the scene's values were actually sendable - a
  /// pedal in the scene that has nothing to do with this device (a stomp
  /// logged for its own sake) contributes nothing, silently.
  Future<int> sendSceneValues({
    required MidiDeviceProfile profile,
    required List<MidiParameterDefinition> effectiveParameters,
    required int sceneId,
  }) async {
    final controls = await _sceneDao.sceneControlsOf(sceneId);
    final values = await _sceneDao.valuesOf(sceneId);
    final valueByControlId = {
      for (final value in values) value.controlId: value.value,
    };

    final sceneValues = [
      for (final owned in controls)
        if (valueByControlId.containsKey(owned.control.id))
          MidiSceneControlValue(
            controlName: owned.control.name,
            value: valueByControlId[owned.control.id]!,
          ),
    ];

    final messages = buildSceneValueMessages(
      effectiveParameters: effectiveParameters,
      channel: profile.defaultChannel,
      values: sceneValues,
    );

    await _engine.sendAll(messages);
    return messages.length;
  }
}
