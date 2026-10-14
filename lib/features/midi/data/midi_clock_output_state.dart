import 'midi_clock_report.dart';

/// One line of the clock diagnostic's own log.
///
/// Not a `MidiLogEntry`: the engine's log is one row per message, which a
/// clock stream would bury, so this log carries the one-off messages (Start,
/// Stop, a test pulse), the failures, and the periodic summary of everything
/// in between.
class MidiClockLogEntry {
  const MidiClockLogEntry({
    required this.timestamp,
    required this.type,
    required this.device,
    this.bytes,
    this.detail,
    this.isFailure = false,
  });

  final DateTime timestamp;

  /// What happened - a MIDI message type, or something the diagnostic itself
  /// did such as a tempo change.
  final String type;

  /// The MIDI output this went to, as the connection screen names it, or
  /// "No device" when there was nothing connected to send to.
  final String device;

  /// The bytes in hex, or null for a line that is not a message.
  final String? bytes;

  final String? detail;

  /// Whether this records something that did not work. A send that was
  /// *attempted* without error is still only attempted - see
  /// [MidiClockReport.pulsesSent].
  final bool isFailure;
}

/// Everything the MIDI Clock Test panel draws.
class MidiClockOutputState {
  const MidiClockOutputState({
    required this.bpm,
    this.outputEnabled = false,
    this.report,
    this.entries = const [],
  });

  /// The tempo the clock is aimed at, whether or not it is running - set by
  /// typing, by the nudge buttons or by tapping.
  final int bpm;

  /// Whether anything outside the diagnostic panel may drive the clock.
  ///
  /// Off unless the user turns it on, so tapping tempo on the performance
  /// rail cannot start putting MIDI on the wire that nobody asked for. The
  /// panel's own Start button is an explicit action and does not consult it.
  final bool outputEnabled;

  /// Counters from the generator, refreshed periodically rather than per
  /// pulse. Null until the stream has been started once.
  final MidiClockReport? report;

  /// Newest first, and bounded - see `MidiClockController.maxLogEntries`.
  final List<MidiClockLogEntry> entries;

  bool get isRunning => report?.isRunning ?? false;

  MidiClockLogEntry? get lastEntry => entries.isEmpty ? null : entries.first;

  MidiClockOutputState copyWith({
    int? bpm,
    bool? outputEnabled,
    MidiClockReport? report,
    List<MidiClockLogEntry>? entries,
  }) => MidiClockOutputState(
    bpm: bpm ?? this.bpm,
    outputEnabled: outputEnabled ?? this.outputEnabled,
    report: report ?? this.report,
    entries: entries ?? this.entries,
  );
}
