import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/midi/midi_connection_state.dart';
import '../data/midi_clock_output_state.dart';
import 'midi_clock_controller.dart';
import 'midi_connection_controller.dart';
import 'midi_engine_providers.dart';

/// The MIDI Clock stream for one device profile.
///
/// Kept for the app's lifetime rather than disposed with the diagnostic
/// screen: a clock the user started is a thing that is happening, and it
/// should not stop because they went to look at a patch. It does stop on
/// disconnect, when the app is backgrounded, and on the first send that
/// fails - see [MidiClockController].
final StateNotifierProviderFamily<
  MidiClockController,
  MidiClockOutputState,
  String
>
midiClockProvider =
    StateNotifierProvider.family<
      MidiClockController,
      MidiClockOutputState,
      String
    >(
      (ref, profileId) => MidiClockController(
        ref.watch(midiEngineProvider),
        // Read lazily rather than watched: the name is wanted for a log
        // line, and rebuilding this controller - tearing down a running
        // clock - every time the connection state changes would be a cure
        // far worse than a stale label.
        deviceName: () {
          final snapshot = ref.read(midiConnectionProvider(profileId));
          if (snapshot.state != MidiConnectionState.connected) {
            return 'No device';
          }
          return snapshot.endpoints.firstOrNull?.name ?? 'Connected device';
        },
      ),
    );
