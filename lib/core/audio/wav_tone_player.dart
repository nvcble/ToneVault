import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

import 'tone_player.dart';
import 'tone_synth.dart';

/// Sounds notes by writing the sound out and playing the file.
///
/// A file rather than a buffer handed straight to the player: playing a file is the one
/// thing every platform audioplayers supports the same way, and a chord that has been
/// played once is on disk already, so playing it again is free. They go in the
/// temporary directory, which the system is free to empty whenever it likes - the app
/// would simply write them again.
class WavTonePlayer implements TonePlayer {
  WavTonePlayer({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  /// The sounds written so far, by the notes they are of.
  final Map<String, String> _files = {};

  Directory? _directory;

  @override
  Future<void> playChord(List<int> midiNotes) =>
      _play('chord-${midiNotes.join('_')}', () => wavOfChord(midiNotes));

  @override
  Future<void> playNotes(List<int> midiNotes) => _play(
    'notes-${midiNotes.join('_')}',
    () => wavOfSequence([
      for (final note in midiNotes) [note],
    ]),
  );

  @override
  Future<void> playSequence(List<List<int>> chords) => _play(
    'bars-${chords.map((chord) => chord.join('_')).join('-')}',
    () => wavOfSequence(chords),
  );

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() async {
    await _player.dispose();
    // The files are left where they are. Deleting them would only cost the next
    // session the work of rendering them again, and the system clears the directory.
  }

  /// Starts the sound from the top, replacing whatever was playing.
  ///
  /// Replacing rather than queueing: the button that gets tapped twice means "again",
  /// and two chords over each other answers a different question than the one asked.
  Future<void> _play(String name, Uint8List Function() render) async {
    final path = _files[name] ?? await _write(name, render());
    _files[name] = path;

    await _player.stop();
    await _player.play(DeviceFileSource(path));
  }

  Future<String> _write(String name, Uint8List bytes) async {
    final directory = _directory ??= await getTemporaryDirectory();
    final file = File('${directory.path}/tonevault-$name.wav');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
