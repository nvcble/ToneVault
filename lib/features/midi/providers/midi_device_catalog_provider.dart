import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/midi/midi_device_profile.dart';
import '../../../core/midi/midi_device_registry.dart';

/// Every device the app can select, for the MIDI landing screen.
final Provider<List<MidiDeviceProfile>> midiDeviceCatalogProvider =
    Provider<List<MidiDeviceProfile>>((ref) => MidiDeviceRegistry.profiles);
