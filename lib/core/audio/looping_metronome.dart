import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

import '../enums/time_signature.dart';
import 'click_synth.dart';
import 'metronome.dart';

/// How much of the count goes into one file, rounded up to whole bars.
///
/// The file is what keeps time, and the one moment the app has to get right is where each
/// playing of it starts - so the longer the file, the fewer of those there are. A few
/// seconds' worth means one every few seconds at any tempo the app counts, rather than
/// one every four hundred milliseconds at the top of the range.
const Duration _stretch = Duration(seconds: 4);

/// Keeps time by starting a stretch of bars, over and over, on the beat.
///
/// The clicks inside a stretch are spaced within the file, so the audio device counts
/// them and they cannot wobble. All that is left is when each stretch starts, and that is
/// read off a stopwatch running since the count began: the nth stretch is due n stretches
/// after the first, so a start that comes a few milliseconds late is late on its own
/// rather than pushing everything after it later still.
///
/// Handing the file to the player with [ReleaseMode.loop] and letting it repeat is
/// shorter, and was what this did. It does not keep time. A looping player reaches the
/// end of the file and seeks back to the top, and both Android and iOS take tens of
/// milliseconds over that seek - time that is added to the bar, every bar. A minute in,
/// the count is a beat behind where it should be, which is what a player hears when they
/// try to play along with anything else.
///
/// Only two files are ever kept, taken in turn. There is nothing to be gained by
/// keeping the old tempos - and a player nudging the tempo up a beat at a time would
/// otherwise fill the directory with a file a nudge. Two rather than one because a
/// player asked for a path it is already holding does not read it again, and the new
/// bars have to arrive as a new file.
class LoopingMetronome implements Metronome {
  LoopingMetronome({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  /// How long since the count began. A stopwatch rather than the wall clock, which can
  /// be put back underneath it.
  final Stopwatch _elapsed = Stopwatch();

  /// Which count is running. Starting or stopping begins a new one, so a seek still in
  /// flight from the count before it knows it is answering nobody.
  int _count = 0;

  Duration _length = Duration.zero;
  Timer? _next;

  Directory? _directory;
  int _slot = 0;

  @override
  Future<void> start({
    required TimeSignature signature,
    required int bpm,
    required bool accentFirst,
    required double volume,
  }) async {
    final bar = signature.clickInterval(bpm) * signature.beats;
    final bars = (_stretch.inMicroseconds / bar.inMicroseconds).ceil();
    final path = await _write(
      wavOfBars(
        signature: signature,
        bpm: bpm,
        accentFirst: accentFirst,
        bars: bars,
      ),
    );

    await stop();
    await _player.setReleaseMode(ReleaseMode.stop);
    await _player.setVolume(volume);
    // Opened before the stopwatch starts, so the first click is not waiting on the file.
    await _player.setSource(DeviceFileSource(path));

    _length = bar * bars;
    _elapsed
      ..reset()
      ..start();
    await _play(_count, 0);
  }

  @override
  Future<void> stop() async {
    _count++;
    _next?.cancel();
    _elapsed.stop();
    await _player.stop();
  }

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> dispose() async {
    _next?.cancel();
    await _player.dispose();
  }

  /// Starts the stretch that comes after [started] of them, and books the next.
  ///
  /// The seek is what makes an early start honest: the player is a few milliseconds from
  /// the end of the stretch before and playing still, so there is nothing to resume and
  /// it is sent back to the top instead. Started late, it has stopped itself at the top
  /// already and the seek costs nothing.
  Future<void> _play(int count, int started) async {
    await _player.seek(Duration.zero);
    if (count != _count) {
      return;
    }

    await _player.resume();

    final due = _length * (started + 1) - _elapsed.elapsed;
    _next = Timer(
      due > Duration.zero ? due : Duration.zero,
      () => unawaited(_play(count, started + 1)),
    );
  }

  Future<String> _write(List<int> bytes) async {
    final directory = _directory ??= await getTemporaryDirectory();
    _slot = 1 - _slot;

    final file = File('${directory.path}/tonevault-metronome-$_slot.wav');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
