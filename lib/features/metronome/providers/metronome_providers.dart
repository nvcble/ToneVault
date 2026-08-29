import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/metronome.dart';
import '../../../core/audio/metronome_provider.dart';
import '../../../core/enums/time_signature.dart';
import '../data/metronome_settings.dart';
import '../data/metronome_state.dart';
import '../data/tap_tempo.dart';

/// The metronome as the screen sees it.
///
/// Not auto-disposed: the count carries on while the player goes to read the lesson
/// they are practising, which is most of what a metronome is for.
final StateNotifierProvider<MetronomeController, MetronomeState>
metronomeSettingsProvider =
    StateNotifierProvider<MetronomeController, MetronomeState>(
      (ref) => MetronomeController(ref.watch(metronomeProvider)),
    );

/// Every change of tempo, meter or accent, and the counting that follows from it.
///
/// A change made while it is counting is heard at once: the bar is rendered again and
/// the loop replaced, which is a beat's worth of interruption and the only honest way
/// to change tempo without pretending the old bar was the new one.
class MetronomeController extends StateNotifier<MetronomeState> {
  MetronomeController(this._metronome, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      _taps = TapTempo(clock: clock),
      super(const MetronomeState());

  final Metronome _metronome;
  final TapTempo _taps;

  /// Injectable so a test can assert on how much practice was counted without
  /// waiting for it.
  final DateTime Function() _clock;

  /// When the count that is going now started, and the seconds banked from the ones
  /// before it.
  ///
  /// Not in the state. Nothing on screen shows a running total, and a state that
  /// changed every second would rebuild the whole metronome once a second for the
  /// sake of a number nobody is reading.
  DateTime? _countingSince;
  int _counted = 0;

  Future<void> toggle() => state.playing ? stop() : start();

  Future<void> start() async {
    _countingSince = _clock();
    state = MetronomeState(settings: state.settings, playing: true);
    await _sound();
  }

  Future<void> stop() async {
    _bank();
    state = MetronomeState(settings: state.settings);
    await _metronome.stop();
  }

  /// The counting done since this was last asked, and forgotten in the asking.
  ///
  /// Taken rather than read, so the same stretch cannot be credited twice: whoever
  /// asks owns what they were given. A count still going is banked up to now and
  /// carries on from now, which is what lets a player leave the metronome running
  /// and have the part before they left already counted.
  int takeCountedSeconds() {
    _bank();
    if (state.playing) {
      _countingSince = _clock();
    }

    final counted = _counted;
    _counted = 0;
    return counted;
  }

  /// Adds the stretch that is going, if one is, to the total.
  void _bank() {
    final since = _countingSince;
    if (since != null) {
      _counted += _clock().difference(since).inSeconds;
      _countingSince = null;
    }
  }

  Future<void> setBpm(int bpm) => _change(state.settings.copyWith(bpm: bpm));

  Future<void> nudge(int by) => setBpm(state.settings.bpm + by);

  Future<void> setSignature(TimeSignature signature) =>
      _change(state.settings.copyWith(signature: signature));

  Future<void> setAccent(bool accentFirst) =>
      _change(state.settings.copyWith(accentFirst: accentFirst));

  /// Louder or quieter without going back to the top of the bar, because the volume
  /// is a knob on the thing rather than a different tempo.
  Future<void> setVolume(double volume) async {
    final settings = state.settings.copyWith(volume: volume);
    state = MetronomeState(settings: settings, playing: state.playing);

    if (state.playing) {
      await _report(() => _metronome.setVolume(settings.volume));
    }
  }

  /// The metronome set to what an exercise asks for, before its screen is opened.
  ///
  /// The volume and the accent are left alone: they are how this player likes a
  /// metronome to sound rather than anything a lesson has an opinion about. Any tapping
  /// they were part way through is forgotten, because it was for something else.
  Future<void> preset({
    required int bpm,
    required TimeSignature signature,
  }) async {
    _taps.reset();
    await _change(state.settings.copyWith(bpm: bpm, signature: signature));
  }

  /// A tap, and the tempo it makes once there have been two of them.
  ///
  /// Tapping does not start the count. A player taps to say how fast the thing they
  /// are about to play goes, and being answered by a click at the second tap is
  /// startling.
  Future<void> tap() async {
    final bpm = _taps.tap();
    if (bpm != null) {
      await setBpm(bpm);
    }
  }

  Future<void> _change(MetronomeSettings settings) async {
    state = MetronomeState(settings: settings, playing: state.playing);
    if (state.playing) {
      await _sound();
    }
  }

  Future<void> _sound() {
    final settings = state.settings;
    return _report(
      () => _metronome.start(
        signature: settings.signature,
        bpm: settings.bpm,
        accentFirst: settings.accentFirst,
        volume: settings.volume,
      ),
    );
  }

  /// A device that cannot play leaves the metronome stopped and says why.
  ///
  /// Kept in the state rather than thrown, because the failure belongs to a tap the
  /// player has already finished making and the screen shows it in a snack bar.
  Future<void> _report(Future<void> Function() work) async {
    try {
      await work();
    } catch (error) {
      state = MetronomeState(settings: state.settings, failure: error);
    }
  }
}
