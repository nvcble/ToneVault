import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/midi/midi_engine.dart';
import '../../../core/midi/midi_log_entry.dart';
import 'midi_engine_providers.dart';

/// A bounded diagnostic capture: only what happened on the wire between
/// [start] and [stop], for exporting and analyzing later - distinct from the
/// MIDI Monitor's always-on rolling log, which keeps running regardless of
/// whether a capture is open.
class MidiCaptureState {
  const MidiCaptureState({this.isCapturing = false, this.entries = const []});

  final bool isCapturing;
  final List<MidiLogEntry> entries;

  MidiCaptureState copyWith({bool? isCapturing, List<MidiLogEntry>? entries}) =>
      MidiCaptureState(
        isCapturing: isCapturing ?? this.isCapturing,
        entries: entries ?? this.entries,
      );
}

/// See section "MIDI Capture Mode" of the diagnostic brief: Start Capture,
/// Stop Capture, Clear and Export are the only actions this exposes -
/// nothing here decides what any captured byte means.
class MidiCaptureController extends StateNotifier<MidiCaptureState> {
  MidiCaptureController(this._engine) : super(const MidiCaptureState());

  final MidiEngine _engine;
  StreamSubscription<MidiLogEntry>? _subscription;

  void start() {
    if (state.isCapturing) {
      return;
    }
    _subscription = _engine.log.listen(_onEntry);
    state = state.copyWith(isCapturing: true);
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    state = state.copyWith(isCapturing: false);
  }

  void clear() {
    state = state.copyWith(entries: const []);
  }

  void _onEntry(MidiLogEntry entry) {
    state = state.copyWith(entries: [...state.entries, entry]);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final StateNotifierProvider<MidiCaptureController, MidiCaptureState>
midiCaptureProvider =
    StateNotifierProvider<MidiCaptureController, MidiCaptureState>(
      (ref) => MidiCaptureController(ref.watch(midiEngineProvider)),
    );
