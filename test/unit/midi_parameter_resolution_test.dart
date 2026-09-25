import 'package:flutter_test/flutter_test.dart';
import 'package:tone_vault/core/midi/midi_message.dart';
import 'package:tone_vault/core/midi/midi_parameter_definition.dart';
import 'package:tone_vault/core/midi/midi_parameter_override.dart';
import 'package:tone_vault/core/midi/midi_parameter_resolution.dart';

const _scene = MidiParameterDefinition(
  name: 'Scene',
  min: 0,
  max: 100,
  messageType: MidiParameterMessageType.controlChange,
  ccNumber: 80,
);

const _pedal = MidiParameterDefinition(
  name: 'Pedal',
  min: 0,
  max: 100,
  messageType: MidiParameterMessageType.controlChange,
  ccNumber: 79,
);

void main() {
  group('applyParameterOverrides', () {
    test('passes a parameter through unchanged when nothing overrides it', () {
      final result = applyParameterOverrides([_scene, _pedal], const []);

      expect(result, [_scene, _pedal]);
    });

    test('substitutes the CC of a matching override, by name', () {
      final result = applyParameterOverrides(
        [_scene, _pedal],
        const [MidiParameterOverride(parameterName: 'Scene', ccNumber: 90)],
      );

      expect(result.firstWhere((d) => d.name == 'Scene').ccNumber, 90);
      expect(result.firstWhere((d) => d.name == 'Pedal').ccNumber, 79);
    });

    test('ignores an override naming a parameter the device does not ship', () {
      final result = applyParameterOverrides(
        [_scene],
        const [
          MidiParameterOverride(parameterName: 'Does not exist', ccNumber: 1),
        ],
      );

      expect(result, [_scene]);
    });
  });

  group('buildParameterMessage', () {
    test('builds a Control Change from the effective CC', () {
      final message = buildParameterMessage(
        effectiveParameters: [_scene],
        parameterName: 'Scene',
        channel: 0,
        value: 2,
      );

      expect(message, isA<ControlChangeMessage>());
      expect(message!.toBytes(), [0xB0, 80, 2]);
    });

    test('is null for a parameter not in the effective list', () {
      final message = buildParameterMessage(
        effectiveParameters: [_scene],
        parameterName: 'Does not exist',
        channel: 0,
        value: 1,
      );

      expect(message, isNull);
    });

    test('is null for a parameter with no CC to send', () {
      const noCc = MidiParameterDefinition(
        name: 'Nothing',
        min: 0,
        max: 1,
        messageType: MidiParameterMessageType.none,
      );

      final message = buildParameterMessage(
        effectiveParameters: [noCc],
        parameterName: 'Nothing',
        channel: 0,
        value: 1,
      );

      expect(message, isNull);
    });
  });
}
