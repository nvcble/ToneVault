import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/midi/midi_engine.dart';
import '../../../core/midi/midi_transport.dart';
import '../../../core/midi/midi_transport_type.dart';
import '../../../core/midi/transports/usb_midi_transport.dart';
import '../data/midi_parameter_sender.dart';
import '../data/nux_mg30_v5_preset_capture_service.dart';
import '../data/nux_mg30_v5_preset_reader.dart';
import 'midi_preset_capture_providers.dart';

/// One engine for the app's lifetime, so a connection made from one screen is
/// still there when another opens.
final Provider<MidiEngine> midiEngineProvider = Provider<MidiEngine>((ref) {
  final engine = MidiEngine();
  ref.onDispose(engine.dispose);
  return engine;
});

final Provider<MidiParameterSender> midiParameterSenderProvider = Provider<MidiParameterSender>(
  (ref) => MidiParameterSender(ref.watch(midiEngineProvider)),
);

final Provider<NuxMg30V5PresetReader> nuxMg30V5PresetReaderProvider = Provider<NuxMg30V5PresetReader>(
  (ref) => NuxMg30V5PresetReader(ref.watch(midiEngineProvider)),
);

final Provider<NuxMg30V5PresetCaptureService> nuxMg30V5PresetCaptureServiceProvider =
    Provider<NuxMg30V5PresetCaptureService>(
      (ref) => NuxMg30V5PresetCaptureService(
        ref.watch(nuxMg30V5PresetReaderProvider),
        ref.watch(midiPresetCaptureRepositoryProvider),
      ),
    );

/// Builds the transport a connection type asks for.
///
/// Bluetooth is deliberately unhandled: no device profile the app ships asks
/// for it yet, and a transport implementation nothing calls would be dead
/// code the moment it needs to change. See [MidiTransportType].
MidiTransport transportFor(MidiTransportType type) {
  switch (type) {
    case MidiTransportType.usb:
      return UsbMidiTransport();
    case MidiTransportType.bluetooth:
      throw UnimplementedError('Bluetooth MIDI is not wired up yet.');
  }
}
