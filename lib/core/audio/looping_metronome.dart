import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

import '../enums/time_signature.dart';
import 'click_synth.dart';
import 'metronome.dart';

/// Keeps time by looping one bar of clicks.
///
/// The bar is written to the temporary directory and handed to the player on repeat, so
/// the timing is the audio device's and not a Dart timer's. Nothing here counts
/// anything.
///
/// Only two files are ever kept, taken in turn. There is nothing to be gained by
/// keeping the old tempos - a bar is played on a loop rather than replayed - and a
/// player nudging the tempo up a beat at a time would otherwise fill the directory with
/// a file a nudge. Two rather than one because a player that has been handed a path
/// may not read it again, and the new bar has to arrive as a new file.
class LoopingMetronome implements Metronome {
  LoopingMetronome({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  Directory? _directory;
  int _slot = 0;

  @override
  Future<void> start({
    required TimeSignature signature,
    required int bpm,
    required bool accentFirst,
    required double volume,
  }) async {
    final path = await _write(
      wavOfBar(signature: signature, bpm: bpm, accentFirst: accentFirst),
    );

    await _player.stop();
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(DeviceFileSource(path), volume: volume);
  }

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> dispose() => _player.dispose();

  Future<String> _write(List<int> bytes) async {
    final directory = _directory ??= await getTemporaryDirectory();
    _slot = 1 - _slot;

    final file = File('${directory.path}/tonevault-metronome-$_slot.wav');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
