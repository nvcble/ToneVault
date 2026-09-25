import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/midi/midi_engine.dart';
import '../../../core/midi/midi_log_entry.dart';
import 'midi_engine_providers.dart';

/// The most recent messages sent or received, newest last.
///
/// Starts from [MidiEngine.history] rather than empty, so opening the
/// Monitor for the first time still shows whatever was sent or received
/// while nothing was watching.
class MidiMonitorController extends StateNotifier<List<MidiLogEntry>> {
  MidiMonitorController(MidiEngine engine) : super(engine.history) {
    _subscription = engine.log.listen(_onEntry);
  }

  static const _maxEntries = 200;
  StreamSubscription<MidiLogEntry>? _subscription;

  void _onEntry(MidiLogEntry entry) {
    final updated = [...state, entry];
    state = updated.length > _maxEntries
        ? updated.sublist(updated.length - _maxEntries)
        : updated;
  }

  void clear() => state = const [];

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final StateNotifierProvider<MidiMonitorController, List<MidiLogEntry>>
midiMonitorProvider =
    StateNotifierProvider<MidiMonitorController, List<MidiLogEntry>>(
      (ref) => MidiMonitorController(ref.watch(midiEngineProvider)),
    );
